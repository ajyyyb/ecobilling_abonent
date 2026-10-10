import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../core/app_theme.dart';
import '../data/models.dart';
import '../state/auth_controller.dart';
import '../state/subscriber_state.dart';
import '../widgets/flows.dart';
import '../widgets/ui_components.dart';
import 'secondary_screens.dart';

String _formatDate(DateTime date) =>
    DateFormat('d MMMM yyyy', 'ru').format(date);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = SubscriberScope.of(context);
    return RefreshIndicator(
      color: AppColors.blue,
      onRefresh: state.loadAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.loadError != null) ...[
              _RefreshErrorBanner(message: state.loadError!),
              SizedBox(height: 14.h),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Добрый день,',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${state.fullName}!',
                        style: TextStyle(
                          fontSize: 29.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -.5,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Спасибо, что заботитесь о нашем городе',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                _SquareAction(
                  icon: Icons.notifications_none_rounded,
                  label: 'Уведомления',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 22.h),
            _BillHero(state: state),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.water_drop_rounded,
                    title: 'Последнее показание',
                    value: '${state.currentReading.toStringAsFixed(0)} м³',
                    foot: state.primaryMeterReadings.isNotEmpty
                        ? 'от ${_formatDate(state.primaryMeterReadings.first.measuredAt)}'
                        : 'Нет данных',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _StatCard(
                    icon: Icons.bar_chart_rounded,
                    title: 'Расход за месяц',
                    value: '${state.monthlyUsage.toStringAsFixed(0)} м³',
                    foot: 'по показаниям счётчика',
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            AppCard(
              onTap: () => showMeterReadingFlow(context, state),
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
              child: Row(
                children: [
                  IconBadge(Icons.info_outline_rounded, size: 38),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Не забудьте передать показания\nв следующем месяце',
                      style: TextStyle(
                        fontSize: 13.sp,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.blueDark,
                    size: 23.r,
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            _WaterSavingBanner(),
          ],
        ),
      ),
    );
  }
}

class _RefreshableScroll extends StatelessWidget {
  const _RefreshableScroll({
    required this.onRefresh,
    required this.padding,
    required this.child,
  });
  final Future<void> Function() onRefresh;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    color: AppColors.blue,
    onRefresh: onRefresh,
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      child: child,
    ),
  );
}

class _RefreshErrorBanner extends StatelessWidget {
  const _RefreshErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF4ED),
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: AppColors.warning.withValues(alpha: .3)),
    ),
    child: Row(
      children: [
        Icon(Icons.wifi_off_rounded, size: 18.r, color: AppColors.warning),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            message,
            style: TextStyle(fontSize: 12.sp, color: AppColors.secondary),
          ),
        ),
      ],
    ),
  );
}

class _SquareAction extends StatelessWidget {
  const _SquareAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.all(11.w),
          child: Icon(icon, size: 22.r, color: AppColors.text),
        ),
      ),
    ),
  );
}

class _BillHero extends StatelessWidget {
  const _BillHero({required this.state});
  final SubscriberUiState state;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(20.w),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(23.r),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF078FE8), Color(0xFF0878CE)],
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x260078D1),
          blurRadius: 19,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'К оплате',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .9),
                  fontSize: 16.sp,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              state.outstandingDebt.toStringAsFixed(0),
              style: TextStyle(
                color: Colors.white,
                fontSize: 42.sp,
                fontWeight: FontWeight.w700,
                height: 1.1,
                letterSpacing: -.6,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 9.w, bottom: 5.h),
              child: Text(
                state.currency,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            if (state.outstandingDebt <= 0) const StatusChip(label: 'Оплачено'),
          ],
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          height: 43.h,
          child: FilledButton(
            onPressed: () => showPaymentFlow(context, state),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.blueDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13.r),
              ),
              elevation: 0,
            ),
            child: Text(
              state.outstandingDebt <= 0 ? 'Счет оплачен' : 'Оплатить',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        if (state.overpayment > 0) ...[
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.savings_outlined,
                color: Colors.white.withValues(alpha: .9),
                size: 14.r,
              ),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  'Переплата: ${state.overpayment.toStringAsFixed(0)} ${state.currency}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .95),
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.foot,
    this.badge,
  });
  final IconData icon;
  final String title;
  final String value;
  final String foot;
  final String? badge;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.all(14.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconBadge(icon, size: 36),
        SizedBox(height: 11.h),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.secondary,
            height: 1.25,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
            if (badge != null) ...[
              SizedBox(width: 5.w),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAFBF3),
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                  child: Text(
                    badge!,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 3.h),
        Text(
          foot,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11.sp, color: AppColors.secondary),
        ),
      ],
    ),
  );
}

