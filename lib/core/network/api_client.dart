import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';
import 'token_storage.dart';

class _LoggingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiError = err.error is ApiException
        ? err.error as ApiException
        : ApiException.fromDioError(err);
    developer.log(
      'API error: ${err.requestOptions.method} ${err.requestOptions.path}',
      name: 'network',
      error: apiError,
    );
    handler.next(err.copyWith(error: apiError));
  }
}

Future<AuthTokens?> _refreshTokens(Dio dio, String refreshToken) async {
  try {
    final response = await dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
      options: Options(extra: {'skipAuth': true}),
    );
    final data = response.data;
    if (data == null) return null;
    return AuthTokens.fromJson(data);
  } on DioException {
    return null;
  }
}

/// Builds the shared Dio instance: carries the bearer token, the
/// single-refresh-on-401 flow, and problem+json error parsing.
Dio buildApiClient({
  required TokenStorage tokenStorage,
  required void Function() onSessionExpired,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}',
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      contentType: 'application/json',
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(
      dio: dio,
      tokenStorage: tokenStorage,
      refresh: (refreshToken) => _refreshTokens(dio, refreshToken),
      onSessionExpired: onSessionExpired,
    ),
  );
  dio.interceptors.add(_LoggingInterceptor());

  return dio;
}
