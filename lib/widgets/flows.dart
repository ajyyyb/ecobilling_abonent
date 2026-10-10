import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../core/app_theme.dart';
import '../data/models.dart';
import '../state/subscriber_state.dart';
import 'ui_components.dart';

/// Backend has no endpoint for online payment yet, so this never actually
/// pays anything — it only tells the user the feature isn't available.
void showPaymentFlow(BuildContext context, SubscriberUiState state) {
  showFeatureUnavailable(context);
}

/// Backend has no endpoint for a resident to submit their own reading, so
/// this never actually saves anything.
void showMeterReadingFlow(BuildContext context, SubscriberUiState state) {
  showFeatureUnavailable(context);
}

Future<void> showTariffDetails(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetTitle(title: 'Текущий тариф'),
          AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '20',
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blueDark,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 5.h, left: 7.w),
                  child: Text(
                    'сом / м³',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'Стоимость рассчитывается по объему потребленной воды и действующему тарифу для абонентов.',
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.5,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> showPaymentDetails(
  BuildContext context,
  SubscriberUiState state,
  ResidentPayment payment,
) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetTitle(title: 'Детали платежа'),
          _PaymentDetailLine(
            label: 'Дата',
            value: DateFormat('d MMMM yyyy', 'ru').format(payment.paidAt),
          ),
          SizedBox(height: 14.h),
          _PaymentDetailLine(
            label: 'Сумма',
            value: '${payment.amount.toStringAsFixed(0)} ${state.currency}',
            strong: true,
          ),
          SizedBox(height: 14.h),
          _PaymentDetailLine(label: 'Лицевой счет', value: state.accountNumber),
          SizedBox(height: 14.h),
          _PaymentDetailLine(label: 'Номер платежа', value: payment.paymentId),
          SizedBox(height: 22.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _PaymentDetailLine extends StatelessWidget {
  const _PaymentDetailLine({
    required this.label,
    required this.value,
    this.strong = false,
  });
  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(color: AppColors.secondary, fontSize: 14.sp),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: AppColors.text,
          fontSize: strong ? 18.sp : 14.sp,
          fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
    ],
  );
}
