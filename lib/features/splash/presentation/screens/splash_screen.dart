import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/images.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../layout/presentation/screens/layout_screen.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    final cubit = context.read<AuthCubit>();
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1600)),
      cubit.stream.firstWhere((s) => s.status != AuthStatus.loading && s.status != AuthStatus.initial)
          .catchError((_) => cubit.state),
    ]);
    if (!mounted) return;

    if (cubit.state.status == AuthStatus.authenticated) {
      Navigator.of(context).pushReplacementNamed(LayoutScreen.routeName);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('hasSeenOnboarding') ?? false;
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      seen ? OnboardingScreen.routeName : OnboardingScreen.routeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(child: Image.asset(AppImages.logo, width: 200.w)),
    );
  }
}
