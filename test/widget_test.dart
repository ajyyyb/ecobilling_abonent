import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecobilling_abonent/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('ru');
  });

  testWidgets('subscriber tabs and local payment flow work', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EcoBillingApp());
    await tester.pumpAndSettle();
    expect(find.text('К оплате'), findsOneWidget);

    await tester.tap(find.text('Расход').last);
    await tester.pumpAndSettle();
    expect(find.text('Потребление'), findsOneWidget);

    await tester.tap(find.text('Платежи').last);
    await tester.pumpAndSettle();
    expect(find.text('Счета и платежи'), findsOneWidget);
    await tester.tap(find.text('Оплатить 580 сом'));
    await tester.pumpAndSettle();
    expect(find.text('Подтверждение оплаты'), findsOneWidget);

    await tester.tap(find.text('Подтвердить оплату'));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(find.text('0 сом'), findsOneWidget);
    expect(find.text('Платеж успешно выполнен'), findsOneWidget);

    await tester.tap(find.text('История').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('TXN-2026-000127')));
    await tester.pumpAndSettle();
    expect(find.text('Детали платежа'), findsOneWidget);
    expect(find.text('001245'), findsOneWidget);
    await tester.tap(find.text('Закрыть'));
    await tester.pumpAndSettle();
  });

  testWidgets('main screens fit small, standard, and large phone widths', (
    tester,
  ) async {
    for (final width in [320.0, 390.0, 430.0]) {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(const EcoBillingApp());
      await tester.pumpAndSettle();

      for (final label in ['Главная', 'Расход', 'Платежи', 'Профиль']) {
        await tester.tap(find.text(label).last);
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '$label overflowed at width $width',
        );
      }

      await tester.tap(find.text('Расход').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('По годам'));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Yearly chart overflowed at width $width',
      );
      await tester.tap(find.text('По месяцам'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Платежи').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('История').last);
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Payment history overflowed at width $width',
      );
    }
  });

  testWidgets('meter reading validation and local update work', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const EcoBillingApp());
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Не забудьте передать показания'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '120');
    await tester.tap(find.text('Передать показание'));
    await tester.pumpAndSettle();
    expect(
      find.text('Новое показание не может быть меньше предыдущего'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField), '140');
    await tester.tap(find.text('Передать показание'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.text('Показание успешно сохранено'), findsOneWidget);
    expect(find.text('140 м³'), findsOneWidget);
  });

  testWidgets('settings, notifications, FAQ, and feedback are interactive', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const EcoBillingApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Асанов Нурбек'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Нурбек2');
    await tester.tap(find.text('Сохранить'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.text('Асанов Нурбек2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Настройки'), findsOneWidget);
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Кыргызча'));
    await tester.pumpAndSettle();
    expect(find.text('Настройки сохранены'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Частые вопросы'));
    await tester.tap(find.text('Частые вопросы'));
    await tester.pumpAndSettle();
    expect(find.text('Как передать показания счетчика?'), findsOneWidget);
    await tester.tap(find.text('Как передать показания счетчика?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('На главной странице нажмите'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Обратная связь'));
    await tester.tap(find.text('Обратная связь'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Показания');
    await tester.enterText(find.byType(TextFormField).at(1), 'Проверка формы');
    await tester.tap(find.text('Отправить'));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(find.text('Спасибо!'), findsOneWidget);
    await tester.tap(find.text('Понятно'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Главная').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.notifications_none_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Новый счет за сентябрь'), findsOneWidget);
    await tester.tap(find.byTooltip('Очистить уведомления'));
    await tester.pumpAndSettle();
    expect(find.text('У вас пока нет новых уведомлений'), findsOneWidget);
  });
}
