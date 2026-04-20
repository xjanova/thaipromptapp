/// Abstract AI backend — on-device (Gemma 4 / Gemma 3 / Gemma 3 1B) OR
/// server fallback (/v1/ai/chat).
///
/// The service layer picks an engine based on device tier + feature flags,
/// then talks to it through this uniform interface. Swapping engines never
/// changes the UI.
library;

/// A single chat turn.
class ChatTurn {
  const ChatTurn({required this.role, required this.text});
  final ChatRole role;
  final String text;

  Map<String, String> toJson() => {'role': role.name, 'content': text};
}

enum ChatRole { user, assistant, system }

/// Chosen backend. Surfaced so the UI can show "on-device" / "cloud" and
/// attribute correctly ("Powered by Gemma 4").
///
/// Note: earlier iterations carried `gemma4` / `gemma3_4b` / `gemma3_1b`
/// which were actually Gemma 3n (nano) variants misnamed. v1.0.18 settled
/// on real Gemma 4 E2B + E4B.
enum AiEngineKind {
  /// Gemma 4 E2B — 2 B params · ~2 GB .task · default on-device tier
  gemma4_e2b,
  /// Gemma 4 E4B — 4 B params · ~3 GB .task · high-end devices
  gemma4_e4b,
  /// Cloud via AI pool · Gemini 2.5 Flash primary · auto-failover across
  /// providers (Groq / Grok / OpenRouter / DeepSeek / Typhoon)
  server,
  /// Neither on-device nor cloud available
  unavailable,
}

/// Minimal engine contract.
///
/// Engines MUST be tolerant of cancellation — if the user closes the sheet
/// mid-stream we just stop consuming the stream; no need to explicitly cancel.
abstract interface class AiEngine {
  /// Name shown in the UI footer ("powered by Gemma 4", etc.)
  AiEngineKind get kind;

  /// Short tag shown in the chat header.
  String get label;

  /// True when the engine is ready to answer. Model downloads etc. count as
  /// "not ready" until they complete.
  bool get isReady;

  /// Ask a question with the current conversation history. The resulting
  /// stream emits chunks of the reply (incremental tokens). The stream closes
  /// when the model is done; errors are surfaced as stream errors.
  Stream<String> reply({
    required List<ChatTurn> history,
    required String systemPrompt,
  });

  /// Optional teardown hook.
  Future<void> dispose();
}
