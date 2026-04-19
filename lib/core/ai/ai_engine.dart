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
/// attribute correctly ("Powered by Gemma").
enum AiEngineKind {
  gemma4,
  gemma3_4b,
  gemma3_1b,
  server, // Gemini Flash / Claude Haiku / OpenAI on the backend
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
