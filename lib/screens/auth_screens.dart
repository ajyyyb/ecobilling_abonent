import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/app_theme.dart';
import '../state/auth_controller.dart';
import '../widgets/ui_components.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconBadge(Icons.water_drop_rounded, size: 72),
          SizedBox(height: 20.h),
          const CircularProgressIndicator(color: AppColors.blue),
        ],
      ),
    ),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Заполните поле';
    return null;
  }

  Future<void> _handleLogin(AuthController auth) async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await auth.login(_accountController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);

    return AnimatedBuilder(
      animation: auth,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: IconBadge(Icons.water_drop_rounded, size: 76),
                        ),
                        SizedBox(height: 18.h),
                        Text(
                          'EcoBilling',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Личный кабинет абонента',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.secondary,
                          ),
                        ),
                        SizedBox(height: 32.h),
                        TextFormField(
                          controller: _accountController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Номер лицевого счёта',
                          ),
                          validator: _requiredValidator,
                        ),
                        SizedBox(height: 14.h),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'Пароль',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: _requiredValidator,
                          onFieldSubmitted: (_) => _handleLogin(auth),
                        ),
                        if (auth.errorMessage != null) ...[
                          SizedBox(height: 12.h),
                          Text(
                            auth.errorMessage!,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                        SizedBox(height: 22.h),
                        PrimaryButton(
                          label: 'Войти',
                          loading: auth.isLoading,
                          onPressed: () => _handleLogin(auth),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
