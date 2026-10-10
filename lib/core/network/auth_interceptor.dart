import 'dart:async';

import 'package:dio/dio.dart';

import 'token_storage.dart';

/// Attaches the bearer access token to every request and, on a single 401,
/// performs one `/auth/refresh` call and retries the original request once.
/// Concurrent 401s share the same in-flight refresh via [_refreshCompleter]
/// so a burst of requests never triggers more than one refresh call.
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  final Future<AuthTokens?> Function(String refreshToken) _refresh;
  final void Function() _onSessionExpired;

  Completer<bool>? _refreshCompleter;

  AuthInterceptor({
    required Dio dio,
    required TokenStorage tokenStorage,
    required Future<AuthTokens?> Function(String refreshToken) refresh,
    required void Function() onSessionExpired,
  }) : _dio = dio,
       _tokenStorage = tokenStorage,
       _refresh = refresh,
       _onSessionExpired = onSessionExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] != true) {
      final token = await _tokenStorage.readAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;
    final skipAuth = err.requestOptions.extra['skipAuth'] == true;

    if (response?.statusCode != 401 || alreadyRetried || skipAuth) {
      handler.next(err);
      return;
    }

    final refreshed = await _refreshOnce();
    if (!refreshed) {
      handler.next(err);
      return;
    }

    try {
      final retryOptions = err.requestOptions;
      retryOptions.extra['retried'] = true;
      final token = await _tokenStorage.readAccessToken();
      if (token != null) {
        retryOptions.headers['Authorization'] = 'Bearer $token';
      }
      final response = await _dio.fetch(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<bool> _refreshOnce() async {
    final inFlight = _refreshCompleter;
    if (inFlight != null) {
      return inFlight.future;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken == null) {
        await _tokenStorage.clear();
        _onSessionExpired();
        completer.complete(false);
        return false;
      }

      final newTokens = await _refresh(refreshToken);
      if (newTokens == null) {
        await _tokenStorage.clear();
        _onSessionExpired();
        completer.complete(false);
        return false;
      }

      await _tokenStorage.saveTokens(newTokens);
      completer.complete(true);
      return true;
    } catch (_) {
      await _tokenStorage.clear();
      _onSessionExpired();
      completer.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}
