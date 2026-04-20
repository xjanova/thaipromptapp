import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../remote_config/feature_flags.dart';
import '../remote_config/remote_config.dart';
import 'ai_engine.dart';
import 'gemma_ai_engine.dart';
import 'model_manager.dart';
import 'prompts.dart';
import 'server_ai_engine.dart';

/// Top-level orchestrator for the น้องหญิง assistant.
///
/// Responsibilities:
///   • Lazily initialise the `flutter_gemma` plugin.
///   • Pick an [AiEngine] based on device tier + feature flag + install state:
///       - On-device Gemma 4 / 3 4B / 3 1B when remote config advertises a
///         model URL for the tier AND the model is already installed.
///       - Server fallback otherwise.
///   • Compose the system prompt (persona + screen context) and relay the
///     stream back to the UI.
///
/// The UI never sees which engine is used except via [AiEngine.kind] / label.
class NongYingService {
  NongYingService({
    required this.modelManager,
    required this.api,
    required this.remoteConfig,
  });

  final ModelManager modelManager;
  final ApiClient api;
  final RemoteConfig remoteConfig;

  static bool _pluginInitialised = false;

  /// Idempotent — calling multiple times is a no-op.
  static Future<void> initializePlugin({String? huggingFaceToken}) async {
    if (_pluginInitialised) return;
    try {
      await FlutterGemma.initialize(huggingFaceToken: huggingFaceToken);
      _pluginInitialised = true;
    } catch (e) {
      if (kDebugMode) debugPrint('[NongYingService] FlutterGemma.initialize failed: $e');
    }
  }

  AiEngine? _cached;

  Future<AiEngine> engine() async {
    if (_cached != null && _cached!.isReady) return _cached!;

    final tier = await modelManager.selectTier();
    final on = await _tryOnDeviceForTier(tier.engine);
    _cached = on ?? ServerAiEngine(api);
    return _cached!;
  }

  Future<GemmaAiEngine?> _tryOnDeviceForTier(AiEngineKind kind) async {
    if (kind == AiEngineKind.server || kind == AiEngineKind.unavailable) return null;

    final url = _urlFor(kind);
    final modelId = _modelIdFor(kind);
    if (url.isEmpty || modelId.isEmpty) return null;

    try {
      await initializePlugin();
      final engine = GemmaAiEngine(
        kind: kind,
        modelId: modelId,
        maxTokens: _maxTokensFor(kind),
      );
      // Only flip to on-device if the model is already installed.
      // Download-on-first-use happens via a dedicated install screen — we
      // never block `reply()` on a multi-hundred-MB download.
      if (!await engine.isInstalled()) return null;
      await engine.preload();
      return engine;
    } catch (e) {
      if (kDebugMode) debugPrint('[NongYingService] on-device init failed for $kind: $e');
      return null;
    }
  }

  String _urlFor(AiEngineKind kind) => switch (kind) {
        AiEngineKind.gemma4_e4b => remoteConfig.string('ai_model_url_gemma4_e4b'),
        AiEngineKind.gemma4_e2b => remoteConfig.string('ai_model_url_gemma4_e2b'),
        _ => '',
      };

  String _modelIdFor(AiEngineKind kind) => switch (kind) {
        AiEngineKind.gemma4_e4b => remoteConfig.string('ai_model_id_gemma4_e4b',
            fallback: 'gemma-4-E4B-it-web.task'),
        AiEngineKind.gemma4_e2b => remoteConfig.string('ai_model_id_gemma4_e2b',
            fallback: 'gemma-4-E2B-it-web.task'),
        _ => '',
      };

  int _maxTokensFor(AiEngineKind kind) => switch (kind) {
        AiEngineKind.gemma4_e4b => 4096,
        AiEngineKind.gemma4_e2b => 2048,
        _ => 1024,
      };

  Stream<String> ask({
    required List<ChatTurn> history,
    Map<String, Object?> context = const {},
    String? systemPrompt,
  }) async* {
    final e = await engine();
    // Prefer the caller-supplied persona (fetched from the server) so
    // admin edits in `ai_bot_profiles` take effect on-device too. Fall
    // back to the embedded constant when the caller hasn't loaded a
    // persona yet (very cold start, no cache).
    final prompt = systemPrompt ?? NongYingPrompts.systemPrompt;
    final body = context.isEmpty
        ? prompt
        : '$prompt\n\nบริบทปัจจุบัน:\n' +
            context.entries.map((e) => '  ${e.key}: ${e.value}').join('\n');
    yield* e.reply(history: history, systemPrompt: body);
  }

