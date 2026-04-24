# Changelog

All notable changes to the Thaiprompt app.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.24] - 2026-04-24

### 🎨 All 23 remaining scaffold screens now have real UI — design handoff complete

User request: "นำเข้าให้ครบ" — every stub from v1.0.22 scaffold is now a real screen matching the Claude Design reference (`design/design_handoff_thaiprompt_marketplace/*.jsx`).

### Rider (5 screens · onDark shell · mango accent)

| Screen | What shipped |
|---|---|
| `/rider` | Mini-map (dashed route + 3 waypoints via CustomPainter), 3 mini-stats, active job card with stop timeline + navigate/deliver actions, upcoming-jobs list |
| `/rider/jobs` | 3 filter chips + 5 job rows (distance badge, route, ETA, pay, tag) |
| `/rider/jobs/:id` | Mango income card with tip breakdown, pickup + dropoff cards with phone/nav action buttons, accept/reject row |
| `/rider/earnings` | Pink→mango week-income hero with 7-bar chart, 4 mini metrics, recent trips history |
| `/rider/profile` | Purple→pink gradient rider card, 4 achievement badges, 6-item menu |

### MLM (4 screens · onDark shell)

| Screen | What shipped |
|---|---|
| `/mlm` | Greeting header, rainbow rank card (mango→pink→purple) with progress bar, 2 stat boxes, 4 quick-action tiles, team activity list |
| `/mlm/tree` | 3-state filter chips, "YOU" center node, 3 downlines with L3 sub-expansion |
| `/mlm/earnings` | Purple→pink total hero + withdraw/history actions, 4 level breakdown boxes, commission log |
| `/mlm/invite` | Mango→tomato invite-code card with `CustomPainter` faux QR, 4 share buttons (LINE/FB/IG/Copy), 3 reward tiers |

### Seller (7 screens)

| Screen | What shipped |
|---|---|
| `/seller/orders` | 4 tab pills (horizontal scroll) + 5 order rows with customer + status chip |
| `/seller/orders/:id` | Pink "new order" header with accept/reject actions, customer card, items breakdown with platform commission, payment-method card |
| `/seller/products` | Search row + add button, 2-col product grid with image, stock indicator, enable pill, out-of-stock overlay |
| `/seller/products/:id` | 3 image slots + "หลัก" tag, name/desc/price/stock fields, 4-category picker chips, enable-switch card, delete+save bottom actions |
| `/seller/promos` | Pink→purple summary hero, 3 promo rows with toggle, "create new" ink CTA |
| `/seller/reports` | 2 stat cards (this-month revenue + orders), 6-month line chart via `CustomPainter` with gradient fill, top-selling products list |
| `/seller/withdraw` | Mint→purple balance card, bank card, amount card with 4 quick-pick chips, big withdraw CTA, recent-withdrawals history |

### Buyer (7 screens)

| Screen | What shipped |
|---|---|
| `/buyer/orders` | 4 tab pills + 4 order cards with emoji icon, status pill, price |
| `/buyer/profile` | Purple→pink→mango gradient top, profile card (overlap pattern with 3D avatar), 3-stat row, 7-item menu routing to orders/seller/rider/mlm/addresses/coupons/help |
| `/buyer/addresses` | 3 address cards with `ค่าเริ่มต้น` pill, add-address CTA |
| `/buyer/coupons` | 3 side-by-side coupons (colored left + details right with "ใช้เลย" button) |
| `/buyer/notifications` | 4 notification rows with unread dot indicator for the top 2 |
| `/buyer/review/:id` | Order header card, star rating (1-5) with label, 6 taggable chips, comment textarea, submit CTA |
| `/buyer/checkout/receipt/:id` | Rainbow-bar receipt with brand logo + REF, dashed-border item section, totals, black-bg ยอดชำระ highlight, 2 payment/shop meta cards, `CustomPainter` barcode + download/email actions |

### Cleanup
- Removed unused imports in `mlm_pages.dart` + `checkout_pages.dart`
- Added `Orders`, `Profile`, `Coupons`, `Addresses` properly wired in existing router

### Files
- `~ lib/features/rider/rider_pages.dart` (~900 lines, 5 pages + CustomPainter route map)
- `~ lib/features/mlm/mlm_pages.dart` (~900 lines, 4 pages + invite QR painter)
- `~ lib/features/seller/seller_pages.dart` (~1100 lines, 8 pages + 6-month line chart painter)
- `~ lib/features/orders/orders_pages.dart` (full rewrite)
- `~ lib/features/profile/profile_pages.dart` (full rewrite, 3 pages)
- `~ lib/features/notifications/notifications_page.dart` (full rewrite)
- `~ lib/features/review/review_page.dart` (full rewrite with star + tag + textarea)
- `~ lib/features/checkout/checkout_pages.dart` (receipt page real + barcode painter)
- `~ pubspec.yaml` 1.0.23+24 → 1.0.24+25

Flutter analyze: 0 errors · 3 info/warning (1 unused-import fixed, 2 deprecated `activeColor` on Switch — still works, awaiting Flutter SDK migration).

**Design handoff v2 coverage: 100%.** Every screen listed in `design_handoff_thaiprompt_marketplace/README.md` is now implemented. Further work focuses on wiring real backend data (product lists from `/v1/products`, orders from `/v1/orders`, etc.) to replace the static stubs used this session.

## [1.0.23] - 2026-04-24

### 🎨 Real UI for 6 scaffolded screens — Search / Categories / Checkout (4) / Seller Dashboard

Continuing v1.0.22 design handoff. 6 screens now have production UI matching the design reference pixel-close:

### `/buyer/search` — Search page
- Mango top bar + white search field + back button
- "ยอดนิยม" hot searches (pink fill for top 2 trending · white fill for rest)
- "ค้นล่าสุด" recent queries with history icon + tap-to-refill
- Autofocus TextField with search-intent keyboard

### `/buyer/categories` — Categories grid
- 2-column grid · 8 color-coded category tiles
- Emoji icon + Thai name + shop count
- Mango tile auto-switches to ink text for contrast; all other colors use white
- Back button in header

### `/buyer/checkout/address` — Step 1/4 Address picker
- 4-step progress indicator (numbered/check-mark, pink when active/done)
- 3 saved address cards with emoji-colored tile + ETA pill + selected-state outline
- "+ เพิ่มที่อยู่ใหม่" ghost button
- Bottom-sheet CTA "ถัดไป · เลือกวิธีจ่าย →"

### `/buyer/checkout/payment` — Step 2/4 Payment method
- 5 payment methods (PromptPay QR, Wallet, Credit card, TrueMoney, COD) with accent tiles + "แนะนำ/เร็วสุด" tags
- Selected-state 3px pink outline
- Coupon input row
- Order summary (subtotal · shipping · discount · total pink)
- Bottom CTA "จ่าย ฿170 →" routes to QR (PromptPay) or Paid (other methods)

### `/buyer/checkout/qr` — Step 3/4 PromptPay QR
- Purple-gradient QR card (white → light-purple)
- Faux-QR `CustomPainter` rendering 14×14 module grid + pink ฿ center badge
- ฿170.00 display + REF mono + 1-second live countdown
- Countdown pill turns pink under 60s
- Bottom CTA "ชำระแล้ว · ตรวจสอบ →"

### `/buyer/checkout/paid` — Step 4/4 Success
- Mint→mango gradient background
- Check icon 110px white circle with elastic scale-in animation (600ms)
- "PAYMENT SUCCESS" mono + "ชำระเงินสำเร็จ" display + order ref line
- Prepare-status card with blur-backdrop background
- Two actions: ใบเสร็จ (ghost) · ติดตามออเดอร์ → (pink)

