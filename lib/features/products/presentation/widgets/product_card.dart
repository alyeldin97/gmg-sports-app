import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/extensions/price_x.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/navigation/cubits/navigation_cubit.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../cart/presentation/cubits/cart_cubit.dart';
import '../../../wishlist/presentation/cubits/wishlist_cubit.dart';
import '../../data/model/product.dart';
import '../screens/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final isArabic = context.read<LocaleCubit>().isArabic;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r16,
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Image + badges (fills all remaining vertical space) ───────────
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(
                ProductDetailsScreen.routeName,
                arguments: product,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image fills the stack
                  AppNetworkImage(
                    url: product.primaryImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),

                  // Discount badge
                  if (product.hasDiscount)
                    PositionedDirectional(
                      top: 8,
                      start: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius: AppBorderRadius.full,
                        ),
                        child: Text(
                          '${product.discountPercent}% ${context.l10n.off}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                  // Wishlist heart
                  PositionedDirectional(
                    top: 6,
                    end: 6,
                    child: _WishlistHeart(productId: product.id),
                  ),

                  // Out-of-stock overlay
                  if (!product.inStock)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.45),
                        alignment: Alignment.center,
                        child: Text(
                          context.l10n.outOfStock,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.subtitle(context)
                              .copyWith(color: AppColors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Name + price ──────────────────────────────────────────────────
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(
              ProductDetailsScreen.routeName,
              arguments: product,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.r, 8.r, 10.r, 4.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.localizedName(isArabic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle(context),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${product.price.asPrice} ${context.l10n.currency}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.price(context),
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            product.compareAtPrice!.asPrice,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall(context).copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Add to cart button ────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(10.r, 2.r, 10.r, 10.r),
            child: _AddToCartButton(product: product),
          ),
        ],
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton({required this.product});
  final Product product;

  void _onTap(BuildContext context) {
    if (product.hasVariants) {
      Navigator.of(context)
          .pushNamed(ProductDetailsScreen.routeName, arguments: product);
      return;
    }
    context.read<CartCubit>().addItem(product, quantity: 1);
    context.read<NavigationCubit>().navigateTo(2);
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = product.inStock;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? AppColors.primaryDark : AppColors.border,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textLight,
          // Comfortable vertical padding, no fixed height
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r)),
          elevation: 0,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: enabled ? () => _onTap(context) : null,
        // FittedBox scales content down if button is too narrow (handles Arabic)
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 13.r),
              SizedBox(width: 4.w),
              Text(
                context.l10n.addToCart,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
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
