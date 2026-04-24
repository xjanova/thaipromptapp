# Handoff: Thaiprompt (ไทยพร๊อม) — Community Marketplace App

> **For: developer using Claude Code on the `xjanova/thaipromptapp` Flutter repo**
> **Target codebase:** Flutter 3.41.7 · Dart 3.11 · Riverpod 2 · go_router
> **Backend:** Laravel 11 + Sanctum (`xjanova/Thaiprompt-Affiliate`)

---

## Overview

Thaiprompt is a **Thai community marketplace** with five roles in one app:

1. **Mode Select** — post-login role picker (Buyer / Seller / Rider)
2. **Buyer** — browse shops, order food & goods, pay with PromptPay, track delivery, review
3. **Seller (ร้านค้า)** — back-office: dashboard, orders, products, promos, reports, withdraw
4. **Rider (ไรเดอร์)** — job queue, active delivery (pickup→deliver), earnings, profile
5. **MLM / Affiliate** — downline tree, earnings, invite links, tier progression
6. **Admin · Remote Config** — web-hosted ad-banner & menu management that feeds the app

All five roles are designed. Wallet (PromptPay top-up, QR transfer, history), Affiliate (tier + earnings + invite), Cart, Checkout (address→payment→QR→paid→receipt), Chat, Tracking, Profile, Settings are modeled in detail.

---

## About the design files in this bundle

The files here are a **hi-fidelity HTML prototype** — they demonstrate the intended visual language, layout, copy, and interaction flow. They are **design references**, not production code. Do **not** transpile the JSX to Dart or copy CSS shadows 1:1.

Your job is to **recreate these designs in the existing Flutter app at `lib/features/*`**, using the project's established patterns:

- `shared/widgets/clay_card.dart` for the "chunk" container
- `shared/widgets/puffy_button.dart` for the `.btn` primitive
- `shared/widgets/nav_dock.dart` for the bottom nav (see §Nav below)
- `shared/widgets/blob_3d.dart` · `puff.dart` · `coin.dart` for the 3D decorations
- `core/theme/tokens.dart` & `clay_theme.dart` for colors/radii/shadows
- `core/theme/text_styles.dart` for typography
- Riverpod controllers under `features/*/*_controller.dart`
- go_router for navigation — add routes to `app/router.dart`

Screens that already exist in `lib/features/` should be **extended**, not rewritten. New roles (Seller / Rider / MLM) need new `features/seller/`, `features/rider/`, `features/mlm/` directories.

## Fidelity

**Hi-fi.** Colors, typography, spacing, radii, shadows, iconography and copy (Thai + English) are final. Pixel-perfect implementation is the goal. Soft claymorphism (no hard borders, soft outer shadows, inner highlights) is the hard rule — **no 1px black strokes anywhere**.

---

## Design tokens

All tokens mirror `lib/core/theme/tokens.dart` — keep them as the single source of truth.

### Colors

| Token | Hex | Usage |
|---|---|---|
| `--pink` | `#FF3E6C` | Primary accent, CTAs, active states |
| `--mint` | `#00D4B4` | Success, money-in, positive delta |
| `--mango` | `#FFC94D` | Secondary accent, active tab pill |
| `--tomato` | `#FF7A3A` | Seller accent, gradient pair with mango |
| `--purple` | `#6B4BFF` | Rider / MLM surface, tertiary accent |
| `--sky` | `#7AC7FF` | Info, links |
| `--cream` | `#FFF8EE` | App background (Buyer, light surfaces) |
| `--ink` | `#0E0B1F` | Text primary, dark surfaces (nav, rider/mlm bg) |
| `--ink-2` | `#2A1F3D` | Secondary dark, muted on dark |
| `--muted` | `#6E6A85` | Secondary text, mono labels |

### Typography

- **UI body/heading:** `IBM Plex Sans Thai` (Thai + Latin) — weights 400, 600, 700, 900
- **Display:** `Space Grotesk` — weight 700, 900 (prices, big numbers)
- **Mono/caption:** `JetBrains Mono` — `.18em` letter-spacing, uppercase, 9–11px (data labels, statusbar clocks)

### Radii

- **Small (chip, pill):** 14px
- **Medium (card, button):** 18px
- **Large (phone screen, sheet):** 22–28px
- **Full pill:** 999px

### Shadows (clay system — **never** use hard offset like `2px 2px 0 #0E0B1F`)

```
--clay-sm:  0 4px 10px -4px rgba(70,42,92,.18), inset 0 1px 0 rgba(255,255,255,.8);
--clay-md:  0 10px 22px -10px rgba(70,42,92,.22), inset 0 1px 0 rgba(255,255,255,.85);
--clay-lg:  0 18px 36px -14px rgba(70,42,92,.28), inset 0 1px 0 rgba(255,255,255,.9);
--clay-glow: 0 10px 18px -8px rgba(255,201,77,.6);
```

