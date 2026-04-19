<?php

/**
 * Route additions for the mobile app.
 *
 * Copy these snippets into `routes/api.php` inside the existing
 * `Route::prefix('v1')->group(function () { ... })` block.
 *
 * - PUBLIC routes: place BEFORE the `Route::middleware('auth:sanctum')` block
 * - PROTECTED routes: place inside the auth:sanctum group
 */

use App\Http\Controllers\Api\V1\AiChatApiController;
use App\Http\Controllers\Api\V1\AnalyticsApiController;
use App\Http\Controllers\Api\V1\AppConfigApiController;
use App\Http\Controllers\Api\V1\AppMenuApiController;
use App\Http\Controllers\Api\V1\AppReleaseApiController;
use Illuminate\Support\Facades\Route;

// ---------------------------------------------------------------------------
// PUBLIC (no auth required)
// ---------------------------------------------------------------------------

Route::prefix('app')->name('api.v1.app.')->group(function () {
    Route::get('/config',         [AppConfigApiController::class, 'config'])->name('config');
    Route::get('/flags',          [AppConfigApiController::class, 'flags'])->name('flags');
    Route::get('/menus',          [AppMenuApiController::class, 'menus'])->name('menus');
    Route::get('/sliders',        [AppMenuApiController::class, 'sliders'])->name('sliders');
    Route::get('/promotions',     [AppMenuApiController::class, 'promotions'])->name('promotions');
    Route::get('/latest-version', [AppReleaseApiController::class, 'latest'])->name('latest-version');
});

// ---------------------------------------------------------------------------
// PROTECTED (auth:sanctum) — place these inside the existing middleware group
// ---------------------------------------------------------------------------

// Analytics ingestion — per-user rate-limited
Route::post('/events/batch', [AnalyticsApiController::class, 'batch'])
    ->middleware('throttle:60,1')
    ->name('api.v1.events.batch');

// AI fallback chat — tighter rate limit
Route::post('/ai/chat', [AiChatApiController::class, 'chat'])
    ->middleware('throttle:20,1')
    ->name('api.v1.ai.chat');