### `/seller` — Seller Dashboard (real)
- Shop header: mango→tomato gradient, shop logo+rating, open/closed toggle
- 2-column stats: revenue today (฿3,820, ↑18%) · pending orders (7, ⚡2 ด่วน)
- 8-hour sales bar chart (highlight current hour in pink, rest mango gradient)
- 4 quick actions: เพิ่มสินค้า · โปรโมชัน · แชท · ถอน
- New orders list with status chips + pricing + tap-to-detail

### Files
- `~ lib/features/home/search_page.dart` (stub → full UI, ~260 lines)
- `~ lib/features/home/categories_page.dart` (stub → full UI, ~150 lines)
- `~ lib/features/checkout/checkout_pages.dart` (stub → 5 real pages, ~700 lines)
- `~ lib/features/seller/seller_pages.dart` (stub → Dashboard real, rest stubs, ~500 lines)
- `~ pubspec.yaml` 1.0.22+23 → 1.0.23+24

Flutter analyze: 0 errors on new files · 1 info fixed in search_page.dart.

## [1.0.22] - 2026-04-24

### 🎨 Design handoff v2 scaffold — 5 roles, 40+ screens, claymorphism system

User request: "Thaiprompt.zip เป็น design ที่เราต้องยึดตามแบบ โปรดนำมาใช้ในแอพให้ครบ"

**Source**: `design/design_handoff_thaiprompt_marketplace/` (extracted from `Thaiprompt.zip` · Apr 24) — hi-fi HTML/JSX prototype from Claude Design covering Buyer/Seller/Rider/MLM/Admin roles.

### 🆕 Shared primitives

- **`lib/shared/widgets/app_tab_bar.dart`** — dark floating pill bar per design spec
  - Active tab: expanding pill with accent fill + icon + label · spring `cubic-bezier(.5, 1.4, .5, 1)` 280ms
  - Inactive tabs: 46×46 icon-only squares at `rgba(255,255,255,.78)`
  - Per-role `RoleTabs` presets: `buyer`, `seller`, `rider`, `mlm`
  - `onDark` flag for dark-background roles (Rider/MLM)
  - Badge support (pink 14px, 2px ink-color border-box separator)
- **`lib/shared/widgets/under_construction_page.dart`** — canonical stub page for v1.0.22 scaffold

### 🆕 Mode Select (`/mode`)

- New `features/onboarding/mode_select_page.dart` — post-login role picker
- 3 stacked mode cards (Buyer pink→tomato · Seller mango→tomato · Rider ink→purple)
- Remote ad banner (dismissible, 3-dot indicator)
- MLM quick-link
- Persists `last_mode` to SharedPreferences

### 🆕 Feature scaffolds (routes live, UI stubs)

- **`features/seller/`** (NEW) · `SellerShell` + 8 pages: dashboard, orders, order detail, products, product edit, promos, reports, withdraw
- **`features/rider/`** (NEW) · `RiderShell` (onDark) + 5 pages: dashboard, jobs, job detail, earnings, profile
- **`features/mlm/`** (NEW) · `MlmShell` (onDark) + 4 pages: dashboard, tree, earnings, invite
- **`features/checkout/`** (NEW) · 5-step flow: address → payment → QR → paid → receipt
- **`features/orders/`** (NEW) · consolidated buyer orders inbox
- **`features/review/`** (NEW) · order review page
- **`features/notifications/`** (NEW)
- **`features/profile/`** (NEW) · profile + address book + coupons
- **`features/home/search_page.dart`**, **`categories_page.dart`** (NEW)

### 🔀 Router overhaul

- `/mode` routes to Mode Select
- `/buyer/*` — new shell prefix for existing Home/Search/Categories/Orders/Product/Shop/Profile/etc.
- `/seller/*` — ShellRoute with Seller tab bar
- `/rider/*` — ShellRoute with Rider tab bar (onDark)
- `/mlm/*` — ShellRoute with MLM tab bar (onDark)
- Legacy routes (`/home`, `/product/:id`, `/shop/:id`) redirect to new paths — no deep-link breakage
- Post-login redirect: `/splash` → `/mode` (was `/home`)
- Guest-allowed list updated to include `/buyer*` paths

### Next sessions (roadmap)

1. Flesh out Buyer Home with new top bar + banner carousel + sections (`screens-a.jsx` reference)
2. Seller Dashboard (revenue card + 8-bar chart + 3 today-orders)
3. Rider Job Queue + active job map
4. MLM Tree visualization
5. Checkout step UIs (address form → payment method → PromptPay QR → paid confetti → receipt)
6. Buyer Search UI (hot tags + recent)
7. Buyer Categories grid
8. Profile + Address Book + Coupons
9. Review flow
10. Notifications inbox

### Files

- `+ lib/shared/widgets/app_tab_bar.dart` (300+ lines)
- `+ lib/shared/widgets/under_construction_page.dart`
- `+ lib/features/onboarding/mode_select_page.dart` (~400 lines)
- `+ lib/features/{seller,rider,mlm}/*_shell.dart` + `*_pages.dart`
- `+ lib/features/{checkout,orders,review,notifications,profile}/*`
- `+ lib/features/home/{search,categories}_page.dart`
- `~ lib/app/router.dart` — ShellRoute restructure + 30+ new routes
- `+ design/design_handoff_thaiprompt_marketplace/` — extracted design reference
- `~ pubspec.yaml` 1.0.21+22 → 1.0.22+23

Flutter analyze: 0 errors · 123 info-only (pre-existing style nits).

## [1.0.21] - 2026-04-21

### 🎛️ Thaiapp-MANAGER — ศูนย์ควบคุมแอปฝั่งเว็บแอดมิน

User request: "ทำ Thaiapp-MANAGER เป็นหน้า admin เดียวที่คุมทุกอย่างที่แอปดึงมา · persona, TTS, keys, โมเดล Gemma, banners, sliders, menus, config, releases"

### Backend — admin hub ใหม่ที่ `/admin/thaiapp`

**Live on prod** (gated by `auth` + `role:admin,super_admin`):

| Route | จัดการอะไร |
|---|---|
| `/admin/thaiapp` | ภาพรวม · cards + stats |
| `/admin/thaiapp/nong-ying` | แก้ persona + TTS config (`ai_bot_profiles[id=4]`) |
| `/admin/thaiapp/ai-pool` | CRUD `ai_api_keys` (Gemini/Groq/Grok/Qwen/OpenRouter/DeepSeek/Typhoon) |
| `/admin/thaiapp/ai-models` | ปุ่ม Sync Gemma .task จาก HF (E2B 2GB / E4B 3GB) |
| `/admin/thaiapp/banners` | CRUD `app_banners` |
| `/admin/thaiapp/sliders` | CRUD `app_sliders` |
| `/admin/thaiapp/menus` | CRUD `app_menus` |
| `/admin/thaiapp/config` | key-value `app_configs` (env-scoped: production vs staging) |
| `/admin/thaiapp/releases` | ประวัติรุ่น (read-only) |

### เพิ่มลิงก์ใน sidebar-v3

- Pinnable-menu-group ใหม่ "📱 Thaiapp · แอป" ใส่หลัง Users/Roles group
- 9 submenus ชี้ไปหน้า hub ทั้งหมด
- ไอคอน `fas fa-mobile-screen`

### Files (ฝั่ง backend repo `xjanova/Thaiprompt-Affiliate`, commit `a44c54aea`)

