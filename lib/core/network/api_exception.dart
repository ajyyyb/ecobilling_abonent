import 'package:dio/dio.dart';

/// Represents an RFC 7807 `application/problem+json` error response,
/// or a local network/timeout condition that never reached the server.
class ApiException implements Exception {
  final int? status;
  final String? title;
  final String? detail;
  final String? code;
  final String? traceId;
  final ApiExceptionKind kind;

  const ApiException({
    this.status,
    this.title,
    this.detail,
    this.code,
    this.traceId,
    this.kind = ApiExceptionKind.server,
  });

  factory ApiException.network() =>
      const ApiException(kind: ApiExceptionKind.network);

  factory ApiException.timeout() =>
      const ApiException(kind: ApiExceptionKind.timeout);

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionError:
        return ApiException.network();
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException.timeout();
      default:
        break;
    }

    final response = error.response;
    if (response == null) {
      return ApiException.network();
    }

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ApiException(
        status: (data['status'] as num?)?.toInt() ?? response.statusCode,
        title: data['title'] as String?,
        detail: data['detail'] as String?,
        code: data['code'] as String?,
        traceId: data['traceId'] as String?,
      );
    }

    return ApiException(status: response.statusCode);
  }

  @override
  String toString() =>
      'ApiException(kind: $kind, status: $status, code: $code, '
      'title: $title, traceId: $traceId)';
}

enum ApiExceptionKind { network, timeout, server }

/// Maps an [ApiException] to a short, user-facing Russian message.
/// `code`/`traceId` are intentionally not shown to the user — they are
/// logged separately for diagnostics.
String apiErrorMessage(ApiException e) {
  switch (e.kind) {
    case ApiExceptionKind.network:
      return 'Нет подключения к интернету';
    case ApiExceptionKind.timeout:
      return 'Сервер не отвечает. Попробуйте снова';
    case ApiExceptionKind.server:
      break;
  }

  switch (e.status) {
    case 400:
      return e.detail ?? 'Некорректные данные запроса';
    case 401:
      return 'Сессия истекла. Войдите снова';
    case 403:
      return 'Нет доступа для выполнения этого действия';
    case 404:
      return 'Запрашиваемые данные не найдены';
    case 409:
      return 'Конфликт данных. Обновите страницу и попробуйте снова';
    case 429:
      return 'Слишком много запросов. Подождите немного';
    case 500:
      return 'Ошибка сервера. Попробуйте позже';
    default:
      return e.detail ?? e.title ?? 'Не удалось выполнить запрос';
  }
}
