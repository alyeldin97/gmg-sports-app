import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../products/presentation/cubits/products_cubit.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../cubits/wishlist_cubit.dart';

class WishlistScreen extends StatelessWidget {
  static const String routeName = '/wishlist';
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;

    if (!auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldBg,
          elevation: 0,
          title: Text(context.l10n.myWishlist, style: AppTextStyles.heading3(context)),
        ),
        body: EmptyState(
          icon: Icons.favorite_border_rounded,
          title: context.l10n.loginToWishlist,
          actionLabel: context.l10n.login,
          onAction: () => Navigator.of(context).pop(),
        ),
      );
    }

    final wishlist = context.watch<WishlistCubit>().state;
    final ids = wishlist.productIds.toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        title: Text(context.l10n.myWishlist, style: AppTextStyles.heading3(context)),
      ),
      body: BlocProvider(
        create: (_) => DependencyInjector().productsCubit..loadByIds(ids),
        child: BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            if (state.status == ProductsStatus.loading ||
                state.status == ProductsStatus.initial) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
            }
            if (state.products.isEmpty) {
              return EmptyState(
                icon: Icons.favorite_border_rounded,
                title: context.l10n.wishlistEmpty,
              );
            }
            return RefreshIndicator(
              color: AppColors.primaryDark,
              onRefresh: () => context.read<ProductsCubit>().loadByIds(ids),
              child: GridView.builder(
                padding: EdgeInsets.all(16.r),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Responsive.gridCrossAxisCount(context),
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 0.66,
                ),
                itemCount: state.products.length,
                itemBuilder: (context, i) => ProductCard(product: state.products[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}