- `app/Http/Controllers/Admin/ThaiappManagerController.php` (454 บรรทัด · 9 pages + 20+ CRUD methods)
- `resources/views/admin/thaiapp/{hub,nong-ying,ai-pool,ai-models,banners,sliders,menus,config,releases,_card,_flash}.blade.php` (11 ไฟล์)
- `routes/web.php` · +42 บรรทัด FQCN route group
- `resources/views/components/arrow-x/sidebar-v3.blade.php` · +29 บรรทัด menu group

### บทเรียนจาก v1.0.21 รอบแรก (ล่ม/กู้)

- **Trap**: `use App\...\Foo as Bar;` ข้างใน `Route::group(function () {})` closure = invalid PHP · ทำเว็บ 500 ทุก route
- **Rule**: FQCN (`\App\Http\Controllers\Admin\ThaiappManagerController::class`) ในทุก route · อย่าใช้ `use as` ใน closure
- **Recovery**: ถ้า `routes/web.php` มี syntax error · `php artisan` boot ไม่ขึ้น · ต้องใช้ Server Maintenance workflow → `custom-command` → raw bash (`sed -i '\|MARKER|,\|END|d'`)
- **Deploy path**: prod auto-syncs จาก `origin/claude/Main` (CI → deploy.yml → SSH → `deploy.sh claude/Main`) · edit บน prod ผ่าน tinker โดยไม่ push จะโดน `git reset --hard` ในรอบ deploy ถัดไป

### App-side (Flutter) — ไม่มีการเปลี่ยนแปลง

แอปยังเรียก endpoints เดิมจาก v1.0.20: `/api/v1/app/config`, `/ai/nong-ying/persona`, `/ai/nong-ying/knowledge?q=`, `/ai/chat`, `/ai/tts`, `/ai/models/{tier}`. Thaiapp-MANAGER แค่ให้แอดมินแก้ข้อมูลต้นทางผ่าน web UI แทน tinker/SQL ตรง

## [1.0.20] - 2026-04-20

### 🧠 Persona + knowledge ย้ายจากแอพ → server (admin แก้ได้ที่เดียว)

User request: "สไตล์การตอบบุคลิกต่าง ๆ ของน้องหญิงให้ควบคุมได้ในส่วนควบคุมแอพ · แอพดึงบุคลิกไปจากส่วนควบคุม · รวมถึง knowledge ต่าง ๆ · เพราะการที่น้องหญิงจะรู้ว่ามีอะไรในแอพต้องค้นหาจากเว็บ thaiprompt"

### Backend — 2 endpoints ใหม่

**`GET /api/v1/ai/nong-ying/persona`** (public · ETag-cacheable · 60/min/IP)
- ดึงจาก `ai_bot_profiles[id=4]` (ที่ seed ไว้ v1.0.18)
- Returns: `system_prompt`, `greeting`, `greeting_not_installed`, `suggestions[]`, `temperature`, `top_p`, `max_tokens`, `tts{...}`, `version` (updated_at timestamp)
- **Admin แก้ persona ใน DB → user รายใหม่เห็นทันที** (ETag invalidate client cache)
- Live test: HTTP 200 · ETag present · system_prompt 2469 chars · 4 suggestions

**`GET /api/v1/ai/nong-ying/knowledge?q=...&limit=5`** (public · 30/min/IP)
- ค้นหา 3 tables: `products` (93 rows live) + `fresh_market_categories` (8 rows) + `product_categories` (16 rows)
- Returns: ไทย array with `type`, `id`, `title`, `subtitle`, `route` (deep-link path)
- Live test: `q=ผัก` → ได้ taladsod category "ผักสด" พร้อม `/taladsod/listings?category=1`

### Backend — chat auto-RAG
- `V1/AiChatApiController::chat()` · เพิ่ม `retrieveKnowledge()` ก่อนเรียก LLM
- Query products + taladsod categories ด้วย user's message · inject top-3 ใน system prompt เป็น "ข้อมูลที่เกี่ยวข้องในแอพ (ใช้ตอบได้ · อย่าประดิษฐ์)"
- LLM อ้างชื่อ + ราคาจริง + emit `[GO:/path]` chip ที่ link เข้าหน้าถูก
- Live test: user ถาม "อยากได้ผักสดค่ะ แนะนำหน่อย" → Gemini ตอบ "ผักสดๆ น่าทานเลยค่ะ! น้องหญิงพาไปดูผักที่ตลาดสดนะคะ [GO:/taladsod/listings?category=1]" ✓

### Backend — tts_config JSON column (admin-controlled voice/temperature)
- `ALTER TABLE ai_bot_profiles ADD COLUMN tts_config JSON` · seed default config:
  ```json
  {"voice":"th-premwadee","voices_available":["th-premwadee","th-achara"],
   "temperature":0.8,"cloud_model":"gemini-2.5-flash-preview-tts",
   "fallback":{"engine":"piper","voice_id":"th_TH-vaja-medium","auto_install":false}}
  ```
- Persona endpoint ส่ง `tts_config` ติดไปกับ response
- Admin แก้ใน DB → app refresh persona → voice เปลี่ยนทันที

### App — `NongYingPersonaProvider` (fetch + SQLite cache + ETag)
- [lib/core/ai/nong_ying_persona.dart](lib/core/ai/nong_ying_persona.dart) · `AsyncNotifierProvider<NongYingPersonaController, NongYingPersona>`
- Cache ใน `KvStore` keys: `tp.ai.persona` (JSON) + `tp.ai.persona_etag`
- Strategy: cold-start return cached/fallback · refresh in background · update state เมื่อ version เปลี่ยน
- Offline-safe fallback: hardcoded persona terse สำหรับ emergency cold-start

### App — chat page ใช้ persona จาก provider (drop embedded)
- Greeting + greetingNotInstalled + suggestions อ่านจาก `nongYingPersonaProvider`
- `NongYingService.ask()` รับ `systemPrompt` parameter · chat page ส่ง `persona.systemPrompt` · ใช้ทั้ง on-device Gemma และ cloud
- Embedded `NongYingPrompts.{systemPrompt, greeting, greetingNotInstalled, suggestions}` ยังคงอยู่เป็น fallback ถ้า API fail

### App — GeminiTtsService อ่าน voice/temperature จาก persona
- `applyConfig(voice: String?, temperature: double?)` · ส่งค่าเข้า POST `/v1/ai/tts`
- `ttsServiceProvider` listen `nongYingPersonaProvider` · auto-apply เมื่อ refresh
- Admin เปลี่ยน voice "th-premwadee" → "th-achara" ใน DB · app ใหม่ได้เสียงใหม่โดยไม่ต้อง redeploy

### 🎤 Embedded voice fallback · Piper VAJA (ที่ทางเลือกฟรีดีสุดที่เราเลือกไว้)
- `th_TH-vaja-medium.onnx` (80 MB · NECTEC VAJA · Apache 2.0)
- Router edge (tts_router.dart) fallback อัตโนมัติเมื่อ Gemini quota หมด
- User ต้อง opt-in ติดตั้งใน Settings ครั้งเดียว (ไม่ bundle APK)
- เปรียบเทียบ options: Piper VAJA (80 MB, Apache 2) > MMS Meta (CC-BY-NC) > XTTS (1.5 GB non-commercial)

## [1.0.19] - 2026-04-20

