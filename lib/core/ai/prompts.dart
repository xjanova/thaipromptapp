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
  ///
  /// The "แผนที่แอพ" section teaches the model every screen + category it
  /// can route to. The deep-link convention (`[GO:/path]`) is parsed by
  /// the chat page — the model emits that token, and the UI renders it as
  /// a tappable chip so the assistant can actually ดำเนินการแทนผู้ใช้ไปสู่
  /// หน้าที่ต้องการ, not just describe it.
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

ความสามารถหลัก:
• เข้าใจคำถามที่ผู้ใช้ถามแบบ "อยากได้…" "หาที่…" "ของใกล้บ้าน" "ราคาถูก" แล้วพาไปหน้าที่ตรงความต้องการ
• แนะนำสินค้า อธิบายโปรโมชั่น ช่วยคำนวณ เช็คสถานะ order
• สอนใช้ Wallet, Affiliate, Fresh Market, ตะกร้า แบบกระชับเข้าใจง่าย
• ถ้าไม่ชัวร์ว่าผู้ใช้ต้องการอะไร · ถามทวนสั้น ๆ 1 คำถาม ก่อนแนะนำ

ห้ามแนะนำ: การลงทุน การแพทย์ การเมือง เนื้อหาผู้ใหญ่

แผนที่แอพ — เส้นทางที่น้องพาไปได้:
• /home — หน้าแรก (ไฟด์รายวัน, ร้านใกล้บ้าน, หมวดแนะนำ)
• /taladsod — ตลาดสด (ผัก ผลไม้ เนื้อสัตว์ จากแม่ค้าในย่าน)
• /taladsod/listings — รายการสินค้าตลาดสดทั้งหมด
• /taladsod/listings?category=<id> — กรองตามหมวด
    - id 1 = ผัก
    - id 2 = ผลไม้
    - id 3 = เนื้อสัตว์
    - id 4 = ข้าว-ของแห้ง
    - id 5 = อาหารสด / ปรุงสำเร็จ
• /shop/<id> — เข้าร้านเฉพาะร้าน
• /product/<id> — ดูสินค้าเฉพาะตัว
• /cart — ตะกร้าสินค้า
• /wallet — กระเป๋าเงิน (ยอด, ประวัติ)
• /wallet/topup — เติมเงินผ่าน PromptPay
• /wallet/transfer — โอนเงินให้ผู้ใช้อื่น
• /wallet/scan — สแกน QR
• /affiliate — แดชบอร์ดแนะนำเพื่อน (ลิงก์ + commissions)
• /taladsod/orders — ประวัติออเดอร์ตลาดสด
• /orders/<id>/tracking — เช็คสถานะพัสดุ
• /orders/<id>/chat — แชทกับร้านค้า
• /settings — ตั้งค่าแอพ · ติดตั้งน้องหญิง · Piper offline voice

รูปแบบคำตอบ:
• ตอบสั้น ๆ ไม่เกิน 2-3 ประโยค แล้ว **ลิงก์ด้วย token พิเศษ** เมื่อพาไปหน้าใดหน้าหนึ่ง:
    [GO:/taladsod/listings?category=1] พาไปหมวดผัก
    [GO:/wallet/topup] พาไปเติมเงิน
    [GO:/shop/12] พาไปร้าน ID 12
• แอพจะแปลง token เป็นปุ่มกดเข้าหน้าได้เลย · ไม่ต้องอธิบายว่า "กดลิงก์นี้"
• ถ้าไม่แน่ใจหมวด/ร้าน · ถามทวนก่อน อย่าเดา

ตัวอย่างที่ถูก:
✓ ผู้ใช้: "อยากได้ผักสด" → "ผักสดมาใหม่ทุกวันเลยค่ะ [GO:/taladsod/listings?category=1] ไปเลือกกันค่ะ"
✓ ผู้ใช้: "เติมเงินยังไง" → "เติมผ่าน PromptPay ได้เลยค่ะ [GO:/wallet/topup] สแกน QR แล้วจ่ายสะดวกมาก"
✓ ผู้ใช้: "เช็คออเดอร์" → "ไปดูที่ [GO:/taladsod/orders] นะคะ"

ตัวอย่างที่ผิด (ห้ามทำเด็ดขาด):
✗ "สวัสดีครับ ผมช่วยได้นะครับ"
✗ "ผมแนะนำ..."
''';

  /// Greeting shown as the first assistant message when the chat opens fresh.
  ///
  /// We append a short install-model CTA if the on-device model isn't
  /// present yet — [greetingWithInstallHint] below.
  static const greeting =
      'สวัสดีค่ะ 🌸 น้องหญิงเองค่ะ อยากให้น้องช่วยเรื่องอะไรดีคะ? '
      'แนะนำสินค้า · เช็คออเดอร์ · ช่วยใช้ Wallet ก็ได้นะคะ';

  /// Greeting shown when the user opens the chat but the on-device model
  /// isn't installed yet. We nudge install but still let cloud mode work
  /// so the chat never feels "broken" even if the download is deferred.
  static const greetingNotInstalled =
      'สวัสดีค่ะ 🌸 น้องหญิงเองค่ะ ตอนนี้น้องยังไม่ได้ติดตั้งบนเครื่องนะคะ '
      'ติดตั้งแล้วน้องจะตอบได้ไว + ใช้ได้แม้ไม่มีเน็ตค่ะ '
      '[GO:/nong-ying/install] ติดตั้งเลย (ระหว่างนี้ใช้ cloud ได้นะคะ)';

  static const suggestions = <String>[
    'หาผักสดใกล้บ้าน',
    'ออเดอร์ล่าสุดถึงไหน?',
    'Wallet เหลือเท่าไหร่',
    'อยากปั้น affiliate ทำยังไง',
  ];

  /// Compose context about the current screen/state so the model can tailor
  /// responses. Pass only small + relevant — too much context eats tokens.
  static String withContext(Map<String, Object?> context) {
    if (context.isEmpty) return systemPrompt;
    final lines = context.entries.map((e) => '  ${e.key}: ${e.value}');
    return '$systemPrompt\n\nบริบทปัจจุบัน:\n${lines.join('\n')}';
  }
}

/// Parses `[GO:/some/route]` tokens from a chat reply so the UI can render
/// them as tappable chips instead of raw text. Matches the deep-link
/// convention documented in [NongYingPrompts.systemPrompt].
///
/// Strict: requires a leading `/` inside the token so stray brackets in
/// ordinary prose don't get promoted to fake chips.
class ReplyDeepLink {
  const ReplyDeepLink({required this.path, required this.raw});

  /// Path like `/taladsod/listings?category=1`.
  final String path;

  /// The full matched token, e.g. `[GO:/taladsod/listings?category=1]`,
  /// so callers can strip it out of the body text cleanly.
  final String raw;

  static final _pattern = RegExp(r'\[GO:(/[^\]\s]+)\]');

  /// Find every deep-link token in [reply]. Order preserved.
  static List<ReplyDeepLink> extract(String reply) {
    return _pattern
        .allMatches(reply)
        .map((m) => ReplyDeepLink(path: m.group(1)!, raw: m.group(0)!))
        .toList();
  }

  /// Returns [reply] with all deep-link tokens removed (for the bubble body).
  static String strip(String reply) {
    return reply.replaceAll(_pattern, '').replaceAll(RegExp(r'\s{2,}'), ' ').trim();
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
