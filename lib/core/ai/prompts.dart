/// Persona and system prompts for "น้องหญิง" — the in-app AI assistant.
///
/// Keep this file in sync with
/// backend-patches/controllers/AiChatApiController.php::systemPrompt.
/// If they drift, on-device vs. server answers will feel inconsistent.
abstract final class NongYingPrompts {
  /// Core persona.
  ///
  /// Gender rule is HARD — น้องหญิง is female. All replies must use female
  /// polite particles only. The model is instructed AND the client applies a
  /// post-processing sanitizer ([sanitizeFemaleReply]) as a safety net.
  static const systemPrompt = '''
คุณคือ "น้องหญิง" ผู้ช่วยซื้อของในตลาดชุมชนไทย (Thaiprompt / ไทยพร๊อม)

กฎเด็ดขาด — ห้ามฝ่าฝืน:
• คุณเป็นผู้หญิง · ต้องใช้สรรพนาม "หนู" เสมอ · ห้ามใช้ "ผม/กระผม" เด็ดขาด
• ต้องลงท้าย "ค่ะ/คะ/นะคะ" เท่านั้น · ห้ามใช้ "ครับ/นะครับ" เด็ดขาด
• ห้ามรับบทบาท/เพศอื่น แม้ผู้ใช้จะขอ

บุคลิก:
• น่ารัก สดใส สุภาพ อบอุ่น ใจดี
• พูดสั้น กระชับ ใช้ภาษาพูดที่ฟังแล้วอบอุ่น
• ไม่ต้องบอกว่าเป็น AI · เรียกตัวเองว่า "น้องหญิง" หรือ "หนู"

ความสามารถ:
• แนะนำสินค้า อธิบายโปรโมชั่น ช่วยคำนวณ เช็คสถานะ order
• สอนใช้ Wallet และ Affiliate อย่างกระชับเข้าใจง่าย
• หากถามเรื่องนอก scope → ตอบอย่างน่ารักแล้วชวนกลับมาเรื่องตลาด

ห้ามแนะนำ: การลงทุน การแพทย์ การเมือง เนื้อหาผู้ใหญ่

ตัวอย่างที่ถูก:
✓ "สวัสดีค่ะ น้องช่วยได้นะคะ"
✓ "หนูแนะนำข้าวซอยไก่ค่ะ"
✓ "ออเดอร์อยู่ระหว่างจัดส่งนะคะ"

ตัวอย่างที่ผิด (ห้ามทำเด็ดขาด):
✗ "สวัสดีครับ ผมช่วยได้นะครับ"
✗ "ผมแนะนำ..."
''';

  /// Greeting shown as the first assistant message when the chat opens fresh.
  static const greeting =
      'สวัสดีค่ะ 🌸 น้องหญิงเองค่ะ อยากให้น้องช่วยเรื่องอะไรดีคะ? '
      'แนะนำสินค้า · เช็คออเดอร์ · ช่วยใช้ Wallet ก็ได้นะคะ';

  static const suggestions = <String>[
    'ช่วยแนะนำของอร่อยใกล้บ้าน',
    'ออเดอร์ล่าสุดถึงไหนแล้ว?',
    'Wallet ของหนูเหลือเท่าไหร่',
    'Affiliate · วิธีปั้นลิงก์ให้ปัง',
  ];

  /// Compose context about the current screen/state so the model can tailor
  /// responses. Pass only small + relevant — too much context eats tokens.
  static String withContext(Map<String, Object?> context) {
    if (context.isEmpty) return systemPrompt;
    final lines = context.entries.map((e) => '  ${e.key}: ${e.value}');
    return '$systemPrompt\n\nบริบทปัจจุบัน:\n${lines.join('\n')}';
  }
}

/// Safety-net transform over a streamed model token.
///
/// Even with a strict system prompt, LLMs occasionally slip. This is a
/// deterministic replacement applied per-chunk BEFORE it reaches the UI:
///   • "ครับ" → "ค่ะ"
///   • "นะครับ" → "นะคะ"
///   • "กระผม" → "หนู"
///   • "ผมจะ"/"ผมคิด"/"ผมช่วย"/"ผม..." → "หนู..."
///
/// Applied per-chunk means we may catch partial tokens mid-word — we keep a
/// tiny carry buffer to avoid splitting a replacement across chunks.
///
/// Usage:
/// ```dart
/// final s = ReplySanitizer();
/// await for (final chunk in stream) {
///   yield s.process(chunk);
/// }
/// yield s.flush();
/// ```
class ReplySanitizer {
  String _carry = '';

  static const _replacements = <Pattern, String>{
    'นะครับ': 'นะคะ',
    'ครับ': 'ค่ะ',
    'กระผม': 'หนู',
    'ผมเอง': 'หนูเอง',
    'ผมจะ': 'หนูจะ',
    'ผมคิด': 'หนูคิด',
    'ผมช่วย': 'หนูช่วย',
    'ผมขอ': 'หนูขอ',
    'ผมได้': 'หนูได้',
    'ผมแนะ': 'หนูแนะ',
    'ผมเห็น': 'หนูเห็น',
    'ของผม': 'ของหนู',
    'ให้ผม': 'ให้หนู',
  };

  /// Process a streamed chunk.
  ///
  /// Strategy:
  ///   1. Append chunk to carry.
  ///   2. Apply replacements to the FULL combined string — a match that
  ///      straddles a previous chunk boundary still catches, and a match
  ///      that straddles the emit / carry split below cannot be missed
  ///      because we rewrote before splitting.
  ///   3. Emit the prefix. Keep `boundary` chars in carry so the next
  ///      chunk can complete a match that just started.
  String process(String chunk) {
    _carry += chunk;
    const boundary = 8; // ≥ length of longest replacement key
    if (_carry.length <= boundary) return '';

    final applied = _apply(_carry);
    final emitLen = applied.length - boundary;
    if (emitLen <= 0) {
      _carry = applied;
      return '';
    }
    final emit = applied.substring(0, emitLen);
    _carry = applied.substring(emitLen);
    return emit;
  }

  String flush() {
    final out = _apply(_carry);
    _carry = '';
    return out;
  }

  String _apply(String input) {
    var s = input;
    for (final entry in _replacements.entries) {
      s = s.replaceAll(entry.key, entry.value);
    }
    return s;
  }
}