### 🎤 "ฟังเสียง" ใช้ได้แล้ว (TTS via AI pool)
- Backend `/api/v1/ai/tts` เดิมใช้ `env('GEMINI_API_KEY')` ตรง ๆ + middleware `auth:sanctum` · guest ใช้ไม่ได้ + key หมดก็ stuck
- v1.0.19 rewrite: route เป็น **public** + throttle:10,1 · controller เรียก `NongYingAIService::tts()` ที่ใช้ pool rotation เหมือน chat
  - Loop keys ของ provider `gemini` ใน pool (priority desc + healthy first)
  - 429 → switch ใน 1 วิ · error → 2 วิ · record usage/error กลับ pool
  - Female voices เท่านั้น (`th-premwadee` = warm · `th-achara` = gentle) · enforced server-side
- **Gemini TTS คืน raw PCM s16le @ 24kHz mono** (ไม่ใช่ MP3 ตามที่ mime บอก) → ห่อ 44-byte RIFF WAV header ให้ `just_audio` เล่นได้ทุก platform
- Live verified: `curl POST /v1/ai/tts` · HTTP 200 · audio/wav · 119,610 bytes · "RIFF...WAVE" magic ครบ · keys_tried=1 · 3.9s
- App `GeminiTtsService`: `Accept: audio/*` + `format: wav` · just_audio auto-detect

### หมายเหตุ
- Persona + knowledge base move จาก app → server · ออกแบบไว้แล้ว · จะ ship เป็น v1.0.20 (เปลี่ยนแปลงเยอะ)
- ตอนนี้ยังอ่าน persona จาก embedded `NongYingPrompts.systemPrompt` · cloud chat ใช้ `ai_bot_profiles.system_prompt` (ตรงกันเพราะผม seed ไว้)

## [1.0.18] - 2026-04-20

### 🎯 **Gemma 4 E2B จริง + AI pool (แบบหมอดู) + น้องหญิงพูดได้แล้ว**

ใช้ gemma-3n (nano) รุ่นเก่า/เล็กกว่าที่ผู้ใช้ต้องการ · v1.0.18 รื้อใหม่ทั้งหมด:

### On-device: Gemma 4 ตัวจริง (ไม่ใช่ 3n/nano อีกต่อไป)
- ค้นหาผ่าน Chrome MCP → พบที่ `litert-community/gemma-4-E{2,4}B-it-litert-lm`
- **Gemma 4 E2B** (2 GB) — default สำหรับเครื่อง Android SDK ≥ 29 (Android 10+) · ส่วนใหญ่
- **Gemma 4 E4B** (3 GB) — high-tier สำหรับ Android SDK ≥ 34 (Android 14+ flagship)
- Ungated · ไม่ต้อง accept license · ใช้ HF token แบบ authorization เท่านั้น

### AI pool integration (สำหรับ cloud fallback · แบบเดียวกับหมอดู/ดูดวง)
- **`NongYingAIService`** (ใหม่) — เลียนแบบ `FortuneAIService::generateWithRetryAndFallback`
  - Enumerate ทุก active API keys ใน `AiApiKeyPoolService` (priority desc, healthy first)
  - ลอง keys ไปเรื่อย ๆ · **สลับทันทีเมื่อโดน 429** (รอ 1 วิ) · error อื่น รอ 2 วิ
  - รองรับ 7 providers: Gemini, Groq, Grok, Qwen, OpenRouter, DeepSeek, Typhoon
  - Record usage + errors กลับ pool (cost tracking · rate limit awareness)
- **`AiBotProfile`** (table) เก็บ persona "น้องหญิง"
  - id #4 · provider=google · model=gemini-2.5-flash (new model row #30)
  - system_prompt พร้อม app map + deep-link convention · admin edit DB ได้ไม่ต้อง redeploy
  - `app_configs.nong_ying_bot_profile_id = 4`
- **`V1/AiChatApiController::chat()`** rewrite · ใช้ `NongYingAIService->chat()` · failover pool
- Route `/v1/ai/chat` ทำเป็น public + `throttle:15,1` (per IP) เพื่อให้ guest ใช้ได้
- **Live test**: Gemini 2.5 Flash ตอบใน 2.9s · persona ถูกต้อง (`ค่ะ/หนู` + deep-link chips)

### Server hosting (รองรับ user ขอ: "ให้เว็บโหลด .task มาไว้")
- Sync'd **gemma-4-E2B-it-web.task (2.00 GB)** ไป `public/ai-models/` · 82s download · sha256 verified
- Admin API: `POST /v1/admin/ai/models/{tier}/sync` trigger ดาวน์โหลดจาก HF
- Proxy: `/api/v1/ai/models/{tier}` → **302 redirect ไป Nginx direct** (zero PHP hot path)
- `/info` endpoint รายงาน `source: local` เมื่อ file พร้อม ให้ client รู้ได้
- Verified live: proxy → 302 → Nginx → Content-Length 2,003,697,664 ✓

### App-side rewrite
- `AiEngineKind` enum: drop `gemma4/gemma3_4b/gemma3_1b` · เพิ่ม `gemma4_e2b` + `gemma4_e4b`
- `ModelManager` tier selection: Android SDK ≥ 34 → E4B · SDK ≥ 29 → E2B · else cloud
- Remote config keys: `ai_model_url_gemma4_e{2,4}b` + `ai_model_id_gemma4_e{2,4}b`
- UI labels + size estimates: 2.0 / 3.0 GB

### HF token (server-side เท่านั้น)
- User login HF → สร้าง fine-grained token ผ่าน Chrome MCP → inject ใน server `.env`
- User **ไม่เคยเห็น token** ใน app · proxy จัดการทุกอย่างฝั่ง server
- Permission: "Read access to contents of all public gated repos" · รองรับ Gemma 3 1B ถ้าจำเป็นในอนาคต

### ล้างข้อมูลเก่า
- ลบ `ai_model_url_gemma4`/`gemma3_4b`/`gemma3_1b` + `ai_model_id_*` 6 rows จาก `app_configs`
- Route regex: `gemma4|gemma3_4b|gemma3_1b` → `gemma4_e2b|gemma4_e4b`

## [1.0.17] - 2026-04-20

### Backend — host .task files บน server ของเราเอง (ผ่าน admin API)
User request: "เว็บโหลด Gemma 4 E2B มาไว้เพื่อให้น้องหญิงโหลดจากเว็บเราแทน · เปลี่ยนโมเดลในอนาคตก็ง่ายขึ้น ในส่วนจัดการแอพหลังบ้าน"

### เพิ่ม — `AiModelAdminController.php` (admin-only CRUD)
- Routes: `/api/v1/admin/ai/models/*` · ผ่าน `auth:sanctum` + inline admin check (`role='admin'` or `is_super_admin`)
- `GET /` → list ทั้ง 3 tier · คืน: filename, local size, sha256, modified_at, hf_url, app_config value, `hf_token_set` flag
- `GET /{tier}` → metadata tier เดียว · ใช้ตรวจ sync status
- `POST /{tier}/sync` → ดาวน์โหลด .task จาก HF ลง `public/ai-models/{filename}` · ใช้ `HF_TOKEN` จาก env · อะตอมมิก (`.downloading` → rename) · backup rollback 1 slot
- `DELETE /{tier}` → ลบ local file
- Error surface ชัดเจน: `unauthenticated` / `forbidden` / `unknown_tier` / `server_not_configured` / `upstream_failed`

### เปลี่ยน — `AiModelProxyController` = local-first
- เดิม: proxy HF ทุก request · hot path เข้า PHP + streams 1.2GB ต่อ user ต่อ download · ช้า + กิน worker
- ตอนนี้: ถ้า `public/ai-models/{filename}` มีอยู่ → **302 redirect ไปหา `/ai-models/{filename}` · Nginx serve ตรง ๆ** · zero PHP · byte-range resume ได้เอง
- ถ้าไม่มี local file → fallback stream จาก HF (backward compat · ทำงานได้แม้ admin ยังไม่ sync)
- `/info` endpoint สะท้อน source: `{source: 'local', served_from: '/ai-models/...', modified_at}` หรือ `{source: 'huggingface'}` · client รู้ได้ว่ากำลังโหลดจากที่ไหน

