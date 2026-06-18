import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/navigation/cubits/navigation_cubit.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../cart/presentation/cubits/cart_cubit.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../../../wishlist/presentation/cubits/wishlist_cubit.dart';
import '../../../collections/presentation/screens/collections_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../orders/presentation/screens/orders_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class LayoutScreen extends StatelessWidget {
  static const String routeName = '/layout';
  const LayoutScreen({super.key});

  static const _screens = [
    HomeScreen(),
    CollectionsScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (prev, curr) =>
              prev.status == AuthStatus.authenticated && curr.status == AuthStatus.guest,
          listener: (context, _) {
            context.read<CartCubit>().clear();
            context.read<WishlistCubit>().clear();
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (prev, curr) =>
              curr.status == AuthStatus.authenticated && curr.user != null &&
              prev.status != AuthStatus.authenticated,
          listener: (context, state) =>
              context.read<WishlistCubit>().load(state.user!.id),
        ),
      ],
      child: BlocBuilder<NavigationCubit, int>(
        builder: (context, index) {
          return PopScope(
          canPop: index == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && index != 0) context.read<NavigationCubit>().navigateTo(0);
          },
          child: Scaffold(
            body: IndexedStack(index: index, children: _screens),
            bottomNavigationBar: _BottomNav(currentIndex: index),
          ),
        );
      },
    ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex});
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(Icons.home_outlined, Icons.home_rounded, context.l10n.navHome),
      _NavItem(Icons.grid_view_outlined, Icons.grid_view_rounded, context.l10n.navShop),
      _NavItem(Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, context.l10n.navCart),
      _NavItem(Icons.receipt_long_outlined, Icons.receipt_long_rounded, context.l10n.navOrders),
      _NavItem(Icons.person_outline_rounded, Icons.person_rounded, context.l10n.navProfile),
    ];
    return Container(
      padding: EdgeInsets.fromLTRB(8, 8.h, 8, 10.h + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: Color(0x12000000), blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, cart) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final selected = i == currentIndex;
            return _Tab(
              item: items[i],
              selected: selected,
              badge: i == 2 ? cart.itemCount : 0,
              onTap: () => context.read<NavigationCubit>().navigateTo(i),
            );
          }),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.item, required this.selected, required this.onTap, this.badge = 0});
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: selected ? 14 : 10, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryMist : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(selected ? item.activeIcon : item.icon,
                    size: 24.r, color: selected ? AppColors.primaryDark : AppColors.textLight),
                if (badge > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
                      child: Text(badge > 9 ? '9+' : '$badge',
                          style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ),
                  ),
              ],
            ),
            if (selected) ...[
              SizedBox(width: 6.w),
              Text(item.label,
                  style: AppTextStyles.label(context).copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w800)),
            ],
          ],
        ),
      ),
    );
  }
}
