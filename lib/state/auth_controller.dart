import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/network/token_storage.dart';
import '../data/auth_repository.dart';

class AuthController extends ChangeNotifier {
  late final TokenStorage tokenStorage;
  late final AuthRepository _repository;
  late final Dio dio;

  bool isBootstrapping = true;
  bool isAuthenticated = false;
  bool isLoading = false;
  String? accountNumber;
  String? errorMessage;

  /// Set by the root widget to kick off the resident data load right after
  /// a session becomes authenticated (fresh login or restored on startup).
  VoidCallback? onAuthenticated;

  AuthController({TokenStorage? tokenStorage, AuthRepository? repository}) {
    this.tokenStorage = tokenStorage ?? TokenStorage();
    dio = buildApiClient(
      tokenStorage: this.tokenStorage,
      onSessionExpired: _handleSessionExpired,
    );
    _repository = repository ?? AuthRepository(dio, this.tokenStorage);
  }

  void _handleSessionExpired() {
    isAuthenticated = false;
    errorMessage = 'Сессия истекла. Войдите снова';
    notifyListeners();
  }

  Future<void> restoreSession() async {
    isAuthenticated = await _repository.hasStoredSession();
    isBootstrapping = false;
    notifyListeners();
    if (isAuthenticated) onAuthenticated?.call();
  }

  Future<bool> login(String accountNumber, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repository.login(accountNumber, password);
      this.accountNumber = accountNumber.trim();
      isAuthenticated = true;
      isLoading = false;
      notifyListeners();
      onAuthenticated?.call();
      return true;
    } on ApiException catch (e) {
      isLoading = false;
      errorMessage = apiErrorMessage(e);
      notifyListeners();
      return false;
    } catch (_) {
      isLoading = false;
      errorMessage = 'Ошибка авторизации. Попробуйте снова.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();
    await _repository.logout();
    isAuthenticated = false;
    isLoading = false;
    accountNumber = null;
    notifyListeners();
  }
}

class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  static AuthController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope is missing above this context');
    return scope!.notifier!;
  }
}