### เพิ่ม — Directory + routes บน production
- `public/ai-models/` · perms 775 · `.gitignore` = `*` (ไม่ commit .task files)
- Route group `v1/admin/ai/models/*` registered · syntax verified · cache cleared ✅
- Verified live: admin endpoint คืน **401 Unauthenticated** ตามที่ตั้งไว้

### ⚠️ Admin actions (ลำดับ)
1. **Set HF_TOKEN** (เช่นเดียวกับ v1.0.16 ยังต้องมีเพื่อ initial sync):
   ```
   echo 'HF_TOKEN=hf_xxx' >> .env && php artisan config:clear
   ```
2. **Sync model** (ครั้งแรก · ผ่าน admin API หรือ Server Logs tinker):
   ```bash
   curl -X POST https://main.thaiprompt.online/api/v1/admin/ai/models/gemma3_4b/sync \
     -H "Authorization: Bearer <admin_sanctum_token>"
   ```
   หรือ tinker: `app(\App\Http\Controllers\Api\AiModelAdminController::class)->sync($req, 'gemma3_4b')`
3. **Verify**: `GET /api/v1/ai/models/gemma3_4b/info` → `source: 'local'` → next user's install จะ 302 ไป Nginx โดยตรง

### อนาคต (roadmap)
- Flutter admin screen · "Sync now" button ต่อ tier · real-time progress · swap model
- Cron job: re-sync ทุกเดือนเผื่อ Google update checkpoint
- Cloudflare CDN layer หน้า `/ai-models/*` (Cache-Control `public, max-age=86400` ถูกส่งอยู่แล้ว)

## [1.0.16] - 2026-04-20

### แก้ — **รากเหง้า** ของ "login แล้วยังต้อง login ใหม่ทุกครั้ง"
- v1.0.13 ย้าย TokenStorage ไป SQLite + secure mirror · token **เขียน** สำเร็จ
- **แต่** bootstrap logic ยังเก่า: `repo.me()` fail ด้วยเหตุผลใดก็ตาม → `catch (_)` → `AuthUnauthenticated` → user ถูก logout
- ผล: network ช้า / server timeout / WiFi ยังไม่ connect ตอน cold start → me() throw → auth wipe · user ต้อง login ใหม่ทั้งที่ token ยังถูกต้อง
- แก้ใน [auth_state.dart](lib/core/auth/auth_state.dart):
  - แยก `UnauthorizedException` (401 จริง → logout) ออกจาก `ApiException` (network/timeout/5xx → **เก็บ auth ไว้**)
  - ถ้า me() fail แบบ transient: set `AuthAuthenticated(TpUser.placeholder())` · user ยัง logged in · retry me() เงียบ ๆ ใน 4 วินาที
  - Token wipe จะเกิดเฉพาะกรณีที่ server ตอบ **401 ด้วยตัวเอง** · network ไม่ดีไม่ wipe
- เพิ่ม `TpUser.placeholder()` factory · id=0 + name="กำลังโหลด..."
- ผล: login ครั้งเดียว → ใช้ได้ยาวจนกว่าจะ logout เองหรือ token หมดอายุ · network ไม่ดีตอนเปิดแอพไม่ทำให้หลุด

### เปลี่ยน — HF Token จัดการฝั่ง server แทน user (ตามที่ user ขอ)
- v1.0.15 ทำ HF token input ใน install page · user งง · ไม่ใช่ UX ที่ดี
- v1.0.16 **ลบ input field ออกทั้งหมด** · user ไม่ต้องเห็น HF ใด ๆ
- Backend `AiModelProxyController.php` (deploy ผ่าน Server Logs แล้ว):
  - `GET /api/v1/ai/models/{tier}` (tier ∈ gemma4/gemma3_4b/gemma3_1b)
  - Stream .task จาก HuggingFace ผ่าน curl · แนบ `Authorization: Bearer $HF_TOKEN` จาก server env
  - รองรับ Range request (resume download บนเน็ตกระตุก)
  - Cache `public, max-age=86400` · CF/Nginx จะ cache อัตโนมัติถ้ามี layer หน้า
  - `/info` endpoint returns file size + upstream status (client can probe before downloading)
- Route registered ใน `routes/api.php` ครอบกลุ่ม `v1/ai/models/*`
- `app_configs.ai_model_url_*` ชี้มาที่ proxy แล้ว:
  - `https://main.thaiprompt.online/api/v1/ai/models/gemma4`
  - `https://main.thaiprompt.online/api/v1/ai/models/gemma3_4b`
  - `https://main.thaiprompt.online/api/v1/ai/models/gemma3_1b`
- Verified live: proxy คืน **503 "server_not_configured"** จนกว่า admin จะใส่ `HF_TOKEN` ใน `.env`

### ⚠️ Admin action required
1. SSH/Server Logs: เพิ่ม `HF_TOKEN=hf_xxxxx` ใน `/home/admin/domains/main.thaiprompt.online/public_html/.env`
2. รัน `php artisan config:clear`
3. Test: `curl -I https://main.thaiprompt.online/api/v1/ai/models/gemma3_1b/info` ควรคืน 200 + JSON มี `size`
4. เมื่อ token ใส่แล้ว · user เปิดแอพ → install → ดาวน์โหลดได้เงียบ ๆ ไม่ต้องกรอกอะไร

## [1.0.15] - 2026-04-20

### Backend — seeded app_configs บน production (ผ่าน Server Logs workflow)
- `ai_model_url_gemma4` = `https://huggingface.co/google/gemma-3n-E4B-it-litert-preview/resolve/main/gemma-3n-E4B-it-int4.task`
- `ai_model_url_gemma3_4b` = `https://huggingface.co/google/gemma-3n-E2B-it-litert-preview/resolve/main/gemma-3n-E2B-it-int4.task`
- `ai_model_url_gemma3_1b` = `https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/Gemma3-1B-IT_multi-prefill-seq_q4_ekv1280.task`
- `ai_enabled` = `1`
- Upsert ผ่าน `gh workflow run "Server Logs"` → tinker base64 · verified via `/v1/app/config`

### แก้ — HF 401 (gated Gemma models) · เพิ่มช่องใส่ HF token
- ทดสอบ URL ที่ seed ไว้: HTTP **401 Unauthorized** ทั้ง 3 ตัว · Gemma บน HuggingFace ถูก gate · ต้อง accept license + ใช้ access token
- Server ยังไม่มี `HF_TOKEN` env var · proxy download ยังไม่พร้อม → ให้ user กรอก token เองไปก่อน
- `install_model_page`:
  - เพิ่มกล่อง "HuggingFace token (ถ้าจำเป็น)" · ช่อง text + ปุ่ม "วาง" + ปุ่มเปิด/ซ่อน
  - 3 ขั้นตอน one-time setup: 1) เปิดหน้าโมเดลขอสิทธิ์ · 2) สร้าง access token · 3) วางในช่อง
  - Token เก็บใน `KvStore` (SQLite) · ครั้งต่อไปไม่ต้องกรอก
  - ปุ่ม deep-link `huggingface.co/settings/tokens` + หน้า model repo (แยกตาม tier)
  - Error 401/403 → แสดงคำแนะนำไทยแบบ step-by-step แทน raw exception
