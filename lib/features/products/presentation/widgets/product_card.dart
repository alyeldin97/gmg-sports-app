import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/extensions/price_x.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../wishlist/presentation/cubits/wishlist_cubit.dart';
import '../../data/model/product.dart';
import '../screens/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final isArabic = context.read<LocaleCubit>().isArabic;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        ProductDetailsScreen.routeName,
        arguments: product,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppBorderRadius.r16,
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: AppNetworkImage(url: product.primaryImage),
                ),
                if (product.hasDiscount)
                  PositionedDirectional(
                    top: 8,
                    start: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: AppBorderRadius.full,
                      ),
                      child: Text(
                        '${product.discountPercent}% ${context.l10n.off}',
                        style: AppTextStyles.bodySmall(context)
                            .copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                PositionedDirectional(
                  top: 6,
                  end: 6,
                  child: _WishlistHeart(productId: product.id),
                ),
                if (!product.inStock)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.4),
                      alignment: Alignment.center,
                      child: Text(
                        context.l10n.outOfStock,
                        style: AppTextStyles.subtitle(context).copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.localizedName(isArabic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle(context),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Text('${product.price.asPrice} ${context.l10n.currency}',
                          style: AppTextStyles.price(context)),
                      if (product.hasDiscount) ...[
                        SizedBox(width: 6.w),
                        Text(
                          product.compareAtPrice!.asPrice,
                          style: AppTextStyles.bodySmall(context).copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistHeart extends StatelessWidget {
  const _WishlistHeart({required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    if (!auth.isLoggedIn) return const SizedBox.shrink();

    return BlocBuilder<WishlistCubit, WishlistState>(
      builder: (context, state) {
        final isSaved = state.contains(productId);
        return GestureDetector(
          onTap: () {
            context.read<WishlistCubit>().toggle(auth.user!.id, productId);
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 18,
              color: isSaved ? AppColors.error : AppColors.textLight,
            ),
          ),
        );
      },
    );
  }
}
