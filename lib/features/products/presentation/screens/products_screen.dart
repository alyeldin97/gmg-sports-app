import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../collections/data/model/collection.dart';
import '../../data/model/product.dart';
import '../cubits/products_cubit.dart';
import '../widgets/product_card.dart';

enum _SortMode { newest, priceLow, priceHigh }

class ProductsScreen extends StatefulWidget {
  static const String routeName = '/products';
  const ProductsScreen({super.key, required this.collection});

  final Collection collection;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  _SortMode _sort = _SortMode.newest;
  bool _inStockOnly = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _query = _searchController.text.toLowerCase()));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _apply(List<Product> products) {
    var result = _inStockOnly ? products.where((p) => p.inStock).toList() : List<Product>.from(products);
    if (_query.isNotEmpty) {
      result = result
          .where((p) =>
              p.name.toLowerCase().contains(_query) ||
              (p.nameAr?.toLowerCase().contains(_query) ?? false))
          .toList();
    }
    switch (_sort) {
      case _SortMode.priceLow:
        result.sort((a, b) => a.price.compareTo(b.price));
      case _SortMode.priceHigh:
        result.sort((a, b) => b.price.compareTo(a.price));
      case _SortMode.newest:
        break;
    }
    return result;
  }

  void _showSortFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(context.l10n.sortBy, style: AppTextStyles.subtitle(context)),
              SizedBox(height: 8.h),
              ...[
                (_SortMode.newest, context.l10n.sortNewest),
                (_SortMode.priceLow, context.l10n.sortPriceLow),
                (_SortMode.priceHigh, context.l10n.sortPriceHigh),
              ].map((e) => RadioListTile<_SortMode>(
                    value: e.$1,
                    groupValue: _sort,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primaryDark,
                    title: Text(e.$2, style: AppTextStyles.body(context)),
                    onChanged: (v) {
                      setSheetState(() {});
                      setState(() => _sort = v ?? _SortMode.newest);
                    },
                  )),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primaryDark,
                title: Text(context.l10n.inStockOnly, style: AppTextStyles.body(context)),
                value: _inStockOnly,
                onChanged: (v) {
                  setSheetState(() {});
                  setState(() => _inStockOnly = v);
                },
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.read<LocaleCubit>().isArabic;
    final hasFilters = _sort != _SortMode.newest || _inStockOnly;
    return BlocProvider(
      create: (_) => DependencyInjector().productsCubit..loadForCollection(widget.collection.id),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldBg,
          elevation: 0,
          title: Text(widget.collection.localizedTitle(isArabic), style: AppTextStyles.heading3(context)),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: context.l10n.search,
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textLight),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: AppColors.textLight),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      InkWell(
                        onTap: () => _showSortFilter(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: hasFilters ? AppColors.primaryMist : AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: hasFilters ? AppColors.primaryDark : AppColors.border,
                            ),
                          ),
                          child: Icon(Icons.tune_rounded,
                              color: hasFilters ? AppColors.primaryDark : AppColors.textLight,
                              size: 22),
                        ),
                      ),
                      if (hasFilters)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryDark,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: BlocBuilder<ProductsCubit, ProductsState>(
                builder: (context, state) {
                  if (state.status == ProductsStatus.loading || state.status == ProductsStatus.initial) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
                  }
                  if (state.status == ProductsStatus.failure) {
                    return EmptyState(
                      icon: Icons.wifi_off_rounded,
                      title: context.l10n.somethingWrong,
                      actionLabel: context.l10n.retry,
                      onAction: () => context.read<ProductsCubit>().loadForCollection(widget.collection.id),
                    );
                  }
                  final filtered = _apply(state.products);
                  if (filtered.isEmpty) {
                    return EmptyState(icon: Icons.inventory_2_outlined, title: context.l10n.noProducts);
                  }
                  return RefreshIndicator(
                    color: AppColors.primaryDark,
                    onRefresh: () => context.read<ProductsCubit>().loadForCollection(widget.collection.id),
                    child: GridView.builder(
                      padding: EdgeInsets.all(16.r),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Responsive.gridCrossAxisCount(context),
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: 0.66,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => ProductCard(product: filtered[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
