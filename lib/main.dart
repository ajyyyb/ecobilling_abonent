import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/app_theme.dart';
import 'screens/main_screens.dart';
import 'state/subscriber_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  runApp(const EcoBillingApp());
}

class EcoBillingApp extends StatefulWidget {
  const EcoBillingApp({super.key});

  @override
  State<EcoBillingApp> createState() => _EcoBillingAppState();
}

class _EcoBillingAppState extends State<EcoBillingApp> {
  final SubscriberUiState _state = SubscriberUiState();

  @override
  void initState() {
    super.initState();
    _state.loadSettings();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, child) => SubscriberScope(
      state: _state,
      child: MaterialApp(
        title: 'EcoBilling',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: child,
      ),
    ),
    child: const AppShell(),
  );
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
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