class _WaterSavingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 15.h),
    decoration: BoxDecoration(
      color: const Color(0xFFE4F4FF),
      borderRadius: BorderRadius.circular(18.r),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            'Экономьте воду —\nсохраняйте будущее!',
            style: TextStyle(
              color: AppColors.blueDark,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Icon(
          Icons.water_drop_rounded,
          size: 44.r,
          color: AppColors.blue.withValues(alpha: .45),
        ),
        Icon(Icons.water_drop_outlined, size: 25.r, color: AppColors.blue),
      ],
    ),
  );
}

class ConsumptionScreen extends StatefulWidget {
  const ConsumptionScreen({super.key});

  @override
  State<ConsumptionScreen> createState() => _ConsumptionScreenState();
}

class _ConsumptionScreenState extends State<ConsumptionScreen> {
  int period = 0;

  List<(String, double)> _monthlySeries(SubscriberUiState state) {
    final charges = [...state.sortedCharges.reversed];
    final recent = charges.length > 6
        ? charges.sublist(charges.length - 6)
        : charges;
    return recent
        .map(
          (c) => (DateFormat('LLL', 'ru').format(c.periodEnd), c.consumption),
        )
        .toList();
  }

  List<(String, double)> _yearlySeries(SubscriberUiState state) {
    final totals = <int, double>{};
    for (final c in state.charges) {
      totals.update(
        c.periodEnd.year,
        (v) => v + c.consumption,
        ifAbsent: () => c.consumption,
      );
    }
    final years = totals.keys.toList()..sort();
    return years.map((y) => ('$y', totals[y]!)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = SubscriberScope.of(context);
    final series = period == 0 ? _monthlySeries(state) : _yearlySeries(state);
    final labels = series.map((e) => e.$1).toList();
    final values = series.map((e) => e.$2).toList();
    final maxValue = values.isEmpty
        ? 10.0
        : values.reduce((a, b) => a > b ? a : b);
    return _RefreshableScroll(
      onRefresh: state.loadAll,
      padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Потребление',
            style: TextStyle(
              fontSize: 25.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 18.h),
          SegmentedControl(
            labels: const ['По месяцам', 'По годам'],
            selectedIndex: period,
            onChanged: (value) => setState(() => period = value),
          ),
          SizedBox(height: 16.h),
          AppCard(
            padding: EdgeInsets.fromLTRB(15.w, 15.h, 15.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Расход воды, м³',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16.h),
                if (values.isEmpty)
                  const EmptyState(
                    title: 'Пока нет данных о начислениях',
                    message: 'График появится после первого начисления.',
                  )
                else
                  SizedBox(
                    height: 190.h,
                    child: BarChart(
                      BarChartData(
                        maxY: maxValue * 1.2,
                        minY: 0,
                        alignment: BarChartAlignment.spaceAround,
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 25,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= labels.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: EdgeInsets.only(top: 8.h),
                                  child: Text(
                                    labels[index],
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: List.generate(
                          values.length,
                          (index) => BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: values[index],
                                color: index == values.length - 1
                                    ? AppColors.blue
                                    : const Color(0xFFB7E3FF),
                                width: period == 0 ? 26.w : 35.w,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(7.r),
                                ),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          SectionTitle('Текущие показания', bottom: 10),
          AppCard(
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 15.w),
            child: Row(
              children: [
                Expanded(
                  child: _ReadingValue(
                    label: 'Предыдущее',
                    value: '${state.previousReading.toStringAsFixed(0)} м³',
                    date: state.primaryMeterReadings.length > 1
                        ? 'от ${_formatDate(state.primaryMeterReadings[1].measuredAt)}'
                        : 'Нет данных',
                  ),
                ),
                Container(
                  width: 1,
                  height: 62.h,
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  color: AppColors.border,
                ),
                Expanded(
                  child: _ReadingValue(
                    label: 'Текущее',
                    value: '${state.currentReading.toStringAsFixed(0)} м³',
                    date: state.primaryMeterReadings.isNotEmpty
                        ? 'от ${_formatDate(state.primaryMeterReadings.first.measuredAt)}'
                        : 'Нет данных',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          AppCard(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                const IconBadge(Icons.bar_chart_rounded),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Расход за месяц',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${state.monthlyUsage.toStringAsFixed(0)} м³',
                        style: TextStyle(
                          fontSize: 23.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          AppCard(
            onTap: () => showTariffDetails(context),
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                const IconBadge(Icons.receipt_long_outlined),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Тариф',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '20 сом/м³',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blueDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.secondary,
                  size: 22.r,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingValue extends StatelessWidget {
  const _ReadingValue({
    required this.label,
    required this.value,
    required this.date,
  });
  final String label;
  final String value;
  final String date;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(fontSize: 12.sp, color: AppColors.secondary),
      ),
      SizedBox(height: 3.h),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
        ),
      ),
      SizedBox(height: 3.h),
      Text(
        date,
        style: TextStyle(fontSize: 11.sp, color: AppColors.secondary),
      ),
    ],
  );
}

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final state = SubscriberScope.of(context);
    return _RefreshableScroll(
      onRefresh: state.loadAll,
      padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Счета и платежи',
            style: TextStyle(
              fontSize: 25.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 18.h),
          SegmentedControl(
            labels: const ['Текущий счет', 'История'],
            selectedIndex: tab,
            onChanged: (value) => setState(() => tab = value),
          ),
          SizedBox(height: 18.h),
          if (tab == 0)
            _currentBill(context, state)
          else
            _history(context, state),
        ],
      ),
    );
  }

  Widget _currentBill(BuildContext context, SubscriberUiState state) {
    final latestCharge = state.sortedCharges.isNotEmpty
        ? state.sortedCharges.first
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: EdgeInsets.all(15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                latestCharge != null
                    ? 'За ${_formatDate(latestCharge.periodEnd)}'
                    : 'Начислений пока нет',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
              if (latestCharge != null) ...[
                SizedBox(height: 15.h),
                _BillLine(
                  title: 'Водоснабжение',
                  detail: '${latestCharge.consumption.toStringAsFixed(0)} м³',
                  amount:
                      '${latestCharge.amount.toStringAsFixed(0)} ${latestCharge.currency}',
                ),
              ],
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15.h),
                child: const Divider(height: 1),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Итого к оплате',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${state.outstandingDebt.toStringAsFixed(0)} ${state.currency}',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              if (state.outstandingDebt > 0)
                PrimaryButton(
                  label:
                      'Оплатить ${state.outstandingDebt.toStringAsFixed(0)} ${state.currency}',
                  icon: Icons.account_balance_wallet_outlined,
                  onPressed: () => showPaymentFlow(context, state),
                )
              else
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAFBF3),
                    borderRadius: BorderRadius.circular(13.r),
                  ),
                  child: const Center(child: StatusChip(label: 'Оплачено')),
                ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        SectionTitle(
          'Последние платежи',
          trailing: 'Все',
          onTrailingTap: () => setState(() => tab = 1),
        ),
        AppCard(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
          child: _paymentRows(
            context,
            state,
            state.sortedPayments.take(3).toList(),
          ),
        ),
      ],
    );
  }

  Widget _history(BuildContext context, SubscriberUiState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
          child: _paymentRows(context, state, state.sortedPayments),
        ),
      ],
    );
  }

  Widget _paymentRows(
    BuildContext context,
    SubscriberUiState state,
    List<ResidentPayment> payments,
  ) {
    if (payments.isEmpty) {
      return const EmptyState(
        title: 'История платежей пока пуста',
        message: 'Здесь появятся ваши платежи.',
      );
    }
    return Column(
      children: [
        for (var index = 0; index < payments.length; index++) ...[
          InkWell(
            key: ValueKey(payments[index].paymentId),
            onTap: () => showPaymentDetails(context, state, payments[index]),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 13.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatDate(payments[index].paidAt),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  Text(
                    '${payments[index].amount.toStringAsFixed(0)} ${state.currency}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 17,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Оплачено',
                    style: TextStyle(fontSize: 12.sp, color: AppColors.success),
                  ),
                ],
              ),
            ),
          ),
          if (index < payments.length - 1) const Divider(height: 1),
        ],
      ],
    );
  }
}

