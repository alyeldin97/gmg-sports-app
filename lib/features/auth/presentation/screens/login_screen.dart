import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/app_validator.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/images.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../layout/presentation/screens/layout_screen.dart';
import '../cubits/auth_cubit.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              Navigator.of(context).pushNamedAndRemoveUntil(LayoutScreen.routeName, (_) => false);
            } else if (state.status == AuthStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? context.l10n.somethingWrong)),
              );
            }
          },
          builder: (context, state) {
            final loading = state.status == AuthStatus.loading;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 24.h),
                    Center(child: Image.asset(AppImages.logo, height: 110.h)),
                    SizedBox(height: 24.h),
                    Text(context.l10n.welcomeBack, style: AppTextStyles.heading1(context)),
                    SizedBox(height: 4.h),
                    Text(context.l10n.loginSubtitle, style: AppTextStyles.bodySmall(context)),
                    SizedBox(height: 24.h),
                    AppTextField(
                      label: context.l10n.email,
                      controller: _emailController,
                      validator: AppValidator.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline_rounded,
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      label: context.l10n.password,
                      controller: _passwordController,
                      validator: AppValidator.validatePassword,
                      obscure: true,
                      prefixIcon: Icons.lock_outline_rounded,
                    ),
                    SizedBox(height: 8.h),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pushNamed(ForgotPasswordScreen.routeName),
                        child: Text(context.l10n.forgotPassword,
                            style: AppTextStyles.label(context).copyWith(color: AppColors.primaryDark)),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    AppButton(label: context.l10n.signIn, loading: loading, onPressed: _submit),
                    SizedBox(height: 12.h),
                    AppButton(
                      label: context.l10n.continueAsGuest,
                      outlined: true,
                      onPressed: () {
                        context.read<AuthCubit>().continueAsGuest();
                        Navigator.of(context).pushNamedAndRemoveUntil(LayoutScreen.routeName, (_) => false);
                      },
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(context.l10n.dontHaveAccount, style: AppTextStyles.bodySmall(context)),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushNamed(RegisterScreen.routeName),
                          child: Text(context.l10n.signUp,
                              style: AppTextStyles.label(context).copyWith(color: AppColors.primaryDark)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
