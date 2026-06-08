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

class ProductsScreen extends StatelessWidget {
  static const String routeName = '/products';
  const ProductsScreen({super.key, required this.collection});

  final Collection collection;

  @override
  Widget build(BuildContext context) {
    final isArabic = context.read<LocaleCubit>().isArabic;
    return BlocProvider(
      create: (_) => DependencyInjector().productsCubit..loadForCollection(collection.id),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldBg,
          elevation: 0,
          title: Text(collection.localizedTitle(isArabic), style: AppTextStyles.heading3(context)),
        ),
        body: BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            if (state.status == ProductsStatus.loading || state.status == ProductsStatus.initial) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
            }
            if (state.products.isEmpty) {
              return EmptyState(icon: Icons.inventory_2_outlined, title: context.l10n.noProducts);
            }
            return GridView.builder(
              padding: EdgeInsets.all(16.r),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.gridCrossAxisCount(context),
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 0.66,
              ),
              itemCount: state.products.length,
              itemBuilder: (context, i) => ProductCard(product: state.products[i]),
            );
          },
        ),
      ),
    );
  }
}
