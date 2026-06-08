import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/app_validator.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../layout/presentation/screens/layout_screen.dart';
import '../cubits/auth_cubit.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signUp(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        title: Text(context.l10n.register, style: AppTextStyles.heading3(context)),
      ),
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
                    Text(context.l10n.createAccountSubtitle, style: AppTextStyles.bodySmall(context)),
                    SizedBox(height: 20.h),
                    AppTextField(
                      label: context.l10n.fullName,
                      controller: _nameController,
                      validator: (v) => AppValidator.validateNotEmpty(v, 'Name'),
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      label: context.l10n.email,
                      controller: _emailController,
                      validator: AppValidator.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline_rounded,
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      label: context.l10n.phone,
                      controller: _phoneController,
                      validator: AppValidator.validatePhone,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      label: context.l10n.password,
                      controller: _passwordController,
                      validator: AppValidator.validatePassword,
                      obscure: true,
                      prefixIcon: Icons.lock_outline_rounded,
                    ),
                    SizedBox(height: 24.h),
                    AppButton(label: context.l10n.signUp, loading: loading, onPressed: _submit),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(context.l10n.alreadyHaveAccount, style: AppTextStyles.bodySmall(context)),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(context.l10n.signIn,
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
