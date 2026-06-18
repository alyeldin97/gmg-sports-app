import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../address/presentation/screens/my_addresses_screen.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../wishlist/presentation/screens/wishlist_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final user = auth.user;
    final locale = context.watch<LocaleCubit>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        title: Text(context.l10n.navProfile, style: AppTextStyles.heading2(context)),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: AppBorderRadius.r16,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    (user?.name.isNotEmpty == true ? user!.name[0] : 'G').toUpperCase(),
                    style: AppTextStyles.heading2(context).copyWith(color: AppColors.ink),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? context.l10n.guestUser,
                          style: AppTextStyles.heading3(context).copyWith(color: AppColors.white)),
                      if (user != null)
                        Text(user.email,
                            style: AppTextStyles.bodySmall(context).copyWith(color: AppColors.primaryLight)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          if (auth.isLoggedIn) ...[
            _tile(context, Icons.person_outline_rounded, context.l10n.editProfile,
                () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
            _tile(context, Icons.favorite_border_rounded, context.l10n.myWishlist,
                () => Navigator.of(context).pushNamed(WishlistScreen.routeName)),
            _tile(context, Icons.location_on_outlined, context.l10n.myAddresses, () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => DependencyInjector().addressCubit..load(),
                  child: const MyAddressesScreen(),
                ),
              ));
            }),
          ],
          _tile(context, Icons.language_rounded, context.l10n.language,
              () => locale.toggle(),
              trailing: Text(locale.isArabic ? context.l10n.english : context.l10n.arabic,
                  style: AppTextStyles.label(context).copyWith(color: AppColors.primaryDark))),
          SizedBox(height: 20.h),
          if (auth.isLoggedIn)
            AppButton(
              label: context.l10n.logout,
              outlined: true,
              icon: Icons.logout_rounded,
              onPressed: () => context.read<AuthCubit>().signOut(),
            )
          else
            AppButton(
              label: context.l10n.signIn,
              onPressed: () => Navigator.of(context).pushNamed(LoginScreen.routeName),
            ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, VoidCallback onTap, {Widget? trailing}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r12,
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryDark),
        title: Text(title, style: AppTextStyles.subtitle(context)),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
        onTap: onTap,
      ),
    );
  }
}