### Spacing

8pt grid — 4, 8, 10, 12, 14, 16, 18, 20, 24, 28 are the common values. Don't invent new ones.

---

## Bottom Nav (shared across all roles)

**See `buyer-app.jsx` → `AppTabBar` + `TabIcon`** for the canonical implementation.

- Dark floating pill bar (`#0E0B1F`), 22px rounded, inset light hairline
- Active tab is an **expanding pill** with coloured fill (accent) + icon + label
- Inactive tabs show icon only (size 22px, stroke 2px)
- Spring easing on width transition: `cubic-bezier(.5, 1.4, .5, 1)` 280ms
- Badges: pink (`#FF3E6C`) 14px, 2px ink-coloured border-box separator

Accent per role:
- Buyer → `#FFC94D` on ink text
- Seller → `#FF7A3A` on white text
- Rider → `#FFC94D` on ink text (over dark page bg)
- MLM → `#FFC94D` on ink text (over dark page bg)

Flutter implementation lives in `lib/shared/widgets/nav_dock.dart` — refactor to accept `items`, `accent`, `accentTextColor`, `onDark` props. Icons should be authored as Flutter `CustomPainter` or SVG assets (keep the specific icon set: home · categories · orders · wallet · profile · dash · products · reports · jobs · bike · earnings · tree · invite · withdraw).

---

## Screens inventory

### Mode Select (`features/onboarding/mode_select_page.dart` — NEW)

- Top: dismissible ad banner carousel (`mode-banner`) — **data comes from `GET /v1/app/sliders`** (Remote Config, ETag-cached). Tap = deeplink, close = session-scoped dismiss.
- Three mode cards stacked: **Buyer** (pink), **Seller** (tomato→mango gradient), **Rider** (purple→sky gradient)
- Each card: big 3D blob glyph, title (TH + EN), one-line sub-copy, "เข้าสู่โหมด →" CTA
- Tap card → `context.go('/buyer')` | `/seller` | `/rider`
- Footer link: "ข้ามและใช้โหมดผู้ซื้อ" (default buyer)

### Buyer flow (16 screens)

| # | Screen | Route | File |
|---|---|---|---|
| 01 | Home | `/buyer` | `features/home/home_page.dart` (existing) |
| 02 | Search | `/buyer/search` | `features/home/search_page.dart` (NEW) |
| 03 | Categories | `/buyer/categories` | `features/home/categories_page.dart` (NEW) |
| 04 | Product | `/buyer/product/:id` | `features/product/product_page.dart` (existing) |
| 05 | Shop | `/buyer/shop/:id` | `features/shop/shop_page.dart` (existing) |
| 06 | Cart | `/buyer/cart` | `features/cart/cart_page.dart` (existing) |
| 07 | Checkout · Address | `/buyer/checkout/address` | `features/checkout/address_step.dart` (NEW) |
| 08 | Checkout · Payment | `/buyer/checkout/payment` | `features/checkout/payment_step.dart` (NEW) |
| 09 | PromptPay QR | `/buyer/checkout/qr` | `features/checkout/qr_step.dart` (NEW) |
| 10 | Paid | `/buyer/checkout/paid` | `features/checkout/paid_step.dart` (NEW) |
| 11 | Receipt | `/buyer/checkout/receipt/:orderId` | `features/checkout/receipt_page.dart` (NEW) |
| 12 | Tracking | `/buyer/tracking/:orderId` | `features/tracking/tracking_page.dart` (existing) |
| 13 | Chat | `/buyer/chat/:shopId` | `features/chat/chat_page.dart` (existing) |
| 14 | Orders | `/buyer/orders` | `features/orders/orders_page.dart` (NEW — currently `my_orders_page.dart` under fresh_market) |
| 15 | Review | `/buyer/review/:orderId` | `features/review/review_page.dart` (NEW) |
| 16 | Notifications | `/buyer/notifications` | `features/notifications/noti_page.dart` (NEW) |
| 17 | Wallet | `/buyer/wallet` | `features/wallet/wallet_page.dart` (existing) |
| 18 | Affiliate | `/buyer/affiliate` | `features/affiliate/affiliate_page.dart` (existing) |
| 19 | Profile | `/buyer/profile` | `features/profile/profile_page.dart` (NEW) |
| 20 | Address book | `/buyer/addresses` | `features/profile/address_book_page.dart` (NEW) |
| 21 | Coupons | `/buyer/coupons` | `features/profile/coupons_page.dart` (NEW) |

**Checkout flow** is modelled as a 4-step stepper (1→Address, 2→Payment, 3→QR if PromptPay, 4→Paid) with Receipt as a leaf. See `buyer-app.jsx` → `CkAddress`, `CkPayment`, `CkQR`, `BuyerPaid`, `CkReceipt`.

