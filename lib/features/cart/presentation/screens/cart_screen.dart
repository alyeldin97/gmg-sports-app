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
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../checkout/presentation/screens/checkout_screen.dart';
import '../../data/model/cart_item.dart';
import '../cubits/cart_cubit.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        title: Text(context.l10n.navCart, style: AppTextStyles.heading2(context)),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) => state.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () => context.read<CartCubit>().clear(),
                    child: Text(context.l10n.clearCart,
                        style: AppTextStyles.label(context).copyWith(color: AppColors.error)),
                  ),
          ),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: context.l10n.cartEmpty,
              subtitle: context.l10n.cartEmptyHint,
              actionLabel: context.l10n.startShopping,
              onAction: () => context.read<NavigationCubit>().navigateTo(0),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(16.r),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, i) => _CartRow(item: state.items[i]),
                ),
              ),
              _CartSummary(subtotal: state.subtotal),
            ],
          );
        },
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final isArabic = context.read<LocaleCubit>().isArabic;
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r16,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppBorderRadius.r12,
            child: AppNetworkImage(url: item.product.primaryImage, width: 72.w, height: 72.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.localizedName(isArabic),
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.subtitle(context)),
                if (item.variant != null)
                  Text(item.variant!.localizedName(isArabic), style: AppTextStyles.bodySmall(context)),
                SizedBox(height: 4.h),
                Text('${item.unitPrice.asPrice} ${context.l10n.currency}',
                    style: AppTextStyles.price(context).copyWith(color: AppColors.primaryDark)),
              ],
            ),
          ),
          _QtyControl(item: item),
        ],
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  const _QtyControl({required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartCubit>();
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: AppBorderRadius.full,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _iconBtn(Icons.remove, () => cart.setQuantity(item.cartKey, item.quantity - 1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Text('${item.quantity}', style: AppTextStyles.subtitle(context)),
              ),
              _iconBtn(Icons.add, () => cart.setQuantity(item.cartKey, item.quantity + 1)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => cart.removeItem(item.cartKey),
          child: Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Icon(Icons.delete_outline_rounded, size: 18.r, color: AppColors.error),
          ),
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 16)),
      );
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.subtotal});
  final double subtotal;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: const BoxDecoration(color: AppColors.white, boxShadow: [
          BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4)),
        ]),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.l10n.subtotal, style: AppTextStyles.label(context)),
                Text('${subtotal.asPrice} ${context.l10n.currency}', style: AppTextStyles.price(context)),
              ],
            ),
            SizedBox(height: 12.h),
            AppButton(
              label: context.l10n.checkout,
              icon: Icons.arrow_forward_rounded,
              onPressed: () => Navigator.of(context).pushNamed(CheckoutScreen.routeName),
            ),
          ],
        ),
      ),
    );
  }
}
