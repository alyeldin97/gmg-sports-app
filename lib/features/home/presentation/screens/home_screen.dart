import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/helpers/responsive.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/images.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../collections/data/model/collection.dart';
import '../../../products/presentation/screens/products_screen.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../../data/model/app_banner.dart';
import '../cubits/home_cubit.dart';
import '../widgets/banner_carousel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _onBannerTap(BuildContext context, AppBanner banner, List<Collection> collections) {
    if (banner.linkType == BannerLinkType.collection && banner.linkId != null) {
      final match = collections.where((c) => c.id == banner.linkId);
      if (match.isNotEmpty) {
        Navigator.of(context).pushNamed(ProductsScreen.routeName, arguments: match.first);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.somethingWrong)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state.status == HomeStatus.loading || state.status == HomeStatus.initial) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
            }
            if (state.status == HomeStatus.failure) {
              return EmptyState(
                icon: Icons.wifi_off_rounded,
                title: context.l10n.somethingWrong,
                actionLabel: context.l10n.retry,
                onAction: () => context.read<HomeCubit>().load(),
              );
            }
            return RefreshIndicator(
              color: AppColors.primaryDark,
              onRefresh: () => context.read<HomeCubit>().load(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _Header()),
                  SliverToBoxAdapter(child: SizedBox(height: 8.h)),
                  SliverToBoxAdapter(
                    child: BannerCarousel(
                      banners: state.banners,
                      onTap: (b) => _onBannerTap(context, b, state.collections),
                    ),
                  ),
                  if (state.collections.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _SectionHeader(title: context.l10n.shopByCollection),
                    ),
                    SliverToBoxAdapter(child: _CollectionsRail(collections: state.collections)),
                  ],
                  SliverToBoxAdapter(child: _SectionHeader(title: context.l10n.featured)),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Responsive.gridCrossAxisCount(context),
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: 0.66,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => ProductCard(product: state.featured[i]),
                        childCount: state.featured.length,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      child: Row(
        children: [
          Image.asset(AppImages.logo, height: 44.h),
          const Spacer(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 8.h),
      child: Text(title, style: AppTextStyles.heading2(context)),
    );
  }
}

class _CollectionsRail extends StatelessWidget {
  const _CollectionsRail({required this.collections});
  final List<Collection> collections;

  @override
  Widget build(BuildContext context) {
    final isArabic = context.read<LocaleCubit>().isArabic;
    return SizedBox(
      height: 130.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: collections.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, i) {
          final c = collections[i];
          return GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(ProductsScreen.routeName, arguments: c),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: AppBorderRadius.r16,
                  child: AppNetworkImage(url: c.imageUrl, width: 90.w, height: 90.h),
                ),
                SizedBox(height: 6.h),
                SizedBox(
                  width: 90.w,
                  child: Text(
                    c.localizedTitle(isArabic),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label(context).copyWith(color: AppColors.textDark),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
