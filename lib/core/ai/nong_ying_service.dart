import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../remote_config/feature_flags.dart';
import 'ai_engine.dart';
import 'model_manager.dart';
import 'prompts.dart';
import 'server_ai_engine.dart';

/// Top-level orchestrator for the น้องหญิง assistant.
///
/// Responsibilities:
///   • pick an [AiEngine] based on tier + feature flags
///   • compose the system prompt with current screen context
///   • expose a simple `ask(history, context)` → `Stream<String>` for the UI
///
/// Once the real `flutter_gemma` integration lands we plug it in here; the UI
/// keeps calling `ask` with no changes.
class NongYingService {
  NongYingService({
    required this.modelManager,
    required this.api,
  });

  final ModelManager modelManager;
  final ApiClient api;

  AiEngine? _cachedEngine;

  Future<AiEngine> engine() async {
    if (_cachedEngine != null) return _cachedEngine!;
    final tier = await modelManager.selectTier();

    // On-device engines ship in a follow-up — for now all tiers fall through
    // to the server engine. The tier info is still logged + exposed so we
    // can do A/B and telemetry.
    _cachedEngine = switch (tier.engine) {
      AiEngineKind.gemma4 ||
      AiEngineKind.gemma3_4b ||
      AiEngineKind.gemma3_1b ||
      AiEngineKind.server ||
      AiEngineKind.unavailable =>
        ServerAiEngine(api),
    };
    return _cachedEngine!;
  }

  /// Stream a reply to [history]. The caller provides [context] (screen,
  /// product id, etc.) which gets folded into the system prompt.
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

  Future<void> dispose() async {
    await _cachedEngine?.dispose();
    _cachedEngine = null;
  }
}

final nongYingEnabledProvider =
    Provider<bool>((ref) => ref.watch(flagProvider(FlagKeys.aiEnabled)));

final nongYingServiceProvider = FutureProvider<NongYingService>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final manager = ref.watch(modelManagerProvider);
  final service = NongYingService(modelManager: manager, api: api);
  ref.onDispose(service.dispose);
  return service;
});