class _BillLine extends StatelessWidget {
  const _BillLine({required this.title, this.detail, required this.amount});
  final String title;
  final String? detail;
  final String amount;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            if (detail != null) ...[
              SizedBox(height: 3.h),
              Text(
                detail!,
                style: TextStyle(fontSize: 12.sp, color: AppColors.secondary),
              ),
            ],
          ],
        ),
      ),
      SizedBox(width: 8.w),
      Text(
        amount,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
    ],
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = SubscriberScope.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Профиль',
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Настройки',
              ),
            ],
          ),
          SizedBox(height: 8.h),
          AppCard(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25.r,
                  backgroundColor: AppColors.paleBlue,
                  child: Text(
                    state.initials,
                    style: TextStyle(
                      color: AppColors.blueDark,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 13.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.fullName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Абонент',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.secondary),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          const SectionTitle('Информация'),
          AppCard(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 1.h),
            child: Column(
              children: [
                InfoRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Лицевой счёт',
                  value: state.accountNumber,
                ),
                const Divider(height: 1),
                InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Адрес',
                  value: state.address,
                ),
                const Divider(height: 1),
                InfoRow(
                  icon: Icons.speed_outlined,
                  label: 'Номер счётчика',
                  value: state.primaryMeter != null
                      ? '№ ${state.primaryMeter!.serialNumber}'
                            '${state.meters.length > 1 ? ' (+${state.meters.length - 1})' : ''}'
                      : '—',
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          const SectionTitle('Уведомления'),
          AppCard(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 3.h),
            child: Column(
              children: [
                _NotificationToggle(
                  icon: Icons.notifications_none_rounded,
                  label: 'Напоминания о платежах',
                  value: state.paymentReminders,
                  onChanged: (v) =>
                      state.setNotification('paymentReminders', v),
                ),
                const Divider(height: 1),
                _NotificationToggle(
                  icon: Icons.sms_outlined,
                  label: 'SMS-уведомления',
                  value: state.smsNotifications,
                  onChanged: (v) =>
                      state.setNotification('smsNotifications', v),
                ),
                const Divider(height: 1),
                _NotificationToggle(
                  icon: Icons.mail_outline_rounded,
                  label: 'Push-уведомления',
                  value: state.pushNotifications,
                  onChanged: (v) =>
                      state.setNotification('pushNotifications', v),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          const SectionTitle('Помощь'),
          AppCard(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 1.h),
            child: Column(
              children: [
                InfoRow(
                  icon: Icons.help_outline_rounded,
                  label: 'Частые вопросы',
                  value: '',
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.secondary,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FaqScreen()),
                  ),
                ),
                const Divider(height: 1),
                InfoRow(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Обратная связь',
                  value: '',
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.secondary,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogout(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Выйти'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogout(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text('Вы действительно хотите выйти из учётной записи?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Выйти',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (result == true && context.mounted) {
      await AuthScope.of(context).logout();
    }
  }
}

class _NotificationToggle extends StatelessWidget {
  const _NotificationToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 5.h),
    child: Row(
      children: [
        Icon(icon, size: 19.r, color: AppColors.text),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 14.sp)),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.blue,
          activeThumbColor: Colors.white,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    ),
  );
}
