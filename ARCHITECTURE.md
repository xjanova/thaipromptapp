# Thaiprompt Mobile App — Architecture

> Flutter mobile app for the Thaiprompt (ไทยพร๊อม) Thai community marketplace.
> Backend: https://github.com/xjanova/Thaiprompt-Affiliate (Laravel 11 + Sanctum)
> App repo: https://github.com/xjanova/thaipromptapp

## 1. Stack

| Layer | Choice | Reason |
|---|---|---|
| Framework | Flutter 3.38 (stable) | Cross-platform Android + iOS |
| Language | Dart 3.10 | Null-safe, records, patterns |
| State | Riverpod 2.x (`flutter_riverpod` + `riverpod_annotation`) | Codegen, compile-safe refs, testable |
| Routing | `go_router` | Declarative + deep-link friendly |
| HTTP | `dio` + `dio_smart_retry` + `pretty_dio_logger` (debug only) | Interceptors for Sanctum token + retry |
| Models | `freezed` + `json_serializable` | Immutable + codegen |
| Storage | `flutter_secure_storage` (tokens/PIN) + `drift` (cache) | Encrypted tokens + fast SQLite cache |
| Fonts | `google_fonts` | IBM Plex Sans Thai + Space Grotesk + JetBrains Mono |
| Images | `cached_network_image` | CDN caching |
| Charts | `fl_chart` | Wallet + Affiliate dashboards |
| QR | `qr_flutter` (display) + `mobile_scanner` (scan) | PromptPay QR |
| Maps | `flutter_map` + `latlong2` (OSM, free) | Tracking screen |
| Animations | `flutter_animate` + `rive` (optional) | Puffy 3D motion |
| LINE Login | `flutter_line_sdk` | Native LINE OAuth |
| **AI (on-device)** | `flutter_gemma` — **Gemma 4** primary, **Gemma 3** fallback | See §5 |
| **TTS** | `sherpa_onnx_flutter` (Piper Thai voice, offline) | Free, commercial OK, NECTEC voice |
| Analytics | Custom SDK → backend `POST /api/v1/events/batch` | Privacy-safe, geohash aggregation |
| GPS | `geolocator` + `geohash_plus` | Region-level tracking (precision 5) |
| Device info | `device_info_plus` + `package_info_plus` | Tier detection for AI model selection |

## 2. Directory Layout

```
lib/
├── main.dart                           # Entry point
├── app/
│   ├── app.dart                        # MaterialApp.router + theme + providers
│   ├── router.dart                     # go_router config
│   └── bootstrap.dart                  # Pre-init (fonts, storage, AI tier detection)
├── core/
│   ├── api/
│   │   ├── api_client.dart             # Dio instance + interceptors
│   │   ├── api_exceptions.dart
│   │   └── endpoints.dart              # Constant URLs
│   ├── auth/
│   │   ├── auth_repository.dart        # Login/logout/refresh
│   │   ├── auth_state.dart             # Riverpod state
│   │   └── token_storage.dart          # flutter_secure_storage wrapper
│   ├── theme/
│   │   ├── tokens.dart                 # Colors, radii, shadows (from styles.css)
│   │   ├── clay_theme.dart             # ThemeData + ClayTheme extension
│   │   └── text_styles.dart            # Display/mono/body
│   ├── analytics/
│   │   ├── event_tracker.dart          # Queue + batch upload
│   │   ├── event_types.dart
│   │   └── location_service.dart       # GPS + geohash
│   ├── ai/
│   │   ├── nong_ying_service.dart      # Persona + chat
│   │   ├── model_manager.dart          # Gemma 4/3 download + tier selection
│   │   └── prompts.dart                # Thai persona system prompt
│   ├── tts/
│   │   └── tts_service.dart            # Piper/sherpa-onnx wrapper
│   ├── remote_config/
│   │   ├── config_service.dart         # GET /app/config (cached, ETag)
│   │   └── feature_flags.dart
│   └── utils/
├── features/
│   ├── onboarding/
│   │   ├── onboarding_page.dart
│   │   └── widgets/
│   ├── auth/
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   └── line_login_page.dart
│   ├── home/
│   │   ├── home_page.dart
│   │   ├── home_controller.dart
│   │   ├── widgets/
│   │   │   ├── today_market_hero.dart
│   │   │   ├── wallet_mini.dart
│   │   │   ├── affiliate_mini.dart
│   │   │   ├── category_marquee.dart
│   │   │   └── nearby_shops.dart
│   │   └── models/
│   ├── product/
│   ├── shop/
│   ├── cart/
│   ├── tracking/
│   ├── chat/
│   ├── wallet/
│   │   ├── wallet_page.dart
│   │   ├── topup_page.dart
│   │   ├── transfer_page.dart          # PIN + QR
│   │   └── qr_scan_page.dart
│   ├── affiliate/
│   └── nong_ying/                      # AI assistant UI
│       ├── chat_page.dart
│       ├── floating_button.dart
│       └── widgets/
└── shared/
    ├── widgets/
    │   ├── clay_card.dart              # The "chunk" primitive
    │   ├── puffy_button.dart           # btn class
    │   ├── blob_3d.dart                # Blob3D from blobs.jsx
    │   ├── puff.dart                   # Puff from blobs.jsx
    │   ├── coin.dart
    │   ├── iso_stall.dart              # Market stall SVG
    │   ├── nav_dock.dart               # TabBar with notch + FAB
    │   ├── marquee.dart
    │   └── phone_safe_area.dart
    └── models/
        ├── product.dart
        ├── order.dart
        ├── wallet_tx.dart
        ├── user.dart
        └── app_config.dart
```

