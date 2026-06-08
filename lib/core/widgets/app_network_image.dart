import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../styling/colors.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _fallback();
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: fit,
      width: width,
      height: height,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.border,
        highlightColor: AppColors.primaryMist,
        child: Container(width: width, height: height, color: AppColors.white),
      ),
      errorWidget: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() => Container(
        width: width,
        height: height,
        color: AppColors.primaryMist,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textLight),
      );
}
