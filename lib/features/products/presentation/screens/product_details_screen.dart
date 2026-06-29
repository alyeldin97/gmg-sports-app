import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/extensions/price_x.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/services/meta_pixel_service.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../cart/presentation/cubits/cart_cubit.dart';
import '../../../wishlist/presentation/cubits/wishlist_cubit.dart';
import '../../data/model/product.dart';
import '../../data/model/product_variant.dart';
import '../cubits/products_cubit.dart';
import '../widgets/product_card.dart';

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
  int _imageIndex = 0;
  late final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    if (widget.product.hasVariants) {
      _selectedVariant = widget.product.variants.firstWhere(
        (v) => v.inStock,
        orElse: () => widget.product.variants.first,
      );
    }
    MetaPixelService.viewContent(
      contentId: widget.product.id,
      contentName: widget.product.name,
      value: widget.product.price,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double get _currentPrice => _selectedVariant?.price ?? widget.product.price;
  int get _currentStock => _selectedVariant?.stock ?? widget.product.stock;

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
      SnackBar(
        content: Text(context.l10n.added),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: context.l10n.navCart,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final isArabic = context.read<LocaleCubit>().isArabic;
    final description = p.localizedDescription(isArabic);
    final images = p.images.isNotEmpty ? p.images : <String>[];

    // Responsive image height: 42% of screen height, clamped for small/large screens
    final screenH = MediaQuery.sizeOf(context).height;
    final imageH = (screenH * 0.42).clamp(260.0, 420.0);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: imageH,
            pinned: true,
            backgroundColor: AppColors.white,
            iconTheme: const IconThemeData(color: AppColors.ink),
            actions: [
              BlocBuilder<WishlistCubit, WishlistState>(
                builder: (context, ws) {
                  final auth = context.watch<AuthCubit>().state;
                  if (!auth.isLoggedIn) return const SizedBox.shrink();
                  final isSaved = ws.contains(p.id);
                  return IconButton(
                    icon: Icon(
                      isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isSaved ? AppColors.error : AppColors.ink,
                    ),
                    onPressed: () =>
                        context.read<WishlistCubit>().toggle(auth.user!.id, p.id),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // ── Image gallery ──────────────────────────────────────────
                  if (images.length > 1)
                    PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (i) => setState(() => _imageIndex = i),
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => showImageGallery(context, images, i),
                        child: Hero(
                          tag: 'product_image_${p.id}_$i',
                          child: AppNetworkImage(url: images[i], fit: BoxFit.contain),
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        final img = p.primaryImage;
                        if (img != null && img.isNotEmpty) {
                          showImageViewer(context, img);
                        }
                      },
                      child: Hero(
                        tag: 'product_image_${p.id}_0',
                        child: AppNetworkImage(url: p.primaryImage, fit: BoxFit.contain),
                      ),
                    ),

                  // ── Dot indicator ──────────────────────────────────────────
                  if (images.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (i) {
                          final sel = i == _imageIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: sel ? 18 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),

                  // ── Expand hint icon ───────────────────────────────────────
                  Positioned(
                    bottom: images.length > 1 ? 32 : 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        if (images.isNotEmpty) {
                          showImageGallery(context, images.isNotEmpty ? images : [p.primaryImage ?? ''], _imageIndex);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.open_in_full_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),

                  // ── Discount badge ─────────────────────────────────────────
                  if (p.hasDiscount)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('−${p.discountPercent}%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('${_currentPrice.asPrice} ${context.l10n.currency}',
                          style: AppTextStyles.heading2(context)
                              .copyWith(color: AppColors.primaryDark)),
                      if (p.hasDiscount) ...[
                        SizedBox(width: 8.w),
                        Text(
                          p.compareAtPrice!.asPrice,
                          style: AppTextStyles.body(context).copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (_currentStock > 0 && _currentStock <= 5)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange.withValues(alpha: 0.12),
                            borderRadius: AppBorderRadius.r12,
                          ),
                          child: Text(
                            context.l10n.onlyXLeft(_currentStock),
                            style: AppTextStyles.bodySmall(context).copyWith(
                              color: AppColors.accentOrange,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
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
                    SizedBox(height: 16.h),
                  ],
                  if (p.collectionIds.isNotEmpty) _RecommendationsSection(product: p),
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
                max: _currentStock,
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

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final collectionId = product.collectionIds.first;
    return BlocProvider(
      create: (_) => DependencyInjector().productsCubit..loadForCollection(collectionId),
      child: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          if (state.status != ProductsStatus.success) return const SizedBox.shrink();
          final recs = state.products
              .where((p) => p.id != product.id && p.isActive)
              .take(8)
              .toList();
          if (recs.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.youMightAlsoLike, style: AppTextStyles.heading3(context)),
              SizedBox(height: 10.h),
              SizedBox(
                height: 265.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recs.length,
                  separatorBuilder: (_, __) => SizedBox(width: 10.w),
                  itemBuilder: (context, i) => SizedBox(
                    width: 155.w,
                    child: ProductCard(product: recs[i]),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          );
        },
      ),
    );
  }
}
