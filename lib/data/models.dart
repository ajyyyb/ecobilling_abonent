class ResidentProfile {
  final String id;
  final String userId;
  final String fullName;
  final DateTime createdAt;

  const ResidentProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.createdAt,
  });

  factory ResidentProfile.fromJson(Map<String, dynamic> json) =>
      ResidentProfile(
        id: json['id'] as String,
        userId: json['userId'] as String,
        fullName: json['fullName'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class ResidentAccount {
  final String residentId;
  final String fullName;
  final String accountId;
  final String accountNumber;
  final String addressId;
  final String locality;
  final String street;
  final String house;
  final String? building;
  final String? apartment;

  const ResidentAccount({
    required this.residentId,
    required this.fullName,
    required this.accountId,
    required this.accountNumber,
    required this.addressId,
    required this.locality,
    required this.street,
    required this.house,
    this.building,
    this.apartment,
  });

  factory ResidentAccount.fromJson(Map<String, dynamic> json) =>
      ResidentAccount(
        residentId: json['residentId'] as String,
        fullName: json['fullName'] as String,
        accountId: json['accountId'] as String,
        accountNumber: json['accountNumber'] as String,
        addressId: json['addressId'] as String,
        locality: json['locality'] as String? ?? '',
        street: json['street'] as String? ?? '',
        house: json['house'] as String? ?? '',
        building: json['building'] as String?,
        apartment: json['apartment'] as String?,
      );

  String get address {
    final parts = <String>[locality, street, house]
      ..removeWhere((e) => e.trim().isEmpty);
    var result = parts.join(', ');
    if (building != null && building!.trim().isNotEmpty) {
      result += '/${building!.trim()}';
    }
    if (apartment != null && apartment!.trim().isNotEmpty) {
      result += ', кв. ${apartment!.trim()}';
    }
    return result;
  }
}

class ResidentMeter {
  final String meterId;
  final String serialNumber;
  final DateTime? installedAt;
  final bool isActive;
  final DateTime? retiredAt;

  const ResidentMeter({
    required this.meterId,
    required this.serialNumber,
    this.installedAt,
    required this.isActive,
    this.retiredAt,
  });

  factory ResidentMeter.fromJson(Map<String, dynamic> json) => ResidentMeter(
    meterId: json['meterId'] as String,
    serialNumber: json['serialNumber'] as String,
    installedAt: json['installedAt'] != null
        ? DateTime.parse(json['installedAt'] as String)
        : null,
    isActive: json['isActive'] as bool? ?? true,
    retiredAt: json['retiredAt'] != null
        ? DateTime.parse(json['retiredAt'] as String)
        : null,
  );
}

class ResidentReading {
  final String readingId;
  final String meterId;
  final double value;
  final DateTime measuredAt;
  final String source;

  const ResidentReading({
    required this.readingId,
    required this.meterId,
    required this.value,
    required this.measuredAt,
    required this.source,
  });

  factory ResidentReading.fromJson(Map<String, dynamic> json) =>
      ResidentReading(
        readingId: json['readingId'] as String,
        meterId: json['meterId'] as String,
        value: (json['value'] as num).toDouble(),
        measuredAt: DateTime.parse(json['measuredAt'] as String),
        source: json['source'] as String? ?? '',
      );
}

class ResidentCharge {
  final String chargeId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double consumption;
  final double amount;
  final String currency;
  final String calculationVersion;

  const ResidentCharge({
    required this.chargeId,
    required this.periodStart,
    required this.periodEnd,
    required this.consumption,
    required this.amount,
    required this.currency,
    required this.calculationVersion,
  });

  factory ResidentCharge.fromJson(Map<String, dynamic> json) => ResidentCharge(
    chargeId: json['chargeId'] as String,
    periodStart: DateTime.parse(json['periodStart'] as String),
    periodEnd: DateTime.parse(json['periodEnd'] as String),
    consumption: (json['consumption'] as num).toDouble(),
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] as String? ?? 'KGS',
    calculationVersion: json['calculationVersion'] as String,
  );
}

class ResidentPayment {
  final String paymentId;
  final double amount;
  final DateTime paidAt;

  const ResidentPayment({
    required this.paymentId,
    required this.amount,
    required this.paidAt,
  });

  factory ResidentPayment.fromJson(Map<String, dynamic> json) =>
      ResidentPayment(
        paymentId: json['paymentId'] as String,
        amount: (json['amount'] as num).toDouble(),
        paidAt: DateTime.parse(json['paidAt'] as String),
      );
}

class ResidentFinancial {
  final double totalCharges;
  final double totalPayments;
  final double outstandingDebt;
  final double overpayment;
  final String currency;

  const ResidentFinancial({
    required this.totalCharges,
    required this.totalPayments,
    required this.outstandingDebt,
    required this.overpayment,
    required this.currency,
  });

  factory ResidentFinancial.fromJson(Map<String, dynamic> json) =>
      ResidentFinancial(
        totalCharges: (json['totalCharges'] as num).toDouble(),
        totalPayments: (json['totalPayments'] as num).toDouble(),
        outstandingDebt: (json['outstandingDebt'] as num).toDouble(),
        overpayment: (json['overpayment'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'KGS',
      );
}