  /// Surface what the install screen should actually download for this device.
  ///
  /// Returns a [ModelInstallPlan] with `status` reflecting why we got where
  /// we did — the install page uses it to distinguish "still loading" from
  /// "this device can't run on-device" vs. "admin hasn't configured a URL".
  Future<ModelInstallPlan> planInstall() async {
    final tier = await modelManager.selectTier();
    if (tier.engine == AiEngineKind.server ||
        tier.engine == AiEngineKind.unavailable) {
      return ModelInstallPlan.unavailable(
        kind: tier.engine,
        reason: 'เครื่องนี้ใช้โหมด cloud เท่านั้น (${tier.reason})',
      );
    }

    final url = _urlFor(tier.engine);
    final modelId = _modelIdFor(tier.engine);
    if (url.isEmpty) {
      return ModelInstallPlan.unconfigured(
        kind: tier.engine,
        modelId: modelId,
        reason: 'ยังไม่เปิดให้ติดตั้ง AI ตอนนี้ค่ะ · ระหว่างนี้ใช้ cloud ได้เลย',
      );
    }

    return ModelInstallPlan.ready(
      kind: tier.engine,
      modelId: modelId,
      url: url,
      modelType: ModelType.gemmaIt,
    );
  }

  /// Quick check used by chat entry points to decide whether to nudge the
  /// user toward the install screen. Fast — does not initialise the model.
  Future<bool> isOnDeviceInstalled() async {
    final tier = await modelManager.selectTier();
    if (tier.engine == AiEngineKind.server ||
        tier.engine == AiEngineKind.unavailable) {
      return false;
    }
    final modelId = _modelIdFor(tier.engine);
    if (modelId.isEmpty) return false;
    try {
      await initializePlugin();
      return await FlutterGemma.isModelInstalled(modelId);
    } catch (e) {
      if (kDebugMode) debugPrint('[NongYingService] isInstalled check failed: $e');
      return false;
    }
  }

  /// Fetch + register a model. Re-selects the engine on success.
  Future<void> installModel({
    required ModelInstallPlan plan,
    String? hfToken,
    required void Function(double percent) onProgress,
  }) async {
    await initializePlugin(huggingFaceToken: hfToken);
    final engine = GemmaAiEngine(
      kind: plan.kind,
      modelId: plan.modelId,
      modelType: plan.modelType,
    );
    await engine.install(url: plan.url, hfToken: hfToken, onProgress: onProgress);
    await _cached?.dispose();
    _cached = null;
  }

  Future<void> dispose() async {
    await _cached?.dispose();
    _cached = null;
  }
}

enum ModelInstallStatus {
  /// Device matches an on-device tier AND a model URL is configured.
  /// Install page should show size + "ดาวน์โหลด" CTA.
  ready,

  /// Device is too small / unsupported platform. Chat still works via cloud.
  unavailable,

  /// Device could run a model, but admin hasn't published a URL yet.
  /// Install page should tell the user + offer cloud mode.
  unconfigured,
}

class ModelInstallPlan {
  const ModelInstallPlan._({
    required this.status,
    required this.kind,
    required this.modelId,
    required this.url,
    required this.modelType,
    this.reason,
  });

  factory ModelInstallPlan.ready({
    required AiEngineKind kind,
    required String modelId,
    required String url,
    required ModelType modelType,
  }) =>
      ModelInstallPlan._(
        status: ModelInstallStatus.ready,
        kind: kind,
        modelId: modelId,
        url: url,
        modelType: modelType,
      );

  factory ModelInstallPlan.unavailable({
    required AiEngineKind kind,
    required String reason,
  }) =>
      ModelInstallPlan._(
        status: ModelInstallStatus.unavailable,
        kind: kind,
        modelId: '',
        url: '',
        modelType: ModelType.gemmaIt,
        reason: reason,
      );

  factory ModelInstallPlan.unconfigured({
    required AiEngineKind kind,
    required String modelId,
    required String reason,
  }) =>
      ModelInstallPlan._(
        status: ModelInstallStatus.unconfigured,
        kind: kind,
        modelId: modelId,
        url: '',
        modelType: ModelType.gemmaIt,
        reason: reason,
      );

  final ModelInstallStatus status;
  final AiEngineKind kind;
  final String modelId;
  final String url;
  final ModelType modelType;
  final String? reason;

  bool get isReady => status == ModelInstallStatus.ready;
}

final nongYingEnabledProvider =
    Provider<bool>((ref) => ref.watch(flagProvider(FlagKeys.aiEnabled)));

final nongYingServiceProvider = FutureProvider<NongYingService>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final manager = ref.watch(modelManagerProvider);
  final rc = ref.watch(remoteConfigControllerProvider).valueOrNull ?? RemoteConfig.empty();
  final service = NongYingService(modelManager: manager, api: api, remoteConfig: rc);
  ref.onDispose(service.dispose);
  unawaited(NongYingService.initializePlugin());
  return service;
});

void unawaited(Future<void> f) {}
