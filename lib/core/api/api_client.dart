import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../auth/token_storage.dart';
import 'api_exceptions.dart';

/// Primary HTTP client for talking to the Thaiprompt backend.
///
/// Responsibilities:
/// - Attach Sanctum Bearer token to every outbound request.
/// - Add `X-App-Version`, `X-Device-Platform` so backend can target flags.
/// - Map transport errors → [ApiException] hierarchy for predictable UI.
/// - Auto-retry idempotent GETs on transient network failures.
/// - On 401, clear token + notify auth state (handled by AuthRepository).
class ApiClient {
  ApiClient._(this._dio, this.tokenStorage);

  final Dio _dio;
  final TokenStorage tokenStorage;

  Dio get dio => _dio;

  static Future<ApiClient> create({
    required String baseUrl,
    required TokenStorage tokenStorage,
  }) async {
    final pkg = await PackageInfo.fromPlatform();

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-App-Version': '${pkg.version}+${pkg.buildNumber}',
          'X-Device-Platform': Platform.isIOS ? 'ios' : 'android',
        },
        validateStatus: (s) => s != null && s < 500, // 5xx → throw
      ),
    );

    // --- Interceptors ----------------------------------------------------
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) {
          if (e.response?.statusCode == 401) {
            // Fire-and-forget token wipe; AuthController listens to route.
            unawaited(tokenStorage.deleteToken());
          }
          handler.next(e);
        },
      ),
    );

    // Smart retry for network blips (GET only, 3 attempts).
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        retries: 3,
        retryDelays: const [
          Duration(milliseconds: 500),
          Duration(seconds: 1),
          Duration(seconds: 3),
        ],
        retryEvaluator: (err, attempt) {
          if (err.requestOptions.method != 'GET') return false;
          return err.type == DioExceptionType.connectionError ||
              err.type == DioExceptionType.connectionTimeout ||
              err.type == DioExceptionType.receiveTimeout;
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        compact: true,
        maxWidth: 120,
      ));
    }

    return ApiClient._(dio, tokenStorage);
  }

  // --- Shorthand request wrappers with typed error mapping ---------------

  Future<T> get<T>(String path, {Map<String, dynamic>? query, CancelToken? cancel}) =>
      _run(() => _dio.get<T>(path, queryParameters: query, cancelToken: cancel));

  Future<T> post<T>(String path, {Object? data, Map<String, dynamic>? query, CancelToken? cancel}) =>
      _run(() => _dio.post<T>(path, data: data, queryParameters: query, cancelToken: cancel));

  Future<T> put<T>(String path, {Object? data, CancelToken? cancel}) =>
      _run(() => _dio.put<T>(path, data: data, cancelToken: cancel));

  Future<T> delete<T>(String path, {Object? data, CancelToken? cancel}) =>
      _run(() => _dio.delete<T>(path, data: data, cancelToken: cancel));

  Future<T> _run<T>(Future<Response<T>> Function() action) async {
    try {
      final resp = await action();
      // 4xx (that we tolerated via validateStatus) must still become typed errors.
      final code = resp.statusCode ?? 0;
      if (code >= 400) {
        throw mapDioError(DioException(
          requestOptions: resp.requestOptions,
          response: resp,
          type: DioExceptionType.badResponse,
        ));
      }
      return resp.data as T;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Inject the compile-time API base URL via `--dart-define=API_BASE_URL=…`.
///
/// Default points at the production brand domain `thaiprompt.online`. The
/// host transparently 301s to the canonical `main.thaiprompt.online` (Dio
/// follows redirects automatically). For local/dev builds against a non-prod
/// backend, override via `--dart-define=API_BASE_URL=https://main.thaiprompt.online/api`
/// or your tunnel URL.
const _fallbackBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://thaiprompt.online/api',
);

final apiBaseUrlProvider = Provider<String>((_) => _fallbackBaseUrl);

final apiClientProvider = FutureProvider<ApiClient>((ref) async {
  final storage = ref.watch(tokenStorageProvider);
  final baseUrl = ref.watch(apiBaseUrlProvider);
  return ApiClient.create(baseUrl: baseUrl, tokenStorage: storage);
});

/// Fire-and-forget helper to avoid unawaited_futures lint.
void unawaited(Future<void> f) {}
