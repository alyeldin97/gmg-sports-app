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
import '../cubits/products_cubit.dart';
import '../widgets/product_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final isArabic = context.read<LocaleCubit>().isArabic;
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
                  final filtered = _query.isEmpty
                      ? state.products
                      : state.products
                          .where((p) => p.name.toLowerCase().contains(_query) ||
                              (p.nameAr?.toLowerCase().contains(_query) ?? false))
                          .toList();
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
