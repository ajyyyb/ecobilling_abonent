import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../core/app_theme.dart';
import '../state/subscriber_state.dart';
import 'ui_components.dart';

Future<void> showPaymentFlow(
  BuildContext context,
  SubscriberUiState state,
) async {
  if (state.currentBill == 0) {
    showAppSnack(context, 'Счет уже оплачен');
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (sheetContext) =>
        _PaymentSheet(state: state, parentContext: context),
  );
}

class _PaymentSheet extends StatefulWidget {
  const _PaymentSheet({required this.state, required this.parentContext});
  final SubscriberUiState state;
  final BuildContext parentContext;

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  bool loading = false;

  Future<void> _confirm() async {
    if (loading) return;
    setState(() => loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 750));
    widget.state.completePayment();
    if (!mounted) return;
    Navigator.of(context).pop();
    if (widget.parentContext.mounted) {
      showAppSnack(widget.parentContext, 'Платеж успешно выполнен');
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20.w,
      12.h,
      20.w,
      MediaQuery.viewInsetsOf(context).bottom + 24.h,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetTitle(
          title: 'Подтверждение оплаты',
          subtitle: 'Проверьте данные перед подтверждением',
        ),
        AppCard(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              _PaymentDetailLine(
                label: 'К оплате',
                value: '${widget.state.currentBill} сом',
                strong: true,
              ),
              SizedBox(height: 13.h),
              _PaymentDetailLine(
                label: 'Лицевой счет',
                value: widget.state.accountNumber,
              ),
              SizedBox(height: 13.h),
              const _PaymentDetailLine(
                label: 'Назначение',
                value: 'Водоснабжение',
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        PrimaryButton(
          label: 'Подтвердить оплату',
          icon: Icons.lock_outline_rounded,
          loading: loading,
          onPressed: _confirm,
        ),
        SizedBox(height: 8.h),
        Center(
          child: Text(
            'Демо-оплата без списания средств',
            style: TextStyle(fontSize: 12.sp, color: AppColors.secondary),
          ),
        ),
      ],
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

Future<void> showMeterReadingFlow(
  BuildContext context,
  SubscriberUiState state,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (sheetContext) =>
        _MeterReadingSheet(state: state, parentContext: context),
  );
}

class _MeterReadingSheet extends StatefulWidget {
  const _MeterReadingSheet({required this.state, required this.parentContext});
  final SubscriberUiState state;
  final BuildContext parentContext;

  @override
  State<_MeterReadingSheet> createState() => _MeterReadingSheetState();
}

class _MeterReadingSheetState extends State<_MeterReadingSheet> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate() || _loading) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final value = int.parse(_controller.text.trim());
    widget.state.saveReading(value);
    if (!mounted) return;
    Navigator.of(context).pop();
    if (widget.parentContext.mounted) {
      showAppSnack(widget.parentContext, 'Показание успешно сохранено');
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20.w,
      12.h,
      20.w,
      MediaQuery.viewInsetsOf(context).bottom + 24.h,
    ),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetTitle(
            title: 'Передать показания',
            subtitle: 'Введите данные с вашего счетчика',
          ),
          Text(
            'Предыдущее показание',
            style: TextStyle(fontSize: 13.sp, color: AppColors.secondary),
          ),
          SizedBox(height: 5.h),
          Text(
            '${widget.state.previousReading} м³',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16.h),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _controller,
              autofocus: false,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Новое показание',
                hintText: 'Введите показание',
                suffixText: 'м³',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите корректное значение';
                }
                final reading = int.tryParse(value.trim());
                if (reading == null) return 'Введите корректное значение';
                if (reading < widget.state.previousReading) {
                  return 'Новое показание не может быть меньше предыдущего';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
          ),
          SizedBox(height: 20.h),
          PrimaryButton(
            label: 'Передать показание',
            icon: Icons.send_rounded,
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    ),
  );
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
  PaymentRecord payment,
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
            value: DateFormat('d MMMM yyyy', 'ru').format(payment.date),
          ),
          SizedBox(height: 14.h),
          _PaymentDetailLine(
            label: 'Сумма',
            value: '${payment.amount} сом',
            strong: true,
          ),
          SizedBox(height: 14.h),
          _PaymentDetailLine(
            label: 'Статус',
            value: payment.paid ? 'Оплачено' : 'Ожидает',
          ),
          SizedBox(height: 14.h),
          _PaymentDetailLine(label: 'Лицевой счет', value: state.accountNumber),
          SizedBox(height: 14.h),
          const _PaymentDetailLine(label: 'Назначение', value: 'Водоснабжение'),
          SizedBox(height: 14.h),
          _PaymentDetailLine(label: 'Номер операции', value: payment.id),
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
