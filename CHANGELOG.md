# Changelog

All notable changes to the Thaiprompt app.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.7] - 2026-04-19

### แก้ — fix สมัครสมาชิกแสดง "ไม่มีสัญญาณอินเทอร์เน็ต" (server-side, no app update needed)
- รากเหง้า: `.htaccess` ของ bare-domain ใช้ `[R=301,L]` · client (Dio + curl + browser) downgrade `POST` → `GET` ตาม legacy HTTP/1.1 → endpoint `/v1/register` คืน `405 Method Not Allowed` → app catch-all map เป็น `NetworkException("ไม่มีสัญญาณ...")`
- แก้: เปลี่ยนเป็น `[R=308,L]` (Permanent Redirect ที่รักษา method) · POST/PUT/DELETE ส่ง body ครบผ่าน redirect → register ใช้งานได้ทันทีในแอพ v1.0.5 ที่ติดตั้งอยู่แล้ว
- เปลี่ยนผ่าน Server Logs tinker (backup `.htaccess.bak.20260419_194942`)

### แก้ — v1.0.6 build fail (`splits.abi` ขัดกับ Flutter auto-injected `ndk.abiFilters`)
- v1.0.6 ใช้แค่ `splits.abi` แต่ Flutter Gradle plugin auto-inject `ndk.abiFilters = [armeabi-v7a, arm64-v8a, x86_64]` → conflict → build fail
- v1.0.7 set ทั้ง `defaultConfig.ndk.abiFilters.clear() + add("arm64-v8a")` AND `splits.abi { include("arm64-v8a") }` ให้ตรงกัน · ไม่ขัดกัน + AAR libs ทั้งหลายถูก strip → คาด APK ~180 MB

### Backend
- `HANDOVER.md` updated · บอก lesson 308 vs 301 ครบ

## [1.0.6] - 2026-04-19

### แก้ — APK ยังใหญ่อยู่หลัง v1.0.5 (350 MB) เพราะ filter ผิดที่
- v1.0.5 ใส่ `defaultConfig.ndk.abiFilters = ["arm64-v8a"]` แต่ filter ตัวนี้ **กรองเฉพาะ NDK code ที่เรา compile เอง** ไม่ได้กรอง AAR native libs ของ third-party (flutter_gemma, sherpa_onnx, mobile_scanner ที่บวมจริง)
- ผล: APK ยังคงรวม `.so` ของ `armeabi-v7a` + `x86_64` ไปด้วย ขนาดเลย 350 MB
- v1.0.6 ย้ายไปใช้ `splits.abi { reset(); include("arm64-v8a"); isUniversalApk = false }` ซึ่งทำงานตอน packaging — กรอง AAR libs ทั้งหมด · คาดผล ~180 MB
- workflow รับชื่อไฟล์ output ทั้งสองแบบ (`app-arm64-v8a-release.apk` ใหม่ + `app-release.apk` เดิม) เผื่อกลับไปใช้ fat APK ในอนาคต

### หมายเหตุ
- ขนาดจริงจะเห็นหลัง CI v1.0.6 build เสร็จ — ถ้ายังเกิน 200 MB ต้อง drill ลงไปที่ AAR ของ flutter_gemma เพิ่ม

## [1.0.5] - 2026-04-19

### เปลี่ยน — APK ขนาดเล็กลง ~50%
- **APK เหลือ arm64-v8a เพียงอย่างเดียว** · ขนาดจาก ~370 MB (universal) → คาด ~180 MB
- `android/app/build.gradle.kts`: เพิ่ม `ndk.abiFilters = ["arm64-v8a"]` ใน `defaultConfig` · ตัด armeabi-v7a (มือถือเก่า 32-bit ปี 2016 ลงไป) + x86_64 (emulator only)
- เหตุผล: native libs จาก `flutter_gemma` (MediaPipe ~90 MB/ABI) + `sherpa_onnx` (~40 MB/ABI) + `mobile_scanner` คือตัวบวมหลัก · 1 ABI ก็เพียงพอสำหรับ minSdk 24 (Android 7.0+)
- ผลกระทบ: เครื่อง 32-bit ที่อายุ ≥ 9 ปี จะติดตั้งไม่ได้ — ในไทยปี 2026 น้อยมาก

### เปลี่ยน — Release pipeline ผอมลง
- `.github/workflows/release.yml`: เลิก build AAB, เลิก split-per-abi, เหลือ `flutter build apk --target-platform=android-arm64` ตัวเดียว
- ผลผลิต: `thaipromptapp-X.Y.Z.apk` (1 ไฟล์) + `SHA256SUMS.txt` แทน 5 ไฟล์เดิม
- CI/CD เร็วขึ้น ~50% (จาก ~15 นาที → ~7-8 นาที)

