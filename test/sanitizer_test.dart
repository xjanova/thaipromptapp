// Tests for ReplySanitizer — enforces that น้องหญิง never slips a male
// polite particle, even if Gemma/Gemini returns one mid-stream.

import 'package:flutter_test/flutter_test.dart';
import 'package:thaipromptapp/core/ai/prompts.dart';

void main() {
  group('ReplySanitizer', () {
    String pipe(List<String> chunks) {
      final s = ReplySanitizer();
      final buf = StringBuffer();
      for (final c in chunks) {
        buf.write(s.process(c));
      }
      buf.write(s.flush());
      return buf.toString();
    }

    test('replaces ครับ with ค่ะ in a single chunk', () {
      expect(pipe(['สวัสดีครับ น้องช่วยได้นะครับ']), 'สวัสดีค่ะ น้องช่วยได้นะคะ');
    });

    test('replaces ผม with หนู in common leading phrases', () {
      expect(pipe(['ผมแนะนำข้าวซอย']), 'หนูแนะนำข้าวซอย');
      expect(pipe(['ผมจะช่วยค่ะ']), 'หนูจะช่วยค่ะ');
      expect(pipe(['ของผมคือ']), 'ของหนูคือ');
    });

    test('handles ครับ split across stream chunks', () {
      // The boundary buffer must hold partial tokens so "คร" + "ับ" still
      // gets rewritten to ค่ะ and doesn't leak as "ครับ".
      final out = pipe(['สวัสดี', 'คร', 'ับ ค่ะ']);
      expect(out.contains('ครับ'), isFalse, reason: out);
      expect(out.contains('ค่ะ'), isTrue, reason: out);
    });

    test('passes through clean female speech unchanged', () {
      expect(pipe(['สวัสดีค่ะ หนูแนะนำข้าวซอยนะคะ']), 'สวัสดีค่ะ หนูแนะนำข้าวซอยนะคะ');
    });

    test('nested replacement นะครับ → นะคะ (not นะค่ะ)', () {
      expect(pipe(['เดี๋ยวเช็คให้นะครับ']), 'เดี๋ยวเช็คให้นะคะ');
    });
  });
}
