import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import 'ai_engine.dart';

/// On-device AI engine backed by `flutter_gemma` (MediaPipe GenAI on Android,
/// Core ML on iOS ≥ 16).
///
/// Flow:
///   1. [install] — download the model from a URL (HuggingFace or our mirror)
///      into MediaPipe's on-device cache. Safe to call repeatedly; no-ops if
///      the model is already installed.
///   2. [preload] — lazily create the InferenceModel + open a chat session.
///      Warms the token cache so the first reply is fast.
///   3. [reply] — streams tokens back.
///
/// We never ship weights in the APK — they're fetched from a URL exposed via
/// backend remote config (`ai_model_url`). Keeps the APK under Play's cap and
/// lets us A/B new models without client releases.
class GemmaAiEngine implements AiEngine {
  GemmaAiEngine({
    required this.kind,
    required this.modelId,
    this.modelType = ModelType.gemmaIt,
    this.maxTokens = 2048,
    this.preferredBackend = PreferredBackend.gpu,
  });

  @override
  final AiEngineKind kind;

  /// Filename as registered by flutter_gemma (e.g. "gemma-3n-4b-it-int4.task").
  /// Used to query [FlutterGemma.isModelInstalled].
  final String modelId;

  final ModelType modelType;
  final int maxTokens;
  final PreferredBackend preferredBackend;

  InferenceModel? _model;
  InferenceChat? _chat;

  @override
  String get label => switch (kind) {
        AiEngineKind.gemma4_e4b => 'น้องหญิง · Gemma 4 E4B',
        AiEngineKind.gemma4_e2b => 'น้องหญิง · Gemma 4 E2B',
        _ => 'น้องหญิง',
      };

  @override
  bool get isReady => _model != null;

  /// Check if the model has already been downloaded on this device.
  Future<bool> isInstalled() => FlutterGemma.isModelInstalled(modelId);

  /// Download + register the model. Call [FlutterGemma.initialize] once in
  /// app bootstrap before this. On subsequent runs this is a no-op.
  ///
  /// [onProgress] receives percentages in 0..100.
  Future<void> install({
    required String url,
    String? hfToken,
    void Function(double percent)? onProgress,
  }) async {
    final builder = FlutterGemma.installModel(modelType: modelType)
        .fromNetwork(url, token: hfToken);
    if (onProgress != null) {
      builder.withProgress((p) => onProgress(p.toDouble()));
    }
    await builder.install();
  }

  /// Construct the active model if not already.
  Future<void> preload() async {
    if (_model != null) return;
    _model = await FlutterGemma.getActiveModel(
      maxTokens: maxTokens,
      preferredBackend: preferredBackend,
    );
  }

  @override
  Stream<String> reply({
    required List<ChatTurn> history,
    required String systemPrompt,
  }) async* {
    try {
      await preload();
    } catch (e) {
      if (kDebugMode) debugPrint('[GemmaAiEngine] preload failed: $e');
      yield 'น้องหญิงยังโหลดโมเดลไม่เสร็จค่ะ · $e';
      return;
    }

    final model = _model!;

    try {
      // New chat per reply keeps the prompt simple and avoids history drift.
      final chat = await model.createChat(supportImage: false);
      _chat = chat;

      // System prompt as first user chunk — Gemma IT's prompt format doesn't
      // have a dedicated "system" role; front-loading the persona works well.
      await chat.addQueryChunk(Message.text(text: systemPrompt, isUser: true));

      // Replay history. The last user turn is the fresh query.
      ChatTurn? lastUser;
      for (final turn in history) {
        switch (turn.role) {
          case ChatRole.user:
            if (lastUser != null) {
              await chat.addQueryChunk(Message.text(text: lastUser.text, isUser: true));
            }
            lastUser = turn;
          case ChatRole.assistant:
            await chat.addQueryChunk(Message.text(text: turn.text, isUser: false));
          case ChatRole.system:
            // System role merged into systemPrompt already.
            break;
        }
      }

      if (lastUser == null) {
        yield 'อยากถามอะไรน้องคะ?';
        return;
      }
      await chat.addQueryChunk(Message.text(text: lastUser.text, isUser: true));

      await for (final response in chat.generateChatResponseAsync()) {
        if (response is TextResponse) {
          yield response.token;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[GemmaAiEngine] stream failed: $e');
      yield 'ขอโทษค่ะ น้องติดปัญหานิดหน่อย · $e';
    }
  }

  @override
  Future<void> dispose() async {
    await _chat?.close();
    _chat = null;
    await _model?.close();
    _model = null;
  }
}
