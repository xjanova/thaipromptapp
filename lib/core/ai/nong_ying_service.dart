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
        AiEngineKind.gemma4 => remoteConfig.string('ai_model_url_gemma4'),
        AiEngineKind.gemma3_4b => remoteConfig.string('ai_model_url_gemma3_4b'),
        AiEngineKind.gemma3_1b => remoteConfig.string('ai_model_url_gemma3_1b'),
        _ => '',
      };

  String _modelIdFor(AiEngineKind kind) => switch (kind) {
        AiEngineKind.gemma4 => remoteConfig.string('ai_model_id_gemma4',
            fallback: 'gemma-3n-E4B-it-int4.task'),
        AiEngineKind.gemma3_4b => remoteConfig.string('ai_model_id_gemma3_4b',
            fallback: 'gemma-3n-E2B-it-int4.task'),
        AiEngineKind.gemma3_1b => remoteConfig.string('ai_model_id_gemma3_1b',
            fallback: 'gemma-3-1b-it-int4.task'),
        _ => '',
      };

  int _maxTokensFor(AiEngineKind kind) => switch (kind) {
        AiEngineKind.gemma4 => 4096,
        AiEngineKind.gemma3_4b => 2048,
        AiEngineKind.gemma3_1b => 1024,
        _ => 1024,
      };

  Stream<String> ask({
    required List<ChatTurn> history,
    Map<String, Object?> context = const {},
  }) async* {
    final e = await engine();
    yield* e.reply(
      history: history,
      systemPrompt: NongYingPrompts.withContext(context),
    );
  }

  /// Surface what the install screen should actually download for this device.
  /// Returns null when on-device is unavailable (tier → server, or no URL in
  /// remote config).
  Future<ModelInstallPlan?> planInstall() async {
    final tier = await modelManager.selectTier();
    final url = _urlFor(tier.engine);
    if (url.isEmpty) return null;
    return ModelInstallPlan(
      kind: tier.engine,
      modelId: _modelIdFor(tier.engine),
      url: url,
      modelType: ModelType.gemmaIt,
    );
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

class ModelInstallPlan {
  const ModelInstallPlan({
    required this.kind,
    required this.modelId,
    required this.url,
    required this.modelType,
  });
  final AiEngineKind kind;
  final String modelId;
  final String url;
  final ModelType modelType;
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
