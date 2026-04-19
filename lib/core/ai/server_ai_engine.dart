import 'dart:async';

import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/endpoints.dart';
import 'ai_engine.dart';

/// Server-side fallback — always available as long as we have network.
///
/// Streams aren't supported by the simple `/v1/ai/chat` endpoint yet, so we
/// fake a one-shot stream: emit the full reply once the HTTP call returns.
/// Once the backend exposes SSE we swap this out.
class ServerAiEngine implements AiEngine {
  ServerAiEngine(this._api);
  final ApiClient _api;

  @override
  AiEngineKind get kind => AiEngineKind.server;

  @override
  String get label => 'น้องหญิง · Cloud';

  @override
  bool get isReady => true;

  @override
  Stream<String> reply({
    required List<ChatTurn> history,
    required String systemPrompt,
  }) async* {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        Api.aiChat,
        data: {
          'messages': history.map((t) => t.toJson()).toList(),
          'context': <String, Object?>{},
        },
      );
      final text = res['reply']?.toString() ?? '';
      if (text.isEmpty) {
        yield 'ขออภัยค่ะ น้องหญิงไม่ได้รับคำตอบค่ะ 🥺';
      } else {
        yield text;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ServerAiEngine] failed: $e');
      yield 'ขอโทษค่ะ น้องติดปัญหานิดนึง ลองใหม่สักครู่นะคะ';
    }
  }

  @override
  Future<void> dispose() async {}
}
