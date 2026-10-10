import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models.dart';
import '../data/resident_repository.dart';

class SubscriberUiState extends ChangeNotifier {
  final ResidentRepository _repository;

  SubscriberUiState(this._repository);

  ResidentProfile? profile;
  ResidentAccount? account;
  List<ResidentMeter> meters = [];
  List<ResidentReading> readings = [];
  List<ResidentCharge> charges = [];
  List<ResidentPayment> payments = [];
  ResidentFinancial? financial;

  bool isLoadingInitial = true;
  bool isRefreshing = false;
  String? loadError;

  // Local-only UI preferences; backend has no endpoint for these.
  String language = 'Русский';
  bool paymentReminders = true;
  bool smsNotifications = true;
  bool pushNotifications = true;
  bool settingsLoaded = false;

  String get fullName => profile?.fullName ?? '—';

  String get initials {
    final name = profile?.fullName.trim() ?? '';
    if (name.isEmpty) return '?';
    final parts = name
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }

  String get accountNumber => account?.accountNumber ?? '—';
  String get address => account?.address ?? '—';

  ResidentMeter? get primaryMeter {
    if (meters.isEmpty) return null;
    return meters.firstWhere((m) => m.isActive, orElse: () => meters.first);
  }

  List<ResidentReading> get primaryMeterReadings {
    final meter = primaryMeter;
    if (meter == null) return const [];
    final filtered = readings.where((r) => r.meterId == meter.meterId).toList()
      ..sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
    return filtered;
  }

  double get currentReading =>
      primaryMeterReadings.isNotEmpty ? primaryMeterReadings.first.value : 0;

  double get previousReading => primaryMeterReadings.length > 1
      ? primaryMeterReadings[1].value
      : currentReading;

  double get monthlyUsage =>
      (currentReading - previousReading).clamp(0, 999999);

  double get outstandingDebt => financial?.outstandingDebt ?? 0;
  double get overpayment => financial?.overpayment ?? 0;
  String get currency => financial?.currency ?? 'сом';

  List<ResidentCharge> get sortedCharges =>
      [...charges]..sort((a, b) => b.periodEnd.compareTo(a.periodEnd));

  List<ResidentPayment> get sortedPayments =>
      [...payments]..sort((a, b) => b.paidAt.compareTo(a.paidAt));

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    paymentReminders = prefs.getBool('paymentReminders') ?? true;
    smsNotifications = prefs.getBool('smsNotifications') ?? true;
    pushNotifications = prefs.getBool('pushNotifications') ?? true;
    language = prefs.getString('language') ?? 'Русский';
    settingsLoaded = true;
    notifyListeners();
  }

  Future<void> setNotification(String key, bool value) async {
    switch (key) {
      case 'paymentReminders':
        paymentReminders = value;
        break;
      case 'smsNotifications':
        smsNotifications = value;
        break;
      case 'pushNotifications':
        pushNotifications = value;
        break;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> setLanguage(String value) async {
    language = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
  }

  /// Initial load right after login/session restore, and pull-to-refresh.
  /// On failure the previously loaded data is kept on screen — only
  /// [loadError] is set so the UI can show a retry affordance.
  Future<void> loadAll() async {
    final isFirstLoad = profile == null;
    if (isFirstLoad) {
      isLoadingInitial = true;
    } else {
      isRefreshing = true;
    }
    loadError = null;
    notifyListeners();

    try {
      final data = await _repository.loadAll();
      profile = data.profile;
      account = data.account;
      meters = data.meters;
      readings = data.readings;
      charges = data.charges;
      payments = data.payments;
      financial = data.financial;
    } catch (e) {
      loadError =
          'Не удалось загрузить данные. Проверьте подключение к интернету';
    } finally {
      isLoadingInitial = false;
      isRefreshing = false;
      notifyListeners();
    }
  }
}

class SubscriberScope extends InheritedNotifier<SubscriberUiState> {
  const SubscriberScope({
    super.key,
    required SubscriberUiState state,
    required super.child,
  }) : super(notifier: state);

  static SubscriberUiState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SubscriberScope>();
    assert(scope != null, 'SubscriberScope is missing above this context');
    return scope!.notifier!;
  }
}
