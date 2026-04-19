# Thaiprompt Backend Patches

Files to add to [`xjanova/Thaiprompt-Affiliate`](https://github.com/xjanova/Thaiprompt-Affiliate) to support the new Flutter app.

## Scope

These patches add **four new backend capabilities**:

1. **Remote Config & Feature Flags** — dynamic control from admin without releasing a new app
2. **Dynamic Menus & Sliders** — promote content without code changes
3. **Analytics Ingestion** — collect events, GPS, product impressions, funnels
4. **AI Chat Fallback** — for devices that can't run Gemma on-device

Each patch lands in three files:
- `database/migrations/YYYY_MM_DD_######_*.php`
- `app/Http/Controllers/Api/V1/*.php`
- Route additions in `routes/api.php`

## How to apply

1. Copy each file from `migrations/` into `database/migrations/` on the backend repo
2. Copy each file from `controllers/` into `app/Http/Controllers/Api/V1/`
3. Merge the route snippets from `routes/api_additions.php` into the existing `routes/api.php`
4. `php artisan migrate` on the backend
5. Create admin CRUD pages (Blade or Vue) — templates not provided here; see your existing AppBannerController as reference

## Files in this patch

| File | Purpose |
|---|---|
| `migrations/2026_04_19_100000_create_app_configs_table.php` | key/value remote config |
| `migrations/2026_04_19_100001_create_feature_flags_table.php` | targeted feature flags |
| `migrations/2026_04_19_100002_create_app_menus_table.php` | dynamic menus |
| `migrations/2026_04_19_100003_create_app_sliders_table.php` | home sliders |
| `migrations/2026_04_19_100004_create_promotions_table.php` | promo campaigns |
| `migrations/2026_04_19_100005_create_app_events_table.php` | analytics events |
| `migrations/2026_04_19_100006_create_app_sessions_table.php` | session tracking |
| `migrations/2026_04_19_100007_create_product_impressions_table.php` | per-impression detail |
| `controllers/AppConfigApiController.php` | GET /config, /flags |
| `controllers/AppMenuApiController.php` | GET /menus, /sliders, /promotions |
| `controllers/AnalyticsApiController.php` | POST /events/batch |
| `controllers/AiChatApiController.php` | POST /ai/chat (fallback when on-device unavailable) |
| `routes/api_additions.php` | route snippets to merge |

## PDPA / Privacy

- GPS: store **geohash-5** (5km precision) for analytics, **geohash-7** (150m) only for active orders
- Events: respect `analytics_consent` flag on user — skip when false
- Retention: raw events auto-delete after 180 days via scheduled artisan job (see `AnalyticsCleanupCommand` hint in controller)
