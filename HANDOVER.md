# Thaiprompt · Handover (2026-04-19)

Status snapshot for the next person picking this up.

## Repos

| Repo | Branch | Notes |
|---|---|---|
| [xjanova/thaipromptapp](https://github.com/xjanova/thaipromptapp) | `main` | Flutter 3.41.7 · v1.0.1 released (signed) |
| [xjanova/Thaiprompt-Affiliate](https://github.com/xjanova/Thaiprompt-Affiliate) | `feature/mobile-app-patches` | **PR [#2534](https://github.com/xjanova/Thaiprompt-Affiliate/pull/2534)** — awaiting merge |

## Phases landed

- **Phase 1** — scaffold, theme, API client, auth, 5 screens
- **Phase 2** — Product / Shop / Cart / Tracking / Chat screens + routing
- **Phase 3** — Wallet (dark hero + QR + chart + history) · Affiliate (tier + earnings + invite) · PIN (HMAC+salt, constant-time) · auto-update (APK download + progress + changelog) · CI/CD (APK + AAB on tag)
- **Phase 4** — Remote Config (ETag, 10-min poll) · Feature Flags · Analytics SDK (session + queue + batch flush) · Geohash privacy · Consent sheet
- **Phase 5** — น้องหญิง AI (engine interface + tier-aware selection + server fallback)
- **Phase 5.2** — Real on-device Gemma via flutter_gemma 0.13 · Gemini TTS via just_audio · **User-initiated install from Settings** (never bundled in APK) · TTS router with quota fallback to Piper
- **Phase 6 (initial)** — Unit tests: ReplySanitizer, PinService, Geohash · Security audit passed (no hardcoded secrets, no unguarded debug prints, cleartext disabled, obfuscated release)

## Product rules (hard-coded, user-decreed)

1. น้องหญิง is **female** — the system prompt forbids `ครับ/ผม/กระผม` with explicit positive/negative examples on both the client and backend. The client also runs a `ReplySanitizer` over the streaming tokens as a safety net.
2. TTS only fires when the user **taps "ฟังเสียง"** on a specific chat bubble. There is NO auto-speak code path.
3. When Gemini TTS returns **429/403** (quota) or a network error, `TtsRouter` flips to Piper for the rest of the session. Flag resets on process restart.
4. Gemma weights and Piper voice files are **downloaded from Settings** only. They are never bundled into the APK. Progress bars with percentages are required.
5. Male TTS voices are not exposed — list of allowed voices is enforced server-side in `AiTtsApiController`.

## Backend PR [#2534](https://github.com/xjanova/Thaiprompt-Affiliate/pull/2534) — what it contains

| File | Purpose |
|---|---|
| `database/migrations/2026_04_19_10000{0..8}_*.php` | 9 new tables: app_configs, feature_flags, app_menus, app_sliders, promotions, app_events, app_sessions, product_impressions, app_releases |
| `app/Http/Controllers/Api/V1/AppConfigApiController.php` | `GET /v1/app/config` + `/flags` (ETag cache) |
| `app/Http/Controllers/Api/V1/AppMenuApiController.php` | `GET /v1/app/menus` + `/sliders` + `/promotions` |
| `app/Http/Controllers/Api/V1/AnalyticsApiController.php` | `POST /v1/events/batch` (consent-aware, geohash-privacy safe) |
| `app/Http/Controllers/Api/V1/AiChatApiController.php` | `POST /v1/ai/chat` — Gemini / Claude / OpenAI selectable via env; **strict female persona** |
| `app/Http/Controllers/Api/V1/AiTtsApiController.php` | `POST /v1/ai/tts` — Gemini 3.1 Native Audio, female voices only |
| `app/Http/Controllers/Api/V1/AppReleaseApiController.php` | `GET /v1/app/latest-version` — drives in-app auto-update |
| `database/seeders/AppConfigSeeder.php` | Seeds the remote config keys the client reads (Gemma model ids, Piper URLs, wallet limits) |
| `database/seeders/FeatureFlagSeeder.php` | Seeds the flag rows (defaults mostly OFF) |
| `routes/api.php` (+16 lines) | Wires the 6 public + 3 protected routes |

## To merge + deploy

1. **Code review + merge** [PR #2534](https://github.com/xjanova/Thaiprompt-Affiliate/pull/2534)
2. `php artisan migrate`
3. `php artisan db:seed --class=AppConfigSeeder`
4. `php artisan db:seed --class=FeatureFlagSeeder`
5. Set env (optional):
   ```
   AI_PROVIDER=gemini
   GEMINI_API_KEY=...          # also powers /v1/ai/tts
   AI_MODEL_GEMINI=gemini-2.5-flash
   AI_TTS_MODEL=gemini-2.5-flash-preview-tts
   ```
6. Flip feature flags via admin UI when each feature is ready:
   - `ai_enabled` → true when Gemini API key is in place
   - `tts_enabled` → true after verifying voice quality
   - `wallet_transfer_enabled` → true after PIN flow is QA'd in staging
7. Upload the 3 Gemma model URLs to the CDN and fill `ai_model_url_gemma4 / gemma3_4b / gemma3_1b` in `app_configs`
8. Host a Piper Thai voice on the CDN and fill `tts_piper_model_url` + `tts_piper_tokens_url`

## Known follow-ups (not blocking release)

- **Admin CRUD UI** for `app_configs / feature_flags / app_menus / app_sliders / promotions / app_releases` — reuse the existing `AppBannerController` pattern. Not in PR #2534 to keep the diff surgical.
- **`AnalyticsCleanupCommand`** — scheduled artisan task that deletes `app_events` rows older than 180 days. Worth adding before prod launch.
- **GitHub Release webhook** → populate `app_releases` automatically. Reuse existing `/api/webhooks/github/release` endpoint.
- **flutter_gemma on iOS** requires deployment target 16.0 — already bumped in `ios/Runner.xcodeproj`.
- **Golden tests** for each screen. Phase 6 currently covers unit tests for the risky security helpers; widget goldens are TODO.
- **drift/freezed** were dropped in Phase 5.2 because they pinned `sqlite3 < 3.0` (conflicted with flutter_gemma). Re-introduce under a `build_runner ^3` upgrade when codegen is actually needed; models are hand-written in `lib/shared/models/` today and pass `flutter analyze`.

## Release signing

- Upload keystore: `D:/Code/thaipromptapp/upload-keystore.jks` (local, git-ignored)
- Passwords: `D:/Code/thaipromptapp/keystore-info.txt` (local, git-ignored)
- **Back up BOTH** — loss = can't ship updates on Play Store ever.
- GitHub Actions secrets (already set):
  `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`

## Releases

- [v1.0.0](https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.0) — initial 9 screens + wallet + affiliate + auto-update
- [v1.0.1](https://github.com/xjanova/thaipromptapp/releases/tag/v1.0.1) — น้องหญิง AI + TTS + Settings install

## Running locally

```bash
flutter run --dart-define=API_BASE_URL=https://your-backend.host/api
```

Or build a release APK:

```bash
flutter build apk --release \
  --obfuscate --split-debug-info=build/symbols \
  --build-name=1.0.1 --build-number=2
```
