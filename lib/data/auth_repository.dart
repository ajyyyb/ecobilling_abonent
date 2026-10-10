import 'package:dio/dio.dart';

import '../core/network/api_exception.dart';
import '../core/network/token_storage.dart';

const _residentRole = 'Resident';

class AuthRepository {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  AuthRepository(this._dio, this._tokenStorage);

  /// Logs in by account number. Throws [ApiException] on failure, including
  /// when the account authenticates but does not carry the Resident role.
  Future<void> login(String accountNumber, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'loginType': 'accountNumber',
        'login': accountNumber.trim(),
        'password': password,
      },
      options: Options(extra: {'skipAuth': true}),
    );

    final tokens = AuthTokens.fromJson(response.data!);
    if (tokens.role != _residentRole) {
      await _tokenStorage.clear();
      throw const ApiException(
        status: 403,
        detail: 'Эта учётная запись не относится к абоненту',
      );
    }
    await _tokenStorage.saveTokens(tokens);
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken != null) {
        await _dio.post<void>(
          '/auth/revoke',
          data: {'refreshToken': refreshToken},
        );
      }
    } catch (_) {
      // Best-effort: proceed to clear the local session regardless.
    }
    await _tokenStorage.clear();
  }

  /// True if a stored session looks usable (tokens present). The caller is
  /// expected to follow up with a real request to confirm it still works.
  Future<bool> hasStoredSession() async {
    final tokens = await _tokenStorage.readTokens();
    return tokens != null;
  }
}
