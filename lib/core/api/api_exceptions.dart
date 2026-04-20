import 'package:dio/dio.dart';

/// App-facing exception hierarchy — isolate UI from Dio specifics.
sealed class ApiException implements Exception {
  const ApiException(this.message, {this.cause, this.statusCode});

  final String message;
  final Object? cause;
  final int? statusCode;

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException([String msg = 'ไม่มีสัญญาณอินเทอร์เน็ต · ตรวจสอบการเชื่อมต่อ'])
      : super(msg);
}

class TimeoutException extends ApiException {
  const TimeoutException([String msg = 'เซิร์ฟเวอร์ตอบกลับช้าเกินไป · ลองใหม่อีกครั้ง'])
      : super(msg);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([String msg = 'เซสชันหมดอายุ กรุณาเข้าสู่ระบบอีกครั้ง'])
      : super(msg, statusCode: 401);
}

class ForbiddenException extends ApiException {
  const ForbiddenException([String msg = 'คุณไม่มีสิทธิ์ทำรายการนี้'])
      : super(msg, statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException([String msg = 'ไม่พบข้อมูลที่ต้องการ'])
      : super(msg, statusCode: 404);
}

class ValidationException extends ApiException {
  const ValidationException(String msg, {this.errors})
      : super(msg, statusCode: 422);
  final Map<String, List<String>>? errors;
}

class RateLimitException extends ApiException {
  const RateLimitException([String msg = 'มีการทำรายการถี่เกินไป · โปรดลองใหม่ในอีกสักครู่'])
      : super(msg, statusCode: 429);
}

class ServerException extends ApiException {
  const ServerException([String msg = 'ขออภัย ระบบกำลังมีปัญหา · โปรดลองใหม่'])
      : super(msg);
}

/// Map a Dio error to a concrete [ApiException].
ApiException mapDioError(DioException e) {
  final code = e.response?.statusCode;
  final data = e.response?.data;
  String rawServerMsg() {
    if (data is Map && data['message'] is String) return data['message'] as String;
    return '';
  }

  String serverMsg() => _localize(rawServerMsg());

  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout =>
      const TimeoutException(),
    DioExceptionType.connectionError ||
    DioExceptionType.unknown =>
      const NetworkException(),
    DioExceptionType.cancel => NetworkException(serverMsg().isEmpty ? 'ยกเลิกคำขอแล้ว' : serverMsg()),
    DioExceptionType.badCertificate => const NetworkException('การเชื่อมต่อไม่ปลอดภัย'),
    DioExceptionType.badResponse => switch (code) {
        401 => UnauthorizedException(serverMsg().isEmpty
            ? 'เซสชันหมดอายุ กรุณาเข้าสู่ระบบอีกครั้ง'
            : serverMsg()),
        403 => ForbiddenException(serverMsg().isEmpty
            ? 'คุณไม่มีสิทธิ์ทำรายการนี้'
            : serverMsg()),
        404 => NotFoundException(serverMsg().isEmpty
            ? 'ไม่พบข้อมูลที่ต้องการ'
            : serverMsg()),
        422 => ValidationException(
            serverMsg().isEmpty ? 'ข้อมูลไม่ถูกต้อง' : serverMsg(),
            errors: _parseErrors(data),
          ),
        429 => const RateLimitException(),
        500 || 502 || 503 || 504 => ServerException(serverMsg().isEmpty
            ? 'ขออภัย ระบบกำลังมีปัญหา · โปรดลองใหม่'
            : serverMsg()),
        _ => ServerException(serverMsg().isEmpty
            ? 'เกิดข้อผิดพลาด (${code ?? '-'})'
            : serverMsg()),
      },
  };
}

/// Translate known English messages from Laravel's default validator /
/// auth responses to Thai. If no match is found, return the original
/// so backend-localized strings (most of our endpoints already respond
/// in Thai) pass through untouched.
///
/// Backend is Laravel 11: default messages come from
/// `vendor/laravel/framework/.../lang/en/auth.php` +
/// `validation.php`. Some endpoints override with Thai messages, some
/// fall back to English (especially Sanctum login's built-in
/// "The provided credentials are incorrect.").
String _localize(String s) {
  if (s.isEmpty) return s;
  // Already Thai? Don't touch. (Any Thai character in the message
  // means the backend already localized it.)
  for (final code in s.runes) {
    if (code >= 0x0E00 && code <= 0x0E7F) return s;
  }
  final lower = s.toLowerCase();

  if (lower.contains('credentials are incorrect') ||
      lower.contains('invalid credentials') ||
      lower.contains('these credentials do not match')) {
    return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
  }
  if (lower.contains('too many') && lower.contains('attempt')) {
    return 'พยายามเข้าระบบถี่เกินไป · รอสักครู่แล้วลองใหม่นะคะ';
  }
  if (lower.contains('email field is required')) {
    return 'กรุณากรอกอีเมล';
  }
  if (lower.contains('password field is required')) {
    return 'กรุณากรอกรหัสผ่าน';
  }
  if (lower.contains('email') && lower.contains('already been taken')) {
    return 'อีเมลนี้ถูกใช้ไปแล้ว · ลองเข้าสู่ระบบแทน';
  }
  if (lower.contains('password') && lower.contains('confirmation')) {
    return 'รหัสผ่านยืนยันไม่ตรงกัน';
  }
  if (lower.contains('email must be a valid')) {
    return 'รูปแบบอีเมลไม่ถูกต้อง';
  }
  if (lower.contains('unauthenticated')) {
    return 'เซสชันหมดอายุ กรุณาเข้าสู่ระบบอีกครั้ง';
  }
  return s;
}

Map<String, List<String>>? _parseErrors(dynamic data) {
  if (data is! Map) return null;
  final errs = data['errors'];
  if (errs is! Map) return null;
  return {
    for (final e in errs.entries)
      e.key.toString(): (e.value is List)
          ? (e.value as List).map((x) => _localize(x.toString())).toList()
          : [_localize(e.value.toString())],
  };
}