- Settings Gemma card → เปลี่ยนปุ่มจาก "ดาวน์โหลด" inline เป็น "ติดตั้งน้องหญิง" → พาไป `/nong-ying/install` · UX รวมศูนย์ที่เดียว

### หมายเหตุสำหรับ admin
- ถ้าต้องการเอา HF token ออกจาก user flow: ใส่ `HF_TOKEN` ใน server `.env` + สร้าง route `/api/v1/ai/models/{file}` ที่ proxy stream จาก HF + update backend URL ให้ชี้มาที่ proxy · จะ bypass 401 ให้ทุก user โดยอัตโนมัติ · ยังไม่ได้ทำในรอบนี้

## [1.0.14] - 2026-04-20

### แก้ — "โหลดโมเดล Gemma ไม่ได้" (root cause: backend ไม่ตั้ง URL)
- ตรวจ `GET /v1/app/config` live · `ai_model_url_gemma4/3_4b/3_1b` ทั้งหมด = empty string
- เก่า: `planInstall()` return `null` → install page ค้างที่ "กำลังตรวจรุ่น..." ตลอดชีวิต · user งง
- แก้:
  - `ModelInstallPlan` เปลี่ยนเป็น sealed-like shape ที่มี `status`: `ready` / `unavailable` / `unconfigured` · แต่ละ status มี `reason` เฉพาะ
  - Install page แสดงสถานะชัดเจน: loading → ready (ดาวน์โหลดได้) / unavailable (เครื่องเล็ก) / unconfigured (admin ยังไม่ตั้ง URL)
  - Settings Gemma card ตามมาเหมือนกัน · ไม่ซ่อนสถานะอีก
- Backend seeder (`AppConfigSeeder.php`) เติม URL default ให้ครบ 3 tier · admin รัน `php artisan db:seed --class=AppConfigSeeder` แล้วใช้ได้ทันที

### เพิ่ม — น้องหญิง "รู้จักทุกซอกมุมของแอพ"
- ขยาย `NongYingPrompts.systemPrompt` ให้มี **แผนที่แอพ** ครบทุกหน้า + category ids (ผัก/ผลไม้/เนื้อสัตว์/...) ที่น้องพาไปได้
- เปลี่ยนรูปแบบคำตอบ: model emit `[GO:/path]` · แอพแปลงเป็น **ปุ่มกดเปิดหน้า** อัตโนมัติ (chip สีส้มใต้บับเบิ้ล)
- ตัวอย่าง: user ถาม "อยากได้ผักสด" → น้อง "ผักสดมาใหม่ทุกวันเลยค่ะ [GO:/taladsod/listings?category=1] ไปเลือกกันค่ะ" → user กด chip → พาไปหน้านั้นทันที
- `ReplyDeepLink.extract/strip` parse token ออกจาก reply · ไม่ leak `[GO:...]` เข้าไปใน bubble
- Chip ฉลาดเลือก label: `/wallet/topup` → "เติมเงิน" · `/taladsod/listings?category=1` → "เข้าหมวด" etc.
- Server side (`AiChatApiController.php`) sync prompt ให้ตรงกัน · cloud reply ก็ใช้ `[GO:...]` เหมือนกัน

### เพิ่ม — Greeting อัจฉริยะตามสถานะ install
- เปิดแชทครั้งแรกแล้ว **โมเดลยังไม่ติดตั้ง** → เปลี่ยน greeting เป็น:
  > "สวัสดีค่ะ 🌸 น้องหญิงเองค่ะ ตอนนี้น้องยังไม่ได้ติดตั้งบนเครื่องนะคะ ติดตั้งแล้วน้องจะตอบได้ไว + ใช้ได้แม้ไม่มีเน็ตค่ะ [GO:/nong-ying/install] ติดตั้งเลย (ระหว่างนี้ใช้ cloud ได้นะคะ)"
- user กด chip "ติดตั้งน้องหญิง" → sheet ปิด · พาไปหน้า install ทันที
- ถ้าติดตั้งแล้ว → greeting ปกติ · ไม่รบกวน

### แก้ — Settings Gemma card ไม่ crash ตอน URL ว่าง
- Settings page ใช้ `plan.isReady` แทน null check · `unconfigured/unavailable` แสดงข้อความ friendly ไม่ใช่ card ว่าง

## [1.0.13] - 2026-04-20

### เพิ่ม — SQLite foundation (`sqflite` + `LocalDb` + `KvStore`)
- เพิ่ม `sqflite ^2.3.3` — platform SQLite runtime · ไม่ชนกับ `flutter_gemma`'s sqlite3 3.x (คนละ package)
- `lib/core/db/local_db.dart`: `LocalDb.open()` + migration ladder (schema v1 = `kv_store` table) · ทุก schema change ต้องเป็น migration ใหม่ · ไม่แก้ migration เก่า
- `KvStore` — thin API รอบตาราง kv: `read/write/delete/deleteAll` · TEXT value · caller JSON-encode เอง
- ใช้เป็น foundation ของ:
  - auth token (v1.0.13 ตอนนี้)
  - product cache, chat history, wallet snapshot, offline queue (roadmap)

### แก้ — Login ไม่ติดทนหลังปิด-เปิดแอพใหม่ (ต้อง login ใหม่ทุกครั้ง)
- รากเหง้า: `flutter_secure_storage` ใน Android ใช้ EncryptedSharedPreferences + AES-GCM · Android 12+ มี bug `AEADBadTagException` ตอน keystore rotate / OS upgrade / ADB install ผิดท่า
- เก่า: `resetOnError: true` → lib **เงียบ ๆ ล้าง keystore ทั้งตัว** เมื่อ read fail → token หายเรียบ → user ต้อง login ใหม่
- ตอนนี้ `TokenStorage` strategy ใหม่:
  - **Primary**: SQLite `kv_store` — ไม่พึ่งพา keystore · ไม่มี bug นี้
  - **Mirror**: secure storage ยังเขียน redundantly (encryption at rest)
  - **Read path**: ลอง SQLite ก่อน · ถ้าไม่เจอ fallback ไป secure storage · migrate ให้ user ที่อัพจาก ≤ v1.0.12 (token เดิมอยู่ใน secure อย่างเดียว → อ่าน + เขียนลง SQLite ให้ครั้งแรก)
  - `resetOnError: false` — errors log ใน `kDebugMode` แทน silent wipe
- `tokenStorageProvider` เปลี่ยนจาก `Provider` เป็น `FutureProvider` (ต้องรอ DB open ก่อน) · apiClient + authRepository + pinService ปรับตามให้ `.future`
- ผล: login ครั้งเดียว → ใช้ได้ยาวจนกว่า token หมดอายุ (หรือ user logout)

### แก้ — `/settings` crash ตั้งแต่ v1.0.11
- v1.0.11 ลบ 7 native libs ของ flutter_gemma หวังจะลด APK 88 MB · ผลข้างเคียง: `FlutterGemma.initializePlugin()` หรือ `isModelInstalled()` dlopen libs บางตัว → throw `UnsatisfiedLinkError` → หน้า settings เปิดไม่ได้
- v1.0.13 revert libs ที่เสี่ยง (embedding + RAG, 50 MB) · เก็บไว้แค่ exclusions ที่ชัวร์:
  - `libmediapipe_tasks_vision_jni.so` (14 MB)
  - `libmediapipe_tasks_vision_image_generator_jni.so` (14 MB)
  - `libimagegenerator_gpu.so` (10 MB)
- APK ผลลัพธ์: 209 MB → ~170 MB (saves 38 MB · ไม่แตะ LlmInference path)
- ถ้าอนาคตจะ drill ลงไปอีก: รัน `adb logcat` ขณะ initializePlugin + ดู UnsatisfiedLinkError ตัวไหนโผล่ขึ้น