## 3. Screens (9 from prototype + AI + Auth)

| # | Route | Screen | API |
|---|---|---|---|
| 0 | `/splash` | Splash (tier detection, config load) | `GET /v1/settings` |
| 1 | `/onboarding` | Onboarding | - |
| 2 | `/login` | Login | `POST /v1/login` |
| 3 | `/register` | Register | `POST /v1/register` |
| 4 | `/line-login` | LINE Native | `/v1/auth/line-native/*` |
| 5 | `/home` | Home (tab) | `GET /v1/products`, `/categories`, banners |
| 6 | `/product/:id` | Product | `GET /v1/products/{id}` |
| 7 | `/shop/:id` | Shop | `GET /v1/shops/{id}` (to add) |
| 8 | `/cart` | Cart | `/v1/cart/*` |
| 9 | `/orders/:id/tracking` | Tracking | `/v1/orders/{id}/tracking` |
| 10 | `/orders/:id/chat` | Chat | `/v1/orders/{id}/messages` |
| 11 | `/wallet` (tab) | Wallet | `/v1/wallet/*` |
| 12 | `/affiliate` (tab) | Affiliate | `/v1/dashboard/commissions` |
| 13 | `/nong-ying` | AI chat (floating accessible anywhere) | on-device |

## 4. Design Tokens (from `thaiprompt/project/styles.css`)

```dart
// Colors
primary:    #FF3E6C (pink)
accent:     #00D4B4 (mint)
warning:    #FFC94D (mango)
secondary:  #6B4BFF (purple)
info:       #5EC9FF (sky)
onSurface:  #2A1F3D (ink)
background: #FFF8EE (paper)
surface:    #FFFFFF (card)

// Clay shadows (3-layer BoxShadow)
clay:    [outer soft-drop, outer subtle, inner bottom dark, inner top highlight]
clay_sm: smaller variant
clay_lg: larger variant

// Radii
chunk: 26 (cards)
chip:  999 (pills)
btn:   999

// Fonts
display: 'Space Grotesk' (titles)
body:    'IBM Plex Sans Thai' (Thai UI text)
mono:    'JetBrains Mono' (labels, codes)
```

## 5. AI — น้องหญิง (Nong Ying)

**Primary:** Gemma 4 4B (INT4 quantized, ~2.5GB)
**Fallback:** Gemma 3 4B → Gemma 3 1B → server (`/api/v1/ai/chat`)