### Backend
- `App\Services\AppReleaseSync::findApkAsset` รองรับ asset naming ใหม่ (`thaipromptapp-X.Y.Z.apk`) แล้วยังดึงรุ่นเก่า (universal/arm64-v8a/aab) ได้ — backward compatible · auto-update flow ไม่แตก

### หมายเหตุ
- ถ้าวันหลังต้องการ support arm32/x86: ใส่กลับใน `abiFilters` ของ `build.gradle.kts` ได้เลย (1 บรรทัด)
- AAB ต้องใช้เมื่อขึ้น Play Store เท่านั้น · เมื่อพร้อมเปิดบน Play Store จะกลับมาเปิด build AAB ใน workflow

## [1.0.4] - 2026-04-19

### เพิ่ม — ตลาดสดไทยพร๊อม (Fresh Market)
- **เปิด "ตลาดสด" ในแอพ** · เชื่อมตรงกับ backend `/api/v1/fresh-market/*` (มาจาก `App\Http\Controllers\Api\V1\FreshMarketApiController`)
- **5 หน้าจอใหม่**:
  - `TaladsodHomePage` (`/taladsod`) · hero leaf-green + categories strip + grid สินค้าใหม่ล่าสุด
  - `TaladsodListingsPage` (`/taladsod/listings`) · ค้นหา (debounce 350ms) + filter (sort: ใหม่/ราคาต่ำ/ราคาสูง/ขายดี · ออร์แกนิก) + infinite scroll pagination + filter chip ลบ category ได้
  - `TaladsodListingDetailPage` (`/taladsod/listings/:id`) · image carousel + chips (ออร์แกนิก/ความสด/ระยะทาง/cashback) + seller card + รายละเอียด + related listings strip + sticky bottom CTA
  - `TaladsodSellerPage` (`/taladsod/sellers/:id`) · profile header (ชื่อร้าน/rating/รีวิว/verified) + grid สินค้าในร้าน
  - `TaladsodMyOrdersPage` (`/taladsod/orders`) · ประวัติออเดอร์พร้อม status pill + cashback + refresh
- **`OrderSheet`** modal · qty stepper · 3 delivery types (รับเอง/ไรเดอร์/ขนส่ง) · 4 payment methods (Wallet/COD/โอน/Escrow) · ที่อยู่จัดส่ง · subtotal สด · POST `/v1/fresh-market/orders` พร้อม error inline
- **Entry point** ที่ HomePage หลัก (`/home`) · hero card "ตลาดสดไทยพร๊อม 🥬" สีเขียวคลายมอร์ฟ tap แล้วไป `/taladsod`
- **`ListingCard`** widget reusable · ใช้ทั้งใน home grid, listings list, seller listings, related strip · แสดง organic + discount + distance + stock + shop name

### ภายใน
- `lib/shared/models/fresh_market.dart` — 8 hand-written models (TmCategory, TmSellerMini, TmSeller, TmListing, TmListingDetail, TmRelatedListing, TmPaginatedListings, TmOrderSummary, TmOrderListItem) + 2 enums (TmDeliveryType, TmPaymentMethod) + status label mapper
- `lib/features/fresh_market/fresh_market_repository.dart` — buyer-side endpoints wrapped (categories, listings paginated, nearby, listingDetail, seller, placeOrder, myOrders) · 2 default Riverpod providers (`fmCategoriesProvider`, `fmRecentListingsProvider`)
- `lib/core/utils/format.dart` (ใหม่) — `formatBaht(value, decimals: ...)` + `formatDistance(km)` shared helpers
- `lib/core/api/endpoints.dart` — เพิ่ม 7 fresh-market endpoint constants (`fmCategories`, `fmListings`, `fmListing(id)`, `fmNearby`, `fmSeller(id)`, `fmOrders`, `fmOrder(id)`)
- `lib/app/router.dart` — เพิ่ม 5 routes สำหรับ taladsod (รวม query parameter `?category=ID`)

### Backend
- รัน `php artisan db:seed --class=FreshMarketSeeder --force` บน production แล้ว · มีข้อมูลตัวอย่างให้แอพแสดง

### หมายเหตุ
- Phase นี้ครอบคลุม **buyer-side** เท่านั้น · seller dashboard + rider GPS ยังไม่อยู่ในแอพ (ใช้ผ่าน LINE bot ตามเดิม) · จะมาในรอบหน้า
- ออเดอร์ที่สำเร็จจะ navigate ไปหน้า "ออเดอร์ตลาดสด" ของ user · ยังไม่มี order detail screen แยก (พอข้อมูลพร้อมแล้วค่อยทำ)

## [1.0.3] - 2026-04-19

