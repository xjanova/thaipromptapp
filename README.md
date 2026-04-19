<div align="center">

<img src="assets/images/logoapp.png" alt="ThaiPromptAPP" width="160" height="160" />

# ThaiPromptAPP — ไทยพร๊อม

**ตลาดชุมชนไทยในมือคุณ · Community Marketplace · Wallet · น้องหญิง AI**

[![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-24%2B-3DDC84?logo=android&logoColor=white)](#)
[![iOS](https://img.shields.io/badge/iOS-16%2B-000000?logo=apple&logoColor=white)](#)
[![License](https://img.shields.io/badge/License-Proprietary-red)](#license)
[![Release](https://img.shields.io/github/v/release/xjanova/thaipromptapp?label=Release&color=ff3e6c)](https://github.com/xjanova/thaipromptapp/releases)
[![CI](https://img.shields.io/github/actions/workflow/status/xjanova/thaipromptapp/release.yml?label=CI)](https://github.com/xjanova/thaipromptapp/actions)

</div>

---

## ✨ สิ่งที่แอพทำได้

| | |
|---|---|
| 🛒 **ตลาดชุมชน** | ซื้อสินค้าจากร้านในย่านบ้านคุณ · หมวดหมู่ + ร้านใกล้บ้าน + แชทตรงกับร้าน |
| 💰 **Wallet** | เติมเงินด้วย PromptPay QR · ดูค่าใช้จ่าย 7 วัน · โอน / สแกน / ถอน |
| 🔗 **Affiliate** | แชร์ลิงก์ทำเงิน · ระบบ tier + earnings + ชวนเพื่อน |
| 🤖 **น้องหญิง AI** | AI ผู้ช่วยภาษาไทย (Gemma on-device) · แชทได้แม้ออฟไลน์ |
| 🔊 **เสียงน้องหญิง** | Gemini TTS หลัก · auto-fallback → Piper offline เมื่อโควต้าหมด |
| 🚚 **ติดตามออเดอร์** | แผนที่ 3D claymorphism + timeline + chat |
| 🔄 **Auto-update** | ดาวน์โหลด APK ใหม่ในแอพ + progress bar + changelog |

---

## 📑 สารบัญ

- [จับภาพหน้าจอ](#-จับภาพหน้าจอ)
- [สถาปัตยกรรม](#-สถาปัตยกรรม)
- [เริ่มใช้งาน (Dev)](#-เริ่มใช้งาน-dev)
- [การ build release](#-การ-build-release)
- [กฎเหล็กของผลิตภัณฑ์](#-กฎเหล็กของผลิตภัณฑ์)
- [แบรนดิ้งและไอคอน](#-แบรนดิ้งและไอคอน)
- [Splash + เสียงเปิดแอพ](#-splash--เสียงเปิดแอพ-16-bit-chiptune)
- [โครงสร้างโปรเจกต์](#-โครงสร้างโปรเจกต์)
- [การเทส](#-การเทส)
- [License](#license)

---

## 📱 จับภาพหน้าจอ

> สกรีนชอตจริง: บันทึก `.png` ไว้ใน `docs/screenshots/` แล้วลิงก์มาในตารางนี้.

| Splash | Onboarding | Home | Wallet |
|:-:|:-:|:-:|:-:|
| _coming soon_ | _coming soon_ | _coming soon_ | _coming soon_ |

| Product | Cart | น้องหญิง Chat | Affiliate |
|:-:|:-:|:-:|:-:|
| _coming soon_ | _coming soon_ | _coming soon_ | _coming soon_ |

---

## 🏗 สถาปัตยกรรม

```
┌────────────────────────────────────────────────────────┐
│  Flutter app  (lib/)                                   │
│  ─ features/   ← 1 dir per screen, owns its UI+state   │
│  ─ core/       ← auth, theme, ai, tts, analytics       │
│  ─ shared/     ← widgets + models reused everywhere    │
│  ─ app/        ← MaterialApp + go_router config        │
├────────────────────────────────────────────────────────┤
│  Riverpod 2  · go_router · dio (Sanctum)               │
│  flutter_gemma  ·  sherpa_onnx (Piper)  ·  just_audio  │
├────────────────────────────────────────────────────────┤
│  Backend  ← Laravel 11 + Sanctum                       │
│  /v1/app/config · /v1/ai/chat · /v1/ai/tts · ...       │
└────────────────────────────────────────────────────────┘
```

ดูรายละเอียดทั้งหมดที่ [`ARCHITECTURE.md`](ARCHITECTURE.md) · roadmap ที่ [`ROADMAP.md`](ROADMAP.md) · history ที่ [`CHANGELOG.md`](CHANGELOG.md).

---

## 🚀 เริ่มใช้งาน (Dev)

ต้องมี Flutter ≥ 3.41 + Dart ≥ 3.11 + Android SDK 35 + JDK 17.

```bash
git clone https://github.com/xjanova/thaipromptapp.git
cd thaipromptapp
flutter pub get
flutter run                  # รันบน emulator/device ที่เชื่อมอยู่
```

แอพจะเปิดที่หน้า splash (logo zoom + chiptune) → onboarding → home.

---

## 📦 การ build release

```bash
# Android — APK universal (สำหรับแจกตรง)
flutter build apk --release \
  --obfuscate --split-debug-info=build/symbols

# Android — AAB (สำหรับ Play Store)
flutter build appbundle --release \
  --obfuscate --split-debug-info=build/symbols

# iOS (จาก macOS)
flutter build ipa --release --obfuscate --split-debug-info=build/symbols
```

CI/CD: push tag `v*.*.*` → GitHub Actions เซ็น APK + AAB ด้วย upload-keystore + ปล่อย GitHub Release อัตโนมัติ. ดู [`.github/workflows/release.yml`](.github/workflows/release.yml).

---

## 🛡 กฎเหล็กของผลิตภัณฑ์

> 5 กฎที่ enforce ทั้ง client และ backend (ดูเหตุผลเต็มที่ memory store).

1. **น้องหญิงเป็นผู้หญิง** · ห้าม `ครับ / นะครับ / ผม / กระผม` ในทุก output · sanitizer + system prompt เป็นเจ้าหน้าที่.
2. **Chat ไม่อ่านออกเสียงเอง** · TTS เล่นเฉพาะตอนผู้ใช้แตะ "ฟังเสียง" · ไม่มี code path auto-speak.
3. **Quota หมด → fallback Piper อัตโนมัติ** · Gemini 429/403/network error → flip เป็น Piper offline ทันที.
4. **Gemma + Piper weights ดาวน์โหลดเอง** · ไม่ฝังใน APK · ปุ่มในหน้า Settings + progress bar.
5. **ไม่มีเสียงผู้ชายใน TTS** · client + server enforce voice list (`th-premwadee`, `th-achara`).

ละเมิดข้อใดข้อหนึ่ง = test แตก (`test/sanitizer_test.dart` + เพื่อน). อย่าลด assertion.

---

## 🎨 แบรนดิ้งและไอคอน

โลโก้แอพอยู่ที่ [`assets/images/logoapp.png`](assets/images/logoapp.png) (1024×1024, navy + ทอง).

ถ้าเปลี่ยนโลโก้ใหม่ → regenerate ทุกแพลตฟอร์มด้วย:

```bash
dart run flutter_launcher_icons        # mipmap + iOS AppIcon
dart run flutter_native_splash:create  # Android 12 + เก่า + iOS LaunchImage
```

config อยู่ตรง bottom ของ [`pubspec.yaml`](pubspec.yaml) (sections `flutter_launcher_icons:` + `flutter_native_splash:`).

**Adaptive icon**: foreground ใช้ `assets/images/logoapp_foreground.png` (โลโก้ + safe-zone padding 18%) บนพื้น `#0E2A4F`.

---

## 🎬 Splash + เสียงเปิดแอพ (16-bit chiptune)

มี 2 ชั้น:

1. **Native splash** (โดย OS) — แสดง `logoapp.png` กลางจอบนพื้น navy `#0E2A4F` ตั้งแต่วินาทีที่กดเปิดแอพ จนกว่า Flutter engine จะ render frame แรก.
2. **Animated splash** (Flutter — [`lib/features/splash/splash_page.dart`](lib/features/splash/splash_page.dart)) — เล่น 2.2 วินาที:

   | ช่วงเวลา | สิ่งที่เกิดขึ้น |
   |---|---|
   | 0.00–0.55s | โลโก้ซูม 0.55→1.08 + soft bounce + กลิทเตอร์ทองแกน |
   | 0.20–0.85s | วงแหวนทองพัลส์ออก 3 ชั้น + sheen sweep ทแยง |
   | 0.30–0.75s | ไตเติ้ล "ThaiPromptAPP" gradient ทอง slide-up + fade |
   | 0.45–0.95s | tagline ภาษาไทยเฟดเข้า + dot loader 3 จุด |
   | 0.75–1.00s | hold + gentle exhale แล้ว flip `splashGateProvider` |

**เสียง**: [`assets/sfx/startup_16bit.wav`](assets/sfx/startup_16bit.wav) — chiptune arpeggio C5→E5→G5→C6 + shimmer tail · square + triangle wave สังเคราะห์เอง · ~1 วินาที · 44.1kHz mono.

ถ้าเครื่องปิดเสียงหรือ audio session ไม่ว่าง → ข้ามการเล่นแบบเงียบ ไม่ blocking boot.

ต้องการ regenerate เสียง? script เก็บไว้ในประวัติคอมมิตที่เพิ่ม v1.0.2 — รัน python ที่ใช้ `wave` + `struct` (ไม่ต้อง install อะไร).

---

## 🗂 โครงสร้างโปรเจกต์

```
lib/
├─ app/                  ← MaterialApp, go_router
├─ core/
│  ├─ ai/                ← AiEngine + Gemma + prompts + sanitizer
│  ├─ analytics/         ← session, batch flush, geohash
│  ├─ auth/              ← Sanctum, secure storage, AuthState
│  ├─ remote_config/     ← ETag-cached config fetch
│  ├─ theme/             ← claymorphism tokens (TpColors, TpShadows)
│  ├─ tts/               ← TtsRouter (Gemini ↔ Piper)
│  └─ update/            ← APK auto-update + FileProvider install
├─ features/             ← 1 dir per screen (12 features)
│  ├─ splash/            ← animated splash + chiptune (this PR)
│  ├─ onboarding/  home/  product/  shop/  cart/
│  ├─ tracking/  chat/  wallet/  affiliate/
│  ├─ nong_ying/         ← AI assistant + install model page
│  └─ settings/  consent/  update/  auth/
└─ shared/
   ├─ models/            ← TpUser, Product, Order, ... (hand-written fromJson)
   └─ widgets/           ← Blob3D, ClayCard, PuffyButton, ...

assets/
├─ images/   logoapp.png · logoapp_foreground.png · logoapp_splash.png
├─ icons/    (small SVG/PNG icons)
├─ sfx/      startup_16bit.wav
├─ ai/       Gemma model manifests
└─ tts/      Piper voice manifest

android/  ios/  test/
backend-patches/   ← Laravel diff (mirrors xjanova/Thaiprompt-Affiliate PR #2534)
```

---

## ✅ การเทส

```bash
flutter test                # 16+ unit tests (sanitizer, PIN, geohash, ...)
flutter analyze             # static analysis (info-level only เป็น OK)
```

PR ใหม่ต้องผ่าน `flutter analyze` (zero new warnings) + ทดสอบ manual smoke ใน emulator (golden path: splash → onboarding → home → product → cart).

---

## 📝 สิ่งที่เปลี่ยนล่าสุด

ดูทั้งหมดที่ [`CHANGELOG.md`](CHANGELOG.md). v1.0.2 ปัจจุบัน:

- 🎨 ไอคอนแอพใหม่ (Android adaptive + iOS) จาก `logoapp.png`
- 🎬 Splash screen เคลื่อนไหวสวยๆ + เสียง 16-bit chiptune ตอนเปิดแอพ
- 📄 README + CHANGELOG เขียนใหม่หมด

---

## License

Proprietary © 2026 Thaiprompt. All rights reserved.

---

<div align="center">

Made with 💛 in Bangkok · ทำจากใจที่กรุงเทพฯ

</div>
