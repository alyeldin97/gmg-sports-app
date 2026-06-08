import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../helpers/app_border.dart';
import '../styling/colors.dart';
import '../styling/text_styles.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscure = false,
    this.prefixIcon,
    this.maxLines = 1,
    this.initialValue,
    this.onChanged,
  });

  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscure;
  final IconData? prefixIcon;
  final int maxLines;
  final String? initialValue;
  final ValueChanged<String>? onChanged;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.label(context)),
        SizedBox(height: 6.h),
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: _obscured,
          maxLines: widget.obscure ? 1 : widget.maxLines,
          onChanged: widget.onChanged,
          style: AppTextStyles.body(context),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 20.r, color: AppColors.textMid)
                : null,
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20.r,
                      color: AppColors.textMid,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: AppBorderRadius.r12,
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.r12,
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.r12,
              borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.r12,
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
