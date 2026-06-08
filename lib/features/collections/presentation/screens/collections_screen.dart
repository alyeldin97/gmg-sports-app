import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../products/presentation/screens/products_screen.dart';
import '../cubits/collections_cubit.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.read<LocaleCubit>().isArabic;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        title: Text(context.l10n.shopByCollection, style: AppTextStyles.heading2(context)),
      ),
      body: BlocBuilder<CollectionsCubit, CollectionsState>(
        builder: (context, state) {
          if (state.status == CollectionsStatus.loading || state.status == CollectionsStatus.initial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
          }
          if (state.collections.isEmpty) {
            return EmptyState(
              icon: Icons.grid_view_rounded,
              title: context.l10n.noProducts,
              actionLabel: context.l10n.retry,
              onAction: () => context.read<CollectionsCubit>().load(),
            );
          }
          return RefreshIndicator(
            color: AppColors.primaryDark,
            onRefresh: () => context.read<CollectionsCubit>().load(),
            child: ListView.separated(
              padding: EdgeInsets.all(16.r),
              itemCount: state.collections.length,
              separatorBuilder: (_, __) => SizedBox(height: 14.h),
              itemBuilder: (context, i) {
                final c = state.collections[i];
                return GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(ProductsScreen.routeName, arguments: c),
                  child: ClipRRect(
                    borderRadius: AppBorderRadius.r16,
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 2.4,
                          child: AppNetworkImage(url: c.imageUrl, width: double.infinity),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black.withValues(alpha: 0.65), Colors.transparent],
                              ),
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          start: 16.w,
                          bottom: 14.h,
                          child: Text(
                            c.localizedTitle(isArabic),
                            style: AppTextStyles.heading2(context).copyWith(color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
