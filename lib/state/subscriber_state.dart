import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentRecord {
  PaymentRecord({
    required this.date,
    required this.amount,
    required this.id,
    this.paid = true,
  });
  final DateTime date;
  final int amount;
  final String id;
  final bool paid;
}

class SubscriberUiState extends ChangeNotifier {
  String firstName = 'Нурбек';
  String lastName = 'Асанов';
  String phone = '+996 555 12 34 56';
  final String accountNumber = '001245';
  final String address = 'г. Бишкек, ул. Манас 19';
  final String meterNumber = 'W-445982';
  int previousReading = 125;
  int currentReading = 132;
  int currentBill = 580;
  String language = 'Русский';
  bool paymentReminders = true;
  bool smsNotifications = true;
  bool pushNotifications = true;
  bool settingsLoaded = false;
  final List<PaymentRecord> paymentHistory = [
    PaymentRecord(
      date: DateTime(2026, 8, 25),
      amount: 290,
      id: 'TXN-2026-000123',
    ),
    PaymentRecord(
      date: DateTime(2026, 7, 25),
      amount: 310,
      id: 'TXN-2026-000108',
    ),
    PaymentRecord(
      date: DateTime(2026, 6, 25),
      amount: 280,
      id: 'TXN-2026-000094',
    ),
  ];

  int get monthlyUsage => (currentReading - previousReading).clamp(0, 999999);
  String get fullName => '$lastName $firstName';
  String get initials =>
      '${firstName.substring(0, 1)}${lastName.substring(0, 1)}';

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

  void saveProfile({
    required String first,
    required String last,
    required String newPhone,
  }) {
    firstName = first.trim();
    lastName = last.trim();
    phone = newPhone.trim();
    notifyListeners();
  }

  void saveReading(int value) {
    previousReading = currentReading;
    currentReading = value;
    notifyListeners();
  }

  void completePayment() {
    if (currentBill > 0) {
      final amount = currentBill;
      final now = DateTime.now();
      paymentHistory.insert(
        0,
        PaymentRecord(
          date: now,
          amount: amount,
          id: 'TXN-${now.year}-${(paymentHistory.length + 124).toString().padLeft(6, '0')}',
        ),
      );
      currentBill = 0;
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