### เพิ่ม — Wallet / Affiliate mini card แตะได้บน home
- เดิม card แสดงยอดเงิน/rank เฉย ๆ · user แตะไม่มีอะไรเกิดขึ้น · งง
- ตอนนี้:
  - แตะที่ Wallet card → `/wallet`
  - "+ เติม" → `/wallet/topup` ตรง ๆ (ข้ามหน้า summary)
  - "ถอน" → `/wallet` (stub จนกว่า v1.1 withdrawal flow ลง)
  - แตะที่ Affiliate card → `/affiliate`

## [1.0.12] - 2026-04-20

### แก้ — "Credential Error" ภาษาอังกฤษโผล่ตอน login (แปลเป็นไทยแล้ว)
- Backend Sanctum login ตอบ `"The provided credentials are incorrect."` (Laravel default ภาษาอังกฤษ) · app เดิมแสดงข้อความนี้ดิบ ๆ · user งง
- เพิ่ม `_localize()` ใน `api_exceptions.dart` · ตรวจจับข้อความอังกฤษที่รู้จัก 8 แบบ → แปลเป็นไทย · string ที่มีตัวอักษรไทยอยู่แล้ว (จาก endpoint ที่ localize ไว้แล้ว) ไม่แตะ
- แปลครอบคลุม: `credentials are incorrect`, `too many attempts`, `email/password required`, `email already taken`, `password confirmation`, `email valid`, `unauthenticated`
- ใช้ทั้งกับ top-level `message` และ per-field `errors[k]` · validation error ใต้ช่องก็ได้ไทย

### แก้ — "เซิร์ฟเวอร์ไม่ส่ง token" หายไป + token extraction ทนทานขึ้น
- เดิมเรียก `data['token'] ?? data['access_token']` ตรง ๆ · ถ้า backend wrap ผล login/register ใน `{success, data: {token, ...}}` → extract fail → throw `StateError('เซิร์ฟเวอร์ไม่ส่ง token')` ที่ user ตีความไม่ได้
- ตอนนี้: `_unwrap` ลองดู `raw['data']` ก่อน ถ้าเป็น Map ใช้ตัวนั้น · `_extractToken` ลองทั้ง `token`/`access_token`/`auth_token` · ลองทั้ง nested และ flat
- ถ้ายัง extract ไม่ได้ (แปลว่า backend พัง) · ข้อความเปลี่ยนเป็น `"เข้าสู่ระบบไม่สำเร็จ · ตรวจสอบอีเมล/รหัสผ่านแล้วลองใหม่ค่ะ"` แทนที่จะโยน "เซิร์ฟเวอร์ไม่ส่ง token" ไปให้ user

### เพิ่ม — Register: ช่องยืนยันรหัสผ่าน + ส่ง `password_confirmation`
- Backend ใช้ Laravel rule `confirmed` บน `password` · ต้องมี `password_confirmation` ตรงกัน
- App เดิมส่งแค่ `password` → backend ตอบ error `"รหัสผ่านไม่ตรงกัน"` ทั้ง ๆ ที่ user กรอกรหัสครั้งเดียว · งง
- ตอนนี้:
  - หน้าสมัครมี 2 ช่อง: "รหัสผ่าน (อย่างน้อย 8 ตัวอักษร)" + "ยืนยันรหัสผ่าน"
  - ตรวจ client-side ก่อน submit: ไม่ตรง → error ทันที · < 8 ตัว → error ทันที · ไม่ต้องรอ server round-trip
  - ส่ง `password_confirmation` ไป backend ด้วย

### เพิ่ม — รหัสแนะนำรองรับลิงก์ affiliate Thaiprompt
- เดิม user ต้อง copy code ยาว ๆ จากลิงก์เอง · ตอนนี้ paste ทั้ง URL ได้เลย
- รองรับรูปแบบ:
  - Bare code: `ABC123`
  - Full URL: `https://thaiprompt.online/?ref=ABC123`
  - Path-style: `thaiprompt.online/invite/ABC123` · `/r/ABC123` · `/ref/ABC123`
  - Query key aliases: `?ref=` · `?referral=` · `?referral_code=` · `?referrer=` · `?r=`
- Hint บอก user รูปแบบที่ยอมรับ: `ABC123 หรือ thaiprompt.online/?ref=ABC123`

## [1.0.11] - 2026-04-20

### เปลี่ยน — APK ลดจาก 209 MB → คาด ~120 MB (-42%)
- ตรวจ APK v1.0.9: `.so` ใช้พื้นที่ **192 MB จาก 209 MB** (88%) · flutter_gemma ลาก native libs มา ~145 MB โดยที่แอพใช้จริงแค่ `LlmInference` path (core 46 MB)
- ลบ libs ที่ไม่ได้ใช้ผ่าน `packaging.jniLibs.excludes`:

  **Vision + image gen (-38 MB)** · ไม่มีโค้ดเราเรียก
  - `libmediapipe_tasks_vision_jni.so` (14 MB)
  - `libmediapipe_tasks_vision_image_generator_jni.so` (14 MB)
  - `libimagegenerator_gpu.so` (10 MB)

  **Embedding + RAG (-50 MB)** · ไม่ใช้ on-device RAG/vector search
  - `libgemma_embedding_model_jni.so` (17 MB)
  - `libgecko_embedding_model_jni.so` (17 MB)
  - `libtext_chunker_jni.so` (9 MB)
  - `libsqlite_vector_store_jni.so` (7 MB)

- เหลือ: `libllm_inference_engine_jni.so` (26 MB) + `liblitertlm_jni.so` (20 MB) · ครบสำหรับ Gemma 4 chat
- sherpa_onnx (libonnxruntime 26 MB) ยังเก็บไว้ — ใช้สำหรับ Piper offline TTS

### หมายเหตุ
- Verification หลัง CI build: `unzip -l thaipromptapp-1.0.11.apk | grep '\.so$'` ควรเห็น `.so` ~13 ไฟล์ แทนที่จะเป็น 20
- ถ้าอนาคตเพิ่ม on-device RAG / vision / image-gen · ลบ exclude line ที่ตรงกันใน `android/app/build.gradle.kts` แล้วรี-build

## [1.0.10] - 2026-04-20

### แก้ — Auto-update dialog ไม่ขึ้นเลย (รากเหง้าของ "แอพไม่รู้ว่ามีเวอร์ชั่นใหม่")
- `UpdateObserver` ถูก mount ใน `MaterialApp.router`'s `builder:` callback · BuildContext ตรงนี้อยู่ **เหนือ** Navigator ของ router
- `showDialog(context: context, ...)` เรียก `Navigator.of(context, rootNavigator: true)` · เดินขึ้นไปในตระกูล widgets หา Navigator · **ไม่เจอ** เพราะ Navigator อยู่ข้างล่าง
- ผล: `showDialog` throw assertion · ถูก `catch (_)` ใน `_runCheck` กลืนเงียบ · user ไม่เห็น dialog เลย แม้ backend ตอบ 1.0.9 อยู่ก็ตาม
- แก้: exposed `rootNavigatorKey` (GlobalKey<NavigatorState>) ผ่าน router · ส่งให้ `GoRouter(navigatorKey: ...)` · UpdateObserver ใช้ `rootNavigatorKey.currentContext` ตอน `UpdateDialog.show(...)` แทน

