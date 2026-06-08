import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/app_validator.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../cubits/auth_cubit.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String routeName = '/forgot-password';
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        title: Text(context.l10n.resetPassword, style: AppTextStyles.heading3(context)),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.passwordResetSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.resetLinkSent)),
              );
              Navigator.of(context).pop();
            } else if (state.status == AuthStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? context.l10n.somethingWrong)),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: context.l10n.email,
                      controller: _emailController,
                      validator: AppValidator.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline_rounded,
                    ),
                    SizedBox(height: 24.h),
                    AppButton(
                      label: context.l10n.resetPassword,
                      loading: state.status == AuthStatus.loading,
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context.read<AuthCubit>().sendPasswordReset(email: _emailController.text.trim());
                        }
                      },
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
