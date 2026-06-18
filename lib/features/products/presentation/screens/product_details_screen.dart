import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/extensions/price_x.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../cart/presentation/cubits/cart_cubit.dart';
import '../../data/model/product.dart';
import '../../data/model/product_variant.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const String routeName = '/product-details';
  const ProductDetailsScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  ProductVariant? _selectedVariant;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.product.hasVariants) {
      _selectedVariant = widget.product.variants.firstWhere(
        (v) => v.inStock,
        orElse: () => widget.product.variants.first,
      );
    }
  }

  double get _currentPrice => _selectedVariant?.price ?? widget.product.price;

  bool get _canAdd {
    if (widget.product.hasVariants) return _selectedVariant?.inStock ?? false;
    return widget.product.inStock;
  }

  void _addToCart() {
    context.read<CartCubit>().addItem(
          widget.product,
          variant: _selectedVariant,
          quantity: _quantity,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.added), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final isArabic = context.read<LocaleCubit>().isArabic;
    final description = p.localizedDescription(isArabic);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340.h,
            pinned: true,
            backgroundColor: AppColors.white,
            iconTheme: const IconThemeData(color: AppColors.ink),
            flexibleSpace: FlexibleSpaceBar(
              background: AppNetworkImage(url: p.primaryImage, fit: BoxFit.cover),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.localizedName(isArabic), style: AppTextStyles.heading2(context)),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${_currentPrice.asPrice} ${context.l10n.currency}',
                          style: AppTextStyles.heading2(context).copyWith(color: AppColors.primaryDark)),
                      if (p.hasDiscount) ...[
                        SizedBox(width: 8.w),
                        Padding(
                          padding: EdgeInsets.only(bottom: 2.h),
                          child: Text(
                            p.compareAtPrice!.asPrice,
                            style: AppTextStyles.body(context).copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 16.h),
                  if (p.hasVariants) ...[
                    Text(context.l10n.selectOption, style: AppTextStyles.label(context)),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: p.variants.map((v) {
                        final selected = v.id == _selectedVariant?.id;
                        return GestureDetector(
                          onTap: v.inStock ? () => setState(() => _selectedVariant = v) : null,
                          child: Opacity(
                            opacity: v.inStock ? 1.0 : 0.4,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary
                                    : (v.inStock ? AppColors.white : AppColors.scaffoldBg),
                                borderRadius: AppBorderRadius.r12,
                                border: Border.all(
                                  color: selected ? AppColors.primaryDark : AppColors.border,
                                ),
                              ),
                              child: Text(
                                v.localizedName(isArabic),
                                style: AppTextStyles.label(context).copyWith(
                                  color: v.inStock ? AppColors.ink : AppColors.textLight,
                                  decoration: v.inStock ? null : TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16.h),
                  ],
                  if (description != null && description.isNotEmpty) ...[
                    Text(context.l10n.description, style: AppTextStyles.heading3(context)),
                    SizedBox(height: 6.h),
                    Text(description, style: AppTextStyles.body(context)),
                  ],
                  SizedBox(height: 80.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: const BoxDecoration(color: AppColors.white, boxShadow: [
            BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4)),
          ]),
          child: Row(
            children: [
              _QtyStepper(
                quantity: _quantity,
                max: _selectedVariant?.stock ?? widget.product.stock,
                onChanged: (q) => setState(() => _quantity = q),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppButton(
                  label: _canAdd ? context.l10n.addToCart : context.l10n.outOfStock,
                  icon: _canAdd ? Icons.add_shopping_cart_rounded : null,
                  onPressed: _canAdd ? _addToCart : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({required this.quantity, required this.max, required this.onChanged});
  final int quantity;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.r12,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
            icon: const Icon(Icons.remove, size: 18),
          ),
          Text('$quantity', style: AppTextStyles.subtitle(context)),
          IconButton(
            onPressed: quantity < max ? () => onChanged(quantity + 1) : null,
            icon: const Icon(Icons.add, size: 18),
          ),
        ],
      ),
    );
  }
}
