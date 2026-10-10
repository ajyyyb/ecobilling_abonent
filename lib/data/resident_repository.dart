import 'package:dio/dio.dart';

import 'models.dart';

class ResidentData {
  final ResidentProfile profile;
  final ResidentAccount account;
  final List<ResidentMeter> meters;
  final List<ResidentReading> readings;
  final List<ResidentCharge> charges;
  final List<ResidentPayment> payments;
  final ResidentFinancial financial;

  const ResidentData({
    required this.profile,
    required this.account,
    required this.meters,
    required this.readings,
    required this.charges,
    required this.payments,
    required this.financial,
  });
}

class ResidentRepository {
  final Dio _dio;

  ResidentRepository(this._dio);

  Future<ResidentData> loadAll() async {
    final results = await Future.wait([
      _dio.get<Map<String, dynamic>>('/me/profile'),
      _dio.get<Map<String, dynamic>>('/me/account'),
      _dio.get<List<dynamic>>('/me/meters'),
      _dio.get<List<dynamic>>('/me/readings'),
      _dio.get<List<dynamic>>('/me/charges'),
      _dio.get<List<dynamic>>('/me/payments'),
      _dio.get<Map<String, dynamic>>('/me/financial'),
    ]);

    final profile = ResidentProfile.fromJson(
      results[0].data! as Map<String, dynamic>,
    );
    final account = ResidentAccount.fromJson(
      results[1].data! as Map<String, dynamic>,
    );
    final meters = (results[2].data! as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(ResidentMeter.fromJson)
        .toList();
    final readings = (results[3].data! as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(ResidentReading.fromJson)
        .toList();
    final charges = (results[4].data! as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(ResidentCharge.fromJson)
        .toList();
    final payments = (results[5].data! as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(ResidentPayment.fromJson)
        .toList();
    final financial = ResidentFinancial.fromJson(
      results[6].data! as Map<String, dynamic>,
    );

    return ResidentData(
      profile: profile,
      account: account,
      meters: meters,
      readings: readings,
      charges: charges,
      payments: payments,
      financial: financial,
    );
  }
}
