# Thaiprompt Roadmap

> Phase 1 landed (this repo is now bootable). Subsequent phases below.

## Phase 1 — Foundation ✅ (2026-04-19)

- [x] Flutter 3.38 scaffold, Android + iOS targets
- [x] Riverpod + go_router + Dio + drift + sherpa wiring in pubspec
- [x] Design tokens (`lib/core/theme/`) matching `styles.css`
  - Colors, radii, clay shadows, text styles, gradients
- [x] API client with Sanctum Bearer token, retry, typed exceptions
- [x] Auth flow: login, register, token storage, `/v1/me` bootstrap
- [x] Shared widgets: ClayCard, PuffyButton, Blob3D, Puff, Coin, IsoStall, NavDock, Marquee, SectionHeader, TpChip, FloorShadow
- [x] Screens: Splash, Onboarding, Login, Register, Home
- [x] Backend patch files (migrations + controllers + route additions)
- [x] `flutter analyze` passes with zero errors

## Phase 2 — Commerce (7-10 days)

Screens — port remaining 5 prototype screens + CRUD bindings:

- [ ] **Product** (`features/product/`) — `GET /v1/products/{id}`, add-to-cart, affiliate share
- [ ] **Shop** (`features/shop/`) — tabs (products, reviews, promotions), follow/chat CTAs
- [ ] **Cart** (`features/cart/`) — add/update/remove, promo code, PromptPay on-hand
- [ ] **Orders + Tracking** (`features/tracking/`) — map with 3D-style polyline + timeline
- [ ] **Chat** (`features/chat/`) — order messages, product pinning

Core helpers to finalise:
- [ ] `drift` schema for offline cart snapshot + order cache
- [ ] `freezed` migration for Product, Cart, Order, Message models + `build_runner`

## Phase 3 — Money (5-7 days)

- [ ] **Wallet** — hero card, balance, top-up (PromptPay QR + bank), withdraw, transactions
- [ ] **Transfer** — recipient lookup via `/v1/wallet/lookup` + PIN confirmation
- [ ] **PIN** — 6-digit lock screen, secure storage with HMAC (constant-time verify)
- [ ] **QR scan/display** — PromptPay EMV-QR format validator
- [ ] **Affiliate** — tiered display (Silver/Gold/…), monthly revenue chart, top-earning links, invite friends

## Phase 4 — Intelligence (3-5 days)

- [ ] **Remote Config SDK** (`lib/core/remote_config/`) — ETag cache, 10-min refresh, typed accessors
- [ ] **Feature flags SDK** — provider + `flagEnabled('ai_enabled')` helper
- [ ] **Analytics SDK** — queue in drift, batch flush 30s/50-events/on-background, retry + backoff
- [ ] **Location service** — `geolocator` + geohash-5 (5km) for home; geohash-7 (150m) only during active orders
- [ ] **Consent flow** — privacy prompt in onboarding with clear "ทำไมต้องขอ" explanation

Backend side:
- [ ] Admin CRUD UI (Blade) for `app_configs`, `feature_flags`, `app_menus`, `app_sliders`, `promotions`
- [ ] Analytics dashboard (heatmap + funnel + segments) — reuse existing `admin/analytics` prefix
- [ ] `php artisan app:cleanup-analytics` command (180-day TTL on `app_events`)

## Phase 5 — AI น้องหญิง + TTS (4-7 days)

### AI
- [ ] **Model manager** (`lib/core/ai/model_manager.dart`)
  - Tier detection: RAM, storage, GPU capability (`device_info_plus`)
  - First-launch download: Gemma 4 (~2.5GB) OR Gemma 3 4B OR Gemma 3 1B
  - Progress UI with cancellation
- [ ] **Chat service** (`lib/core/ai/nong_ying_service.dart`)
  - MediaPipe LLM Inference backend (Android GPU delegate)
  - Core ML Neural Engine on iOS
  - Streaming token output via `Stream<String>`
- [ ] **System prompt** (`lib/core/ai/prompts.dart`) — persona + safety rails (keep in sync with backend `AiChatApiController::systemPrompt`)
- [ ] **Fallback** — route to `/v1/ai/chat` when on-device unavailable or model download fails

### UI
- [ ] Floating AI button (`features/nong_ying/floating_button.dart`) — accessible from every screen
- [ ] Chat page with Thai input, rich markdown-ish replies, voice-play button
- [ ] Context injection: user profile + current screen (Home/Product/Cart/etc.) into the prompt

### TTS (Piper via sherpa-onnx)
- [ ] Bundle `th_TH-vaja-medium` voice (~60MB) under `assets/tts/`
- [ ] `tts_service.dart` — initialise on cold start, warm cache for common phrases
- [ ] Integrate with น้องหญิง: tap speaker icon on any assistant reply → play
- [ ] Respect system "silent mode" + offer toggle in settings

## Phase 6 — Hardening & Launch (ongoing)

Tests:
- [ ] Widget tests for 9 screens (golden images via `alchemist` or `golden_toolkit`)
- [ ] Integration test for full login → add-to-cart → checkout flow
- [ ] Unit tests for API client, token storage, feature flag evaluation

Security audit (per `C:/Users/xman/.claude/CLAUDE.md` §B):
- [ ] Confirm no hardcoded secrets (`grep -r "API_KEY\|SECRET"`)
- [ ] Log scrubber — verify token/PIN never in release logs
- [ ] Constant-time PIN comparison implemented
- [ ] Rate limiting honored on all `/v1/wallet/*` calls
- [ ] Cert pinning on wallet + auth endpoints
- [ ] Release build uses `--obfuscate --split-debug-info`
- [ ] APK reverse-engineering smoke test (JADX scan)

Release:
- [ ] Gemma license attribution in About screen
- [ ] PDPA-compliant privacy policy link
- [ ] Internal testing via Firebase App Distribution (Android) + TestFlight (iOS)
- [ ] Store listings: screenshots from 9 screens, Thai + English descriptions

---

## Known gaps / decisions deferred

- **Payment rails:** currently using backend's existing PromptPay flow. Card + TrueMoney + PayPal pathways exist server-side — surface in Wallet when business decides rollout order
- **Multi-language:** Thai-first; EN toggle exists in prototype tweaks panel. Full i18n (`l10n/`) deferred to Phase 6
- **Push notifications:** not in prototype; would need Firebase Cloud Messaging + backend `FcmToken` registration endpoint
- **Deep links:** `tp://product/123` scheme designed but not registered yet (AndroidManifest intent filter + iOS Associated Domains)
- **Offline mode:** drift caches planned for cart + last-seen products; full offline browsing is out of scope
