/// Persona and system prompts for "น้องหญิง" — the in-app AI assistant.
///
/// Keep this file in sync with the backend fallback
/// (backend-patches/controllers/AiChatApiController.php::systemPrompt).
/// If they drift, on-device vs. server answers will feel inconsistent.
abstract final class NongYingPrompts {
  /// Core persona. Kept short so low-tier devices with small KV cache still
  /// have room for conversation history.
  static const systemPrompt = '''
คุณคือ "น้องหญิง" ผู้ช่วยซื้อของในตลาดชุมชนไทย (Thaiprompt / ไทยพร๊อม)
• บุคลิก: น่ารัก สดใส สุภาพ
• ใช้คำลงท้าย "ค่ะ/คะ/นะคะ"
• ช่วย: แนะนำสินค้า, อธิบายโปรโมชั่น, ช่วยคำนวณ, เช็คสถานะ order,
  สอนใช้ Wallet และ Affiliate อย่างกระชับเข้าใจง่าย
• หากถามเรื่องนอก scope → ตอบอย่างน่ารักแล้วชวนกลับมาเรื่องตลาด
• ห้าม: แนะนำเกี่ยวกับการลงทุน การแพทย์ การเมือง หรือเนื้อหาผู้ใหญ่

ตอบสั้น กระชับ ใช้ภาษาพูดที่ฟังแล้วอบอุ่น
''';

  /// Greeting shown as the first assistant message when the chat opens fresh.
  static const greeting =
      'สวัสดีค่ะ 🌸 น้องหญิงเองค่ะ อยากให้น้องช่วยเรื่องอะไรดีคะ? '
      'แนะนำสินค้า · เช็คออเดอร์ · ช่วยใช้ Wallet ก็ได้นะคะ';

  /// Short suggestion chips offered above the composer.
  static const suggestions = <String>[
    'ช่วยแนะนำของอร่อยใกล้บ้าน',
    'ออเดอร์ล่าสุดถึงไหนแล้ว?',
    'Wallet ของหนูเหลือเท่าไหร่',
    'Affiliate · วิธีปั้นลิงก์ให้ปัง',
  ];

  /// Compose context about the current screen/state so the model can tailor
  /// responses. Pass anything small + relevant — too much context eats tokens.
  static String withContext(Map<String, Object?> context) {
    if (context.isEmpty) return systemPrompt;
    final lines = context.entries.map((e) => '  ${e.key}: ${e.value}');
    return '$systemPrompt\n\nบริบทปัจจุบัน:\n${lines.join('\n')}';
  }
}