### เพิ่ม — รอ Splash จบก่อนแสดง dialog + debug logging
- เดิม `_runCheck` ดีเลย์ 800ms คงที่ · ถ้าโชคร้าย check เสร็จก่อน splash anim (2.3s) · dialog ขึ้นทับ logo zoom-in ดูน่าเกลียด
- ตอนนี้: check network ขนานกับ splash anim · รอ `splashGateProvider` flip → true (หรือ timeout 3500ms) ก่อนพ่น dialog · landing frame เสมอ
- `catch` block เพิ่ม `debugPrint` ใน `kDebugMode` เพื่อ surface การ fail ในครั้งต่อไปโดยไม่ต้องเดา · release build ยังเงียบเหมือนเดิม

### ภายใน
- `min_supported_version` จาก backend = 1.0.9 (ปัจจุบัน) · ผู้ใช้ที่ยังอยู่บน ≤ v1.0.8 จะได้ dialog แบบ `mandatory: true` (non-dismissable) → อัพเดทเร็วขึ้น

## [1.0.9] - 2026-04-20

### เปลี่ยน — Splash → Onboarding (ไม่บายพาสให้อีกต่อไป)
- v1.0.8 ส่ง guest จาก `/splash` ไป `/home` ทันที · user ไม่เคยได้เห็น "ตลาดนัดอยู่ในมือ"
- v1.0.9 คืนค่าดั้งเดิม: guest cold-start = Splash → `/onboarding` → กด "เริ่มใช้เลย" → `/home`
- ปุ่ม "เริ่มใช้เลย · Get started" เปลี่ยนจาก `/register` เป็น `/home` · เข้าเป็น guest ทันที ไม่บังคับสมัคร
- ลิงก์ "มีบัญชีแล้ว? เข้าสู่ระบบ" ยังพาไป `/login` ตามเดิม

### เพิ่ม — Guest access ขยาย (แก้ปัญหาหลายหน้าเด้งไป login/Route Error)
- `/settings` → เปิดให้ guest · ติดตั้ง Gemma + Piper ได้โดยไม่ต้อง login (feature offline ล้วน ไม่แตะ backend)
- `/nong-ying`, `/nong-ying/install` → เปิดให้ guest · AI น้องหญิงทำงาน local (Gemma บนเครื่อง)
- ผล: guest กดเมนูล่างสุด (ปุ่มเมนู/settings) → เข้าหน้า settings ได้ทันที ไม่ต้อง login

### แก้ — ปุ่มย้อนกลับไม่พังในทุกหน้า
- หน้า `/settings` + `/cart` เข้าถึงด้วย `context.go` (replace stack) · กด back เดิมเรียก `context.pop()` บน stack ว่าง → throw/ไม่ทำอะไร
- ใช้ `canPop()` check: ถ้า pop ได้ → pop · ถ้าไม่ได้ → `context.go('/home')` · ไม่มี dead-end

### แก้ — NavDock ปุ่ม "เมนู" ไม่ทำงานในหน้า Wallet + Affiliate
- Wallet + Affiliate page onChange handler เดิมรองรับแค่ home/wallet/affiliate · แตะ "เมนู" ไม่เกิดอะไร
- ตอนนี้: `NavTab.menu → /settings` ครบทุกหน้า

### แก้ — Login/Register error message ไม่ leak "Exception:/Bad state:" อีก
- ก่อนหน้า: `catch (e)` แสดง `"เกิดข้อผิดพลาด: Exception: ..."` หรือ `"Bad state: ..."` ออกหน้าจอ (อ่านแล้วดูเป็น "Creation Error")
- ตอนนี้: คัดแยก `ApiException` + `StateError` + generic · generic แสดงข้อความไทยสะอาด ๆ แทน
- Login: `"เข้าระบบไม่สำเร็จ · ตรวจสอบอีเมล/รหัสผ่านแล้วลองใหม่ค่ะ"`
- Register: `"สมัครไม่สำเร็จ · ลองอีกสักครู่หรือตรวจการเชื่อมต่อนะคะ"`
- เพิ่ม validation ช่องว่างก่อน submit (แทนส่งไปให้ backend 422) · UX เร็วขึ้น

### แก้ — หน้า "ไม่พบเส้นทาง" (Route Error) ดูน่ากลัว
- เดิม: `Scaffold > Text("ไม่พบเส้นทาง: /foo")` · พื้นขาวล้วน text เดียวดาย
- ตอนนี้: icon + ข้อความ "อุ๊ย · หน้านี้ไม่ว่างในตอนนี้" + ปุ่ม "กลับหน้าแรก" สีพาสเทล · match brand

## [1.0.8] - 2026-04-19

### เปลี่ยน — Guest mode (ไม่ต้อง login ก่อนใช้แอพ)
- หน้าที่ไม่ต้อง login: `/home`, `/taladsod`, `/taladsod/listings`, `/taladsod/listings/:id`, `/taladsod/sellers/:id`, `/product/:id`, `/shop/:id`, `/orders/:id/tracking` (token-based)
- หน้าที่ยังต้อง login: `/cart`, `/wallet`, `/wallet/*`, `/affiliate`, `/settings`, `/taladsod/orders` · กดเข้าจะเด้งไป `/login` พร้อมปุ่ม "ข้ามไปก่อน" + ปุ่มย้อนกลับไป `/home`
- Splash → Home ตรงๆ สำหรับ guest (เคยเป็น Splash → Onboarding)
- Login/Register page back-arrow ไป `/home` แทน `/onboarding` เพื่อไม่ติด loop

### แก้ — App ส่งทุกคำขอตรงไปที่ canonical host (ไม่พึ่ง 308 redirect อีกแล้ว)
- API base URL: `https://thaiprompt.online/api` → `https://main.thaiprompt.online/api`
- เหตุผล: Dio + dart:io HttpClient บน Android บางเครื่องเจอปัญหาเรื่อง POST body หาย/method downgrade ตอน follow 308 → ทำให้แอพแสดง "ไม่มีสัญญาณอินเทอร์เน็ต" ทั้งที่เน็ตปกติ
- ตอนนี้แอพไม่ต้องผ่าน redirect → 1 round-trip เร็วขึ้น + เสถียรขึ้นทุกเครื่อง
- Bare-domain `thaiprompt.online` ยัง 308 ปกติสำหรับเบราว์เซอร์ + ลิงก์ภายนอก (`.htaccess` เดิม)

### แก้ — Auto-update prompt ไม่เคยขึ้นเพราะรอ AuthAuthenticated
- `UpdateObserver` เคย gate ที่ `next is AuthAuthenticated` → guest user ไม่เคยเห็น update dialog
- v1.0.8: fire ตอน auth state เปลี่ยนจาก `AuthUnknown` → `AuthAuthenticated` หรือ `AuthUnauthenticated` (ครั้งแรกของ session)
- เพิ่ม fallback ใน `initState`: ถ้า auth resolved ก่อน mount (warm start / hot reload) จะ run check ทันที
- ผล: app ทุกครั้งที่เปิดจะเช็ค `/v1/app/latest-version` และเด้ง dialog ถ้ามีเวอร์ชั่นใหม่

### ภายใน
- ผล packaging.jniLibs.excludes (v1.0.7) verified: APK เหลือ 199 MB · 20 .so files · arm64-v8a เพียงอย่างเดียว ✅

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

[Unreleased]: https://github.com/xjanova/thaipromptapp/compare/v1.0.8...HEAD
[1.0.8]: https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.8
[1.0.7]: https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.7
[1.0.6]: https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.6
[1.0.5]: https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.5
[1.0.4]: https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.4
[1.0.3]: https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.3
[1.0.2]: https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.2
[1.0.1]: https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.1
[1.0.0]: https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.0
