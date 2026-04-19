# Changelog

All notable changes to the Thaiprompt app.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.1] - 2026-04-19

### เพิ่ม — น้องหญิง AI + เสียง
- **AI น้องหญิง** พร้อมใช้งาน · แตะ "น้องหญิง" ที่มุมขวาล่างของหน้าแรกเพื่อแชทได้เลยค่ะ
- **เสียงน้องหญิง** (หญิงไทย) · แตะ "ฟังเสียง" ใต้คำตอบแต่ละบับเบิลเพื่อให้น้องอ่านออกเสียง (ไม่อ่านเองอัตโนมัติ)
- **หน้าตั้งค่าใหม่** (เมนู → ตั้งค่า) · ดาวน์โหลดโมเดลน้องหญิง (Gemma) กับเสียงออฟไลน์ได้ตามต้องการ · มีแถบโปรเกรสชัดเจนทุกขั้นตอน

### ปลอดภัย + บุคลิก
- บังคับ persona น้องหญิงเป็นผู้หญิงเด็ดขาด · ทั้ง system prompt และ sanitizer ฝั่ง client (`ครับ→ค่ะ`, `ผม→หนู`)
- ลบเสียงผู้ชายออกทั้งหมดจาก TTS · server-side enforced

### ภายใน
- Flutter 3.41.7 / Dart 3.11.5 · target Android 24+ / iOS 16+
- `flutter_gemma ^0.13.5` (on-device Gemma 4 / 3 4B / 3 1B) · `sherpa_onnx ^1.12.39` (Piper offline) · `just_audio ^0.9.42`
- โมเดล AI และเสียงออฟไลน์ **ไม่ถูกฝังใน APK** · ดาวน์โหลดจากหน้าตั้งค่าเมื่อต้องการ
- TtsRouter: Gemini cloud เป็นหลัก · auto-fallback → Piper offline เมื่อโควต้าฟรีหมด (429/403) หรือไม่มีเน็ต

## [1.0.0] - 2026-04-19

### เพิ่ม
- เปิดตัวเวอร์ชันแรกของ Thaiprompt · ไทยพร๊อม 🎉
- Onboarding + สมัครสมาชิก / เข้าสู่ระบบ (รวม LINE Login native)
- หน้าแรก: ตลาดวันนี้, Wallet mini, Affiliate mini, หมวดหมู่, ร้านใกล้บ้าน
- หน้าสินค้า: ตัวเลือกขนาด + add-ons + share ลิงก์ affiliate
- หน้าร้านค้า: โปรไฟล์ร้าน + สถิติ + tabs (สินค้า/รีวิว/โปรโมชัน)
- ตะกร้า: แก้จำนวน, ใช้ Coins, สรุปราคา, จ่ายด้วย Wallet
- ติดตามออเดอร์: แผนที่สไตล์ 3D + timeline
- แชทร้านค้า: พิมพ์ข้อความ + แนบสินค้าให้กดสั่งต่อได้
- Wallet: balance + PromptPay QR + กราฟค่าใช้จ่าย 7 วัน + ประวัติธุรกรรม
- Affiliate: tier progress + earnings + ลิงก์ทำเงินสูงสุด + ชวนเพื่อน
- ระบบอัปเดตอัตโนมัติในแอพ: ดาวน์โหลด APK ใหม่ + โปรเกรสบาร์ + changelog
- แสดงเวอร์ชันแอพในหน้าแรก · แตะเพื่อเช็คอัปเดต

### ปลอดภัย
- Sanctum Bearer token เก็บใน `flutter_secure_storage` (เข้ารหัส)
- PIN ของ Wallet เก็บเป็น HMAC-SHA256 + constant-time verify (ไม่เก็บ PIN ดิบ)
- Release APK ใช้ `--obfuscate --split-debug-info` + Proguard
- FileProvider + scoped storage สำหรับ APK update install
- GPS ใช้ geohash-5 (≈5km) สำหรับ analytics, geohash-7 (≈150m) เฉพาะออเดอร์

### ภายใน
- Flutter 3.38 / Dart 3.10 · target Android 24+ / iOS 13+
- Riverpod 2 · go_router · dio + Sanctum interceptor · drift · sherpa-onnx
- CI/CD: GitHub Actions สร้าง APK (universal + split-per-abi) + AAB ทุก tag `v*.*.*`

[Unreleased]: https://github.com/xjanova/thaipromptapp/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.1
[1.0.0]: https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.0