### เพิ่ม — เชื่อมต่อ production backend
- **API base URL** ชี้ไป `https://thaiprompt.online/api` (production) แทน `staging.thaiprompt.app` (โดเมนเก่าไม่มีจริง)
- Dio follows redirect อัตโนมัติ → `main.thaiprompt.online` (canonical)
- ยังคง override ได้ผ่าน `--dart-define=API_BASE_URL=...` สำหรับ dev/staging builds

### ภายใน — backend handshake
- Backend PR [#2534](https://github.com/xjanova/Thaiprompt-Affiliate/pull/2534) merged แล้ว · เปิดให้ใช้ endpoints:
  - `GET /v1/app/config` (ETag cached) · `GET /v1/app/flags` · `GET /v1/app/menus` · `/sliders` · `/promotions` · `/latest-version`
  - `POST /v1/events/batch` (auth · 60/min) · `POST /v1/ai/chat` (auth · 20/min) · `POST /v1/ai/tts` (auth · 20/min)
- ก่อนหน้านี้ทั้งหมด 404 → ตอนนี้ live (deploy auto-triggered จากการ merge)

### หมายเหตุ
- Cloudflare Page Rule เก่าทำ 301 จาก `thaiprompt.online` ไป `main.thaiprompt.online` แต่หาย `/` (`http://main.thaiprompt.onlineapi/...`)
- แก้ใน CF dashboard 1 บรรทัด (เปลี่ยน destination จาก `http://main.thaiprompt.online$1` → `https://main.thaiprompt.online/$1`) ดูคู่มือเต็มที่ [`Thaiprompt-Affiliate/HANDOVER.md`](https://github.com/xjanova/Thaiprompt-Affiliate/blob/claude/Main/HANDOVER.md)
- Backend repo มี defensive `RewriteRule` ใน `public/.htaccess` เป็น safety net เผื่อ CF rule ถูก remove

## [1.0.2] - 2026-04-19

### เพิ่ม — แบรนดิ้ง + อัตลักษณ์แอพ
- **ไอคอนแอพใหม่** · ใช้โลโก้ `logoapp.png` (ตะกร้าทอง + ดอกบัว + ลายไทย พื้น navy) เป็น launcher icon บน Android (mipmap ทุกความหนาแน่น) และ iOS (`AppIcon.appiconset` ครบทุกขนาด)
- **Adaptive icon** สำหรับ Android 8+ (mipmap-anydpi-v26) · พื้น `#0E2A4F` + foreground เฉพาะตัวโลโก้ ไม่บีบ ไม่ครอป
- **Native splash screen** สำหรับ Android 12+ (`values-v31/styles.xml`) และ Android เก่า (`drawable/launch_background.xml`) + iOS (`LaunchImage.imageset`) · พื้นสีเดียวกับโลโก้ (navy `#0E2A4F`)
- **Animated splash** ก่อนเข้าแอพ · โลโก้ซูม + เด้ง + กลิทเตอร์ทอง + วงแหวนทองพัลส์ + sheen sweep + ไตเติ้ล "ThaiPromptAPP" gradient ทอง + dot loader
- **เสียงเปิดแอพ 16-bit chiptune** · arpeggio C5→E5→G5→C6 พร้อม shimmer tail (square + triangle wave) สังเคราะห์เป็น WAV mono 44.1kHz · ความยาว ~1 วินาที · เล่นพร้อม haptic light impact

### ภายใน
- เพิ่ม `flutter_launcher_icons ^0.14.4` + `flutter_native_splash ^2.4.6` ใน dev_dependencies (regenerate ด้วย `dart run flutter_launcher_icons` + `dart run flutter_native_splash:create`)
- เพิ่ม `splashGateProvider` (StateProvider<bool>) · ปิดทางให้ router redirect ขณะ animation ยังเล่นอยู่ · เปิดเองเมื่อ animation จบ (~2.3s)
- ย้าย `logoapp.png` → `assets/images/logoapp.png` + เพิ่ม `assets/sfx/startup_16bit.wav`
- README.md เขียนใหม่ทั้งฉบับ · มีไอคอนเด่น · บัตจ shields.io · TOC · architecture · feature matrix · screenshots placeholder

### หมายเหตุ
- เสียงเปิดแอพเล่นแค่ตอน cold start (ครั้งแรกของ process) · ไม่เล่นซ้ำเมื่อ background→foreground
- ถ้าอุปกรณ์ปิดเสียง / silent mode · จะข้าม `play()` แบบเงียบ · ไม่ blocking boot

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

[Unreleased]: https://github.com/xjanova/thaipromptapp/compare/v1.0.7...HEAD
[1.0.7]: https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.7
[1.0.6]: https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.6
[1.0.5]: https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.5
[1.0.4]: https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.4
[1.0.3]: https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.3
[1.0.2]: https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.2
[1.0.1]: https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.1
[1.0.0]: https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.0
