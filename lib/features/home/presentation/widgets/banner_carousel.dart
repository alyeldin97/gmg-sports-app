import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/model/app_banner.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key, required this.banners, required this.onTap});

  final List<AppBanner> banners;
  final ValueChanged<AppBanner> onTap;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        // Aspect-ratio driven height: 16:7, clamped to avoid huge banners on desktop
        final bannerH = (constraints.maxWidth * 7 / 16).clamp(130.0, 280.0);
        return Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: bannerH,
                viewportFraction: 0.92,
                enlargeCenterPage: true,
                enlargeStrategy: CenterPageEnlargeStrategy.height,
                autoPlay: widget.banners.length > 1,
                autoPlayInterval: const Duration(seconds: 5),
                onPageChanged: (i, _) => setState(() => _current = i),
              ),
              items: widget.banners.map((banner) {
                return GestureDetector(
                  onTap: () => widget.onTap(banner),
                  child: ClipRRect(
                    borderRadius: AppBorderRadius.r16,
                    child: AppNetworkImage(
                      url: banner.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            ),
            if (widget.banners.length > 1) ...[
              SizedBox(height: 10.h),
              AnimatedSmoothIndicator(
                activeIndex: _current,
                count: widget.banners.length,
                effect: const ExpandingDotsEffect(
                  dotHeight: 7,
                  dotWidth: 7,
                  activeDotColor: AppColors.primaryDark,
                  dotColor: AppColors.border,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
