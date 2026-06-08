import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../helpers/app_border.dart';
import '../styling/colors.dart';
import '../styling/text_styles.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.outlined = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    final bg = outlined ? Colors.transparent : AppColors.primary;
    final fg = AppColors.ink;

    return SizedBox(
      width: expand ? double.infinity : null,
      height: 52.h,
      child: Material(
        color: disabled && !outlined ? AppColors.primary.withValues(alpha: 0.5) : bg,
        borderRadius: AppBorderRadius.r12,
        child: InkWell(
          borderRadius: AppBorderRadius.r12,
          onTap: disabled ? null : onPressed,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: AppBorderRadius.r12,
              border: outlined ? Border.all(color: AppColors.ink, width: 1.5) : null,
            ),
            child: loading
                ? SizedBox(
                    width: 22.r,
                    height: 22.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.ink,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 20.r, color: fg),
                        SizedBox(width: 8.w),
                      ],
                      Text(label, style: AppTextStyles.button(context).copyWith(color: fg)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
