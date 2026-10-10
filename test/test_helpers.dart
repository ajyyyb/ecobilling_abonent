import 'package:dio/dio.dart';
import 'package:ecobilling_abonent/core/network/token_storage.dart';
import 'package:ecobilling_abonent/data/auth_repository.dart';
import 'package:ecobilling_abonent/data/models.dart';
import 'package:ecobilling_abonent/data/resident_repository.dart';

/// Always "succeeds" without touching the network or secure storage, so
/// widget tests can drive the login/logout flow deterministically.
class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository() : super(Dio(), TokenStorage());

  bool loggedIn = false;

  @override
  Future<void> login(String accountNumber, String password) async {
    loggedIn = true;
  }

  @override
  Future<void> logout() async {
    loggedIn = false;
  }

  @override
  Future<bool> hasStoredSession() async => false;
}

ResidentData buildFakeResidentData() {
  return ResidentData(
    profile: ResidentProfile(
      id: 'profile-1',
      userId: 'user-1',
      fullName: 'Асанов Нурбек',
      createdAt: DateTime.utc(2026, 1, 1),
    ),
    account: const ResidentAccount(
      residentId: 'res-1',
      fullName: 'Асанов Нурбек',
      accountId: 'acc-1',
      accountNumber: '001245',
      addressId: 'addr-1',
      locality: 'Бишкек',
      street: 'ул. Мира',
      house: '15',
      apartment: '12',
    ),
    meters: const [
      ResidentMeter(meterId: 'meter-1', serialNumber: '449582', isActive: true),
    ],
    readings: [
      ResidentReading(
        readingId: 'reading-1',
        meterId: 'meter-1',
        value: 132,
        measuredAt: DateTime.utc(2026, 9, 12),
        source: 'controller',
      ),
      ResidentReading(
        readingId: 'reading-2',
        meterId: 'meter-1',
        value: 125,
        measuredAt: DateTime.utc(2026, 8, 12),
        source: 'controller',
      ),
    ],
    charges: [
      ResidentCharge(
        chargeId: 'charge-1',
        periodStart: DateTime.utc(2026, 9, 1),
        periodEnd: DateTime.utc(2026, 9, 30),
        consumption: 7,
        amount: 580,
        currency: 'сом',
        calculationVersion: 'v1',
      ),
    ],
    payments: [
      ResidentPayment(
        paymentId: 'payment-1',
        amount: 290,
        paidAt: DateTime.utc(2026, 8, 25),
      ),
    ],
    financial: const ResidentFinancial(
      totalCharges: 580,
      totalPayments: 290,
      outstandingDebt: 290,
      overpayment: 0,
      currency: 'сом',
    ),
  );
}

class FakeResidentRepository extends ResidentRepository {
  FakeResidentRepository() : super(Dio());

  @override
  Future<ResidentData> loadAll() async => buildFakeResidentData();
}
