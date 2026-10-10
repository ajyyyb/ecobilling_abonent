import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/app_theme.dart';
import 'data/resident_repository.dart';
import 'screens/auth_screens.dart';
import 'screens/main_screens.dart';
import 'state/auth_controller.dart';
import 'state/subscriber_state.dart';
import 'widgets/ui_components.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  runApp(const EcoBillingApp());
}

class EcoBillingApp extends StatefulWidget {
  /// Tests inject their own fakes here instead of the real network-backed
  /// defaults constructed in [initState].
  const EcoBillingApp({super.key, this.authController, this.subscriberState});

  final AuthController? authController;
  final SubscriberUiState? subscriberState;

  @override
  State<EcoBillingApp> createState() => _EcoBillingAppState();
}

class _EcoBillingAppState extends State<EcoBillingApp> {
  late final AuthController _authController;
  late final SubscriberUiState _subscriberState;

  @override
  void initState() {
    super.initState();
    _authController = widget.authController ?? AuthController();
    _subscriberState =
        widget.subscriberState ??
        SubscriberUiState(ResidentRepository(_authController.dio));
    _authController.onAuthenticated ??= () {
      unawaited(_subscriberState.loadAll());
    };
    _subscriberState.loadSettings();
    unawaited(_authController.restoreSession());
  }

  @override
  void dispose() {
    _authController.dispose();
    _subscriberState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, child) => AuthScope(
      controller: _authController,
      child: SubscriberScope(
        state: _subscriberState,
        child: MaterialApp(
          title: 'EcoBilling',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: child,
        ),
      ),
    ),
    child: const _RootGate(),
  );
}

class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);

    return AnimatedBuilder(
      animation: auth,
      builder: (context, _) {
        if (auth.isBootstrapping) return const SplashScreen();
        if (!auth.isAuthenticated) return const LoginScreen();
        return const AppShell();
      },
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = SubscriberScope.of(context);

    if (state.isLoadingInitial) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.blue)),
      );
    }

    if (state.loadError != null && state.profile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const IconBadge(Icons.wifi_off_rounded, size: 56),
                const SizedBox(height: 16),
                Text(state.loadError!, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Повторить',
                  icon: Icons.refresh_rounded,
                  onPressed: () => state.loadAll(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: AppColors.background,
      ),
      child: Scaffold(
        body: SafeArea(
          top: true,
          bottom: false,
          child: IndexedStack(
            index: _selectedIndex,
            children: const [
              HomeScreen(),
              ConsumptionScreen(),
              PaymentsScreen(),
              ProfileScreen(),
            ],
          ),
        ),
        bottomNavigationBar: _BottomBar(
          selectedIndex: _selectedIndex,
          onSelected: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.selectedIndex, required this.onSelected});
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    (Icons.home_rounded, 'Главная'),
    (Icons.bar_chart_rounded, 'Расход'),
    (Icons.account_balance_wallet_outlined, 'Платежи'),
    (Icons.person_outline_rounded, 'Профиль'),
  ];

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 58.h,
        child: Row(
          children: List.generate(_items.length, (index) {
            final selected = selectedIndex == index;
            return Expanded(
              child: InkWell(
                onTap: () => onSelected(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _items[index].$1,
                      size: 21.r,
                      color: selected
                          ? AppColors.blue
                          : const Color(0xFF98A2B3),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      _items[index].$2,
                      style: TextStyle(
                        fontSize: 10.sp,
                        height: 1,
                        color: selected
                            ? AppColors.blueDark
                            : AppColors.secondary,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    ),
  );
}