**Tier detection (at first launch):**

```
if (totalRAM >= 8GB && storageFree > 4GB) → Gemma 4 4B
else if (totalRAM >= 6GB && storageFree > 3GB) → Gemma 3 4B
else if (totalRAM >= 4GB) → Gemma 3 1B
else → server fallback (requires network)
```

**Persona:** see `core/ai/prompts.dart` — cute, polite Thai female assistant with "ค่ะ/คะ/นะคะ" style

**Use cases:**
- Home: smart recommendations based on history
- Product: summarize reviews, answer Q&A
- Wallet: spending insights
- Affiliate: tips for sharing

**Runtime:**
- MediaPipe LLM Inference (Android GPU delegate)
- Core ML + Neural Engine (iOS)
- Streaming token output via `Stream<String>`

**Licensing:** Gemma Terms of Use → commercial OK, attribution "Powered by Gemma" required in About screen

## 6. TTS — Piper (Thai voice)

**Engine:** `sherpa-onnx` via `sherpa_onnx_flutter` package
**Voice:** `th_TH-vaja-medium` (NECTEC, MIT-compatible)
**Size:** ~60MB, bundled with app
**Latency:** <200ms on-device
**Quality:** cute female Thai voice, appropriate for "น้องหญิง" persona

## 7. Analytics

**Client SDK (`core/analytics/`):**
- Queue events in `drift` local DB
- Batch flush every 30s OR when reaching 50 events OR on app background
- Events include: `screen_view`, `product_tap`, `search`, `cart_add`, `checkout`, `order_place`, `ai_query`
- Each event carries: `user_id`, `session_id`, `device_tier`, `app_ver`, `geohash5`, `ts`
- Retry with exponential backoff on network failure
- Respect consent state from onboarding

**Backend endpoint (to add):**
- `POST /api/v1/events/batch` — rate-limited, accepts array of events

## 8. Remote Config + Feature Flags

**Client:**
- Fetch on app launch + every 10 min when foregrounded
- Cache with ETag (no-bandwidth when unchanged)
- Flags: `ai_enabled`, `tts_enabled`, `wallet_topup_enabled`, `affiliate_enabled`, `new_ui_v2`

**Backend tables:**
- `app_configs` — global key/value
- `feature_flags` — targeted rollout (version/role/region/%)
- `app_menus` — dynamic menu items
- `app_sliders` — home hero slides with targeting

## 9. Security (per CLAUDE.md global rules)

- Sanctum token in `flutter_secure_storage` only — NEVER in SharedPreferences or plain storage
- Wallet PIN: never logged, validated constant-time via HMAC
- HTTPS only, cert pinning on `/api/v1/wallet/*` and `/auth/*` endpoints
- QR payloads validated: check PromptPay EMV-QR format + amount sanity check
- No private keys or mnemonics in code (we don't use crypto wallets per-user — backend custodial only)
- Log scrubber: strip token/pin/mnemonic from all logs before release
- Release build: `--obfuscate --split-debug-info`
- Rate limiting: respect backend `429` responses, exponential backoff
- GPS: request permission with clear rationale; geohash-5 for analytics (5km), geohash-7 only for active order delivery

## 10. Delivery Phases

**Phase 1 (current):** Foundation
- Scaffold + theme + API client + auth + Onboarding + Home screen

**Phase 2:** Core commerce
- Product + Shop + Cart + Orders + Tracking + Chat

**Phase 3:** Money
- Wallet (topup, transfer w/ PIN, QR scan/display) + Affiliate dashboard

**Phase 4:** Intelligence
- Analytics SDK + Remote Config + Feature Flags

**Phase 5:** AI + Voice
- น้องหญิง (Gemma 4/3 tiered) + Piper TTS + floating chat UI

**Phase 6:** Backend patches (parallel with Phase 3-5)
- Admin UI for menu/slider/promotion/flag CRUD
- Analytics aggregation queries + dashboard
- `events/batch` endpoint
