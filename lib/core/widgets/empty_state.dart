import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../styling/colors.dart';
import '../styling/text_styles.dart';
import 'app_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: const BoxDecoration(
                color: AppColors.primaryMist,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44.r, color: AppColors.primaryDark),
            ),
            SizedBox(height: 16.h),
            Text(title, style: AppTextStyles.heading3(context), textAlign: TextAlign.center),
            if (subtitle != null) ...[
              SizedBox(height: 8.h),
              Text(subtitle!, style: AppTextStyles.bodySmall(context), textAlign: TextAlign.center),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 20.h),
              AppButton(label: actionLabel!, onPressed: onAction, expand: false),
            ],
          ],
        ),
      ),
    );
  }
}