### Seller flow (7 screens) · **NEW `features/seller/`**

| # | Screen | Route | Key elements |
|---|---|---|---|
| S1 | Dashboard | `/seller` | Revenue today card, 8-bar hourly chart, 4 quick-actions, 3 today-orders. See `seller-app.jsx` → `SellerDashV2` |
| S2 | Orders | `/seller/orders` | Status tabs (ทั้งหมด · ใหม่ · กำลังทำ · จัดส่ง · เสร็จ · ยกเลิก) · list. See `SellerOrders` |
| S3 | Order Detail | `/seller/orders/:id` | Customer card, items, action row: ยืนยัน / ปฏิเสธ |
| S4 | Products | `/seller/products` | Grid of products, stock indicator, edit button |
| S5 | Product Edit | `/seller/products/:id` | Image upload (4 slots), name/price/stock/description/variants/category |
| S6 | Promotions | `/seller/promos` | Active promos list, create new CTA |
| S7 | Reports | `/seller/reports` | 6-month revenue chart, top products, export |
| S8 | Withdraw | `/seller/withdraw` | Bank card, amount input, quick-pick chips (1k / 3k / all), history |

### Rider flow (5 screens) · **NEW `features/rider/`**

| # | Screen | Route | Key elements |
|---|---|---|---|
| R1 | Dashboard / Live Job | `/rider` | Mini map SVG with 3-point route (A→B→C), active job card, accept/navigate buttons |
| R2 | Job Queue | `/rider/jobs` | Filter chips (ใกล้ฉัน · ราคาสูง · ด่วน), job cards with distance/fare/ETA |
| R3 | Job Detail (active) | `/rider/jobs/:id` | Full map, customer contact, pickup→dropoff timeline, action row |
| R4 | Earnings | `/rider/earnings` | Today / week / month toggles, bar chart, breakdown (deliveries × avg fare + tips) |
| R5 | Profile / Wallet | `/rider/profile` | Rider card with rating, vehicle info, documents status |
| R6 | SOS | sheet | Dispatch panic button → contacts dispatch + 191 (see `extra-screens.jsx`) |

### MLM / Affiliate full (4 screens) · **NEW `features/mlm/`**

| # | Screen | Route | Key elements |
|---|---|---|---|
| M1 | Dashboard | `/mlm` | Tier card (current + progress to next), downline count, this-month commission |
| M2 | Team Tree | `/mlm/tree` | Visual tree graph, tap node → drill down |
| M3 | Earnings | `/mlm/earnings` | Commission history, level breakdown |
| M4 | Invite | `/mlm/invite` | Personal link + QR + share buttons, invite contact list |

### Admin Banner / Menu panel (web, not in app) · backend repo

- Banner crud (title, image, link, active range, target roles)
- Menu-item crud (label, icon, route, order, visible_to[])
- Promotion crud
- Mapping: `lib/core/remote_config/` already reads these — just add the admin UI to the Laravel backend per `HANDOVER.md` §"Known follow-ups".

---

## Interactions & behaviour

### Navigation

- **go_router** with `ShellRoute` per mode so the tab bar persists across sub-screens
- Deeplinks: `thaiprompt://buyer/product/:id`, `thaiprompt://mlm/invite?ref=XYZ`
- Mode switch persists in `SharedPreferences` (`last_mode`) — next launch auto-routes to last active mode

### Animations

- Tab pill expand: 280ms `cubic-bezier(.5, 1.4, .5, 1)`
- Screen transitions: `CupertinoPageTransition` on iOS, fade-through 240ms on Android
- Paid success: `flutter_animate` — confetti + scale-in check badge (1.0→1.2→1.0 over 600ms)
- QR countdown: plain 1-second ticker, turns pink under 60s

### Form validation

- **Address:** required name, phone (TH regex `^0[6-9]\d{8}$`), building, district, province (dropdown of 77 provinces)
- **Product edit:** name (≥3 chars), price (>0), stock (≥0), category required, ≥1 image
- **Withdraw:** amount ≥ ฿100, ≤ current balance, bank account verified
- **PIN:** 6 digits, 3-attempt lockout (already implemented — see `core/security/pin_service.dart`)

### Empty / Loading / Error states

- Loading: `shimmer` block matching layout (not spinners)
- Empty: centered 3D blob illustration + one-line "ยังไม่มี <thing>" + CTA to primary action
- Error: toast with retry button; 500s → friendly "ขอโทษนะ ระบบขัดข้อง ลองใหม่อีกที"

---

## State management (Riverpod)

Add these providers (codegen via `@riverpod`):

