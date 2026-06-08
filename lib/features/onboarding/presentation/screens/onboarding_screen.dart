import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/images.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../layout/presentation/screens/layout_screen.dart';

class OnboardingScreen extends StatelessWidget {
  static const String routeName = '/onboarding';
  const OnboardingScreen({super.key});

  Future<void> _markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            children: [
              const Spacer(),
              Image.asset(AppImages.logo, width: 220.w),
              SizedBox(height: 24.h),
              Text(
                context.l10n.heroTitle.replaceAll('\\n', '\n'),
                textAlign: TextAlign.center,
                style: AppTextStyles.heading1(context).copyWith(color: AppColors.white, height: 1.2),
              ),
              SizedBox(height: 12.h),
              Text(
                context.l10n.loginSubtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(context).copyWith(color: AppColors.primaryLight),
              ),
              const Spacer(),
              AppButton(
                label: context.l10n.signIn,
                onPressed: () {
                  _markSeen();
                  Navigator.of(context).pushNamed(LoginScreen.routeName);
                },
              ),
              SizedBox(height: 12.h),
              AppButton(
                label: context.l10n.continueAsGuest,
                outlined: true,
                onPressed: () {
                  _markSeen();
                  context.read<AuthCubit>().continueAsGuest();
                  Navigator.of(context).pushNamedAndRemoveUntil(LayoutScreen.routeName, (_) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
