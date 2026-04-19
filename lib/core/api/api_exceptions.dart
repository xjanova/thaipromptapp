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
  String serverMsg() {
    if (data is Map && data['message'] is String) return data['message'] as String;
    return '';
  }

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

Map<String, List<String>>? _parseErrors(dynamic data) {
  if (data is! Map) return null;
  final errs = data['errors'];
  if (errs is! Map) return null;
  return {
    for (final e in errs.entries)
      e.key.toString(): (e.value is List)
          ? (e.value as List).map((x) => x.toString()).toList()
          : [e.value.toString()],
  };
}