```
features/onboarding/mode_controller.dart      // current mode enum
features/checkout/checkout_controller.dart    // step, address, method, coupon, order preview
features/seller/seller_dashboard_controller.dart
features/seller/products_controller.dart
features/rider/job_queue_controller.dart
features/rider/active_job_controller.dart
features/mlm/downline_controller.dart
```

Backend endpoints (see `HANDOVER.md` and backend PR #2534):

- `GET /v1/app/config` + `/flags` · remote config & feature flags
- `GET /v1/app/sliders` · ad banners for Mode Select
- `POST /v1/events/batch` · analytics (consent-aware)
- Existing endpoints: `/v1/products`, `/v1/shops`, `/v1/cart`, `/v1/orders`, `/v1/wallet/*`, `/v1/affiliate/*`

New endpoints **to add** (document them when you extend the backend):

- `GET /v1/seller/dashboard`, `GET /v1/seller/orders`, `PATCH /v1/seller/orders/:id`
- `GET /v1/seller/products`, `POST /v1/seller/products`, `PATCH /v1/seller/products/:id`
- `GET /v1/rider/jobs`, `POST /v1/rider/jobs/:id/accept`, `POST /v1/rider/jobs/:id/deliver`
- `GET /v1/rider/earnings`, `GET /v1/mlm/tree`, `GET /v1/mlm/invite`

---

## Assets

- **Logo:** `ref/logoapp.png`, `ref/logoapp_foreground.png`, `ref/logoapp_splash.png` — already in `assets/images/` of the Flutter repo
- **3D decorations:** draw with Flutter `CustomPainter` or ship as static SVG assets (not PNG — the shapes are algorithmic). See `blobs.jsx` → `Blob3D`, `Puff`, `Coin` for the path maths
- **SFX:** `assets/sfx/startup_16bit.wav` — already exists
- **Icons:** 14 tab icons listed above. Recommended: author as a single `thaiprompt_icons.svg` sprite, or compile to a Flutter `IconData` set via `fluttericon.com` if you want `Icon()` ergonomics

---

## Files in this bundle

- **`Thaiprompt App v2.html`** — the prototype host page. Open in a browser to see all 40+ screens laid out on a design canvas (5 rows per mode)
- **`blobs.jsx`** — 3D blob / puff / coin primitives (SVG path maths are the reference)
- **`phone.jsx`** — claymorphic Android-ish device frame (status bar, home indicator)
- **`buyer-app.jsx`** — Buyer state machine + **shared `AppTabBar` / `TabIcon`** (canonical nav implementation)
- **`seller-app.jsx`** — Seller 7-screen flow
- **`rider-app.jsx`** — Rider 5-screen flow
- **`mlm-app.jsx`** — MLM 4-screen flow
- **`extra-screens.jsx`** — Rider SOS, Admin banner panel (web), misc
- **`screens-a.jsx` / `screens-b.jsx` / `screens-c.jsx`** — original Buyer screens (Home, Product, Shop, Wallet, Affiliate, Cart, Tracking, Chat, Profile, Settings)
- **`styles.css`** — design tokens (mirrors `lib/core/theme/tokens.dart`)

## How to run the prototype

```bash
# from the bundle directory
npx serve .
# open http://localhost:3000/Thaiprompt%20App%20v2.html
```

Or just open `Thaiprompt App v2.html` directly in a modern browser — no build step, scripts are transpiled in-browser via `@babel/standalone`.

---

## Implementation priority (suggested)

1. **Nav refactor** — update `nav_dock.dart` to the new dark-pill `AppTabBar` spec (§Bottom Nav). Ship the 14-icon set.
2. **Mode Select** — new screen, wire remote-config banner carousel, enable mode switch
3. **Checkout flow** — 5 new screens under `features/checkout/`. The existing Cart already exists
4. **Seller shell** — ShellRoute + 7 screens. Start with Dashboard + Orders, ship, then Products / Promos / Reports / Withdraw
5. **Rider shell** — ShellRoute + 5 screens. Start with Job Queue + Active Job
6. **MLM screens** — extend existing `features/affiliate/` into 4-screen shell
7. **Profile / Address book / Coupons / Notifications / Review** — fill in Buyer remaining screens
8. **Admin banner UI** — Laravel backend CRUD (see `HANDOVER.md`)

---

## Questions for the next Claude

- Should the Seller / Rider modes be separate APKs eventually, or single-app with role switch? (Currently: single-app, switchable via Mode Select)
- MLM tier thresholds and commission % are stub values in the prototype — confirm the real business rules from product before coding
- The Flutter repo's `fresh_market/` feature overlaps with Buyer — decide whether to merge it into `buyer/` or keep as a sub-feature

---

*Last updated: 2026-04-24 · Design language: claymorphism + Vibrant Pop · Built on: Thaiprompt v1.0.1*
