import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokens {
  final String tokenType;
  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;
  final String role;

  const AuthTokens({
    required this.tokenType,
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.role,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
    tokenType: json['tokenType'] as String,
    accessToken: json['accessToken'] as String,
    accessTokenExpiresAt: DateTime.parse(
      json['accessTokenExpiresAt'] as String,
    ),
    refreshToken: json['refreshToken'] as String,
    refreshTokenExpiresAt: DateTime.parse(
      json['refreshTokenExpiresAt'] as String,
    ),
    role: json['role'] as String,
  );
}

/// Secure, persistent storage for auth tokens. Never keep these in
/// SharedPreferences — access and refresh tokens only live here.
class TokenStorage {
  static const _keyTokenType = 'auth_token_type';
  static const _keyAccessToken = 'auth_access_token';
  static const _keyAccessTokenExpiresAt = 'auth_access_token_expires_at';
  static const _keyRefreshToken = 'auth_refresh_token';
  static const _keyRefreshTokenExpiresAt = 'auth_refresh_token_expires_at';
  static const _keyRole = 'auth_role';

  final FlutterSecureStorage _storage;

  TokenStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveTokens(AuthTokens tokens) async {
    await Future.wait([
      _storage.write(key: _keyTokenType, value: tokens.tokenType),
      _storage.write(key: _keyAccessToken, value: tokens.accessToken),
      _storage.write(
        key: _keyAccessTokenExpiresAt,
        value: tokens.accessTokenExpiresAt.toIso8601String(),
      ),
      _storage.write(key: _keyRefreshToken, value: tokens.refreshToken),
      _storage.write(
        key: _keyRefreshTokenExpiresAt,
        value: tokens.refreshTokenExpiresAt.toIso8601String(),
      ),
      _storage.write(key: _keyRole, value: tokens.role),
    ]);
  }

  Future<AuthTokens?> readTokens() async {
    final values = await Future.wait([
      _storage.read(key: _keyTokenType),
      _storage.read(key: _keyAccessToken),
      _storage.read(key: _keyAccessTokenExpiresAt),
      _storage.read(key: _keyRefreshToken),
      _storage.read(key: _keyRefreshTokenExpiresAt),
      _storage.read(key: _keyRole),
    ]);

    final tokenType = values[0];
    final accessToken = values[1];
    final accessTokenExpiresAt = values[2];
    final refreshToken = values[3];
    final refreshTokenExpiresAt = values[4];
    final role = values[5];

    if (tokenType == null ||
        accessToken == null ||
        accessTokenExpiresAt == null ||
        refreshToken == null ||
        refreshTokenExpiresAt == null ||
        role == null) {
      return null;
    }

    return AuthTokens(
      tokenType: tokenType,
      accessToken: accessToken,
      accessTokenExpiresAt: DateTime.parse(accessTokenExpiresAt),
      refreshToken: refreshToken,
      refreshTokenExpiresAt: DateTime.parse(refreshTokenExpiresAt),
      role: role,
    );
  }

  Future<String?> readAccessToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  Future<String?> readRefreshToken() async {
    return _storage.read(key: _keyRefreshToken);
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _keyTokenType),
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyAccessTokenExpiresAt),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyRefreshTokenExpiresAt),
      _storage.delete(key: _keyRole),
    ]);
  }
}
