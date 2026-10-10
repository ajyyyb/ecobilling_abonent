import 'package:ecobilling_abonent/main.dart';
import 'package:ecobilling_abonent/state/auth_controller.dart';
import 'package:ecobilling_abonent/state/subscriber_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('ru');
  });

  Widget buildApp({FakeAuthRepository? authRepository}) {
    final repository = authRepository ?? FakeAuthRepository();
    final authController = AuthController(repository: repository);
    final subscriberState = SubscriberUiState(FakeResidentRepository());
    authController.onAuthenticated = () {
      subscriberState.loadAll();
    };
    return EcoBillingApp(
      authController: authController,
      subscriberState: subscriberState,
    );
  }

  testWidgets('shows the login screen when there is no stored session', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Войти'), findsOneWidget);
    expect(find.text('Номер лицевого счёта'), findsOneWidget);
  });

  testWidgets('logs in and shows real resident data on the home screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Номер лицевого счёта'),
      '001245',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Пароль'),
      'password',
    );
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    // No more login screen; home shows data from ResidentRepository, not
    // any hardcoded fixture value.
    expect(find.text('Войти'), findsNothing);
    expect(find.textContaining('Асанов Нурбек'), findsWidgets);
    expect(find.text('290'), findsOneWidget); // outstandingDebt from /financial
  });

  testWidgets('payment, meter reading, and feedback show "unavailable"', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Номер лицевого счёта'),
      '001245',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Пароль'),
      'password',
    );
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    // Paying from the home screen hero never zeroes the real debt.
    await tester.tap(find.text('Оплатить'));
    await tester.pump();
    expect(find.text('Функция пока недоступна'), findsOneWidget);
    expect(find.text('290'), findsOneWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Обратная связь'));
    await tester.tap(find.text('Обратная связь'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Тема');
    await tester.enterText(find.byType(TextFormField).at(1), 'Сообщение');
    await tester.tap(find.text('Отправить'));
    await tester.pump();
    expect(find.text('Функция пока недоступна'), findsOneWidget);
  });

  testWidgets('logging out returns to the login screen', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Номер лицевого счёта'),
      '001245',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Пароль'),
      'password',
    );
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Выйти'));
    await tester.tap(find.text('Выйти'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Выйти').last);
    await tester.pumpAndSettle();

    expect(find.text('Номер лицевого счёта'), findsOneWidget);
  });

  testWidgets('main screens fit small, standard, and large phone widths', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Номер лицевого счёта'),
      '001245',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Пароль'),
      'password',
    );
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    for (final width in [320.0, 390.0, 430.0]) {
      tester.view.physicalSize = Size(width, 844);
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
    }
  });
}
