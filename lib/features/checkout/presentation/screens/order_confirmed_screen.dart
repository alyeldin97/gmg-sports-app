import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../layout/presentation/screens/layout_screen.dart';
import '../../../orders/data/model/order.dart';
import '../../../orders/presentation/screens/order_details_screen.dart';

class OrderConfirmedScreen extends StatelessWidget {
  static const String routeName = '/order-confirmed';
  const OrderConfirmedScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.r),
                decoration: const BoxDecoration(color: AppColors.primaryMist, shape: BoxShape.circle),
                child: Icon(Icons.check_rounded, size: 64.r, color: AppColors.accentGreen),
              ),
              SizedBox(height: 24.h),
              Text(context.l10n.orderPlaced, style: AppTextStyles.heading1(context), textAlign: TextAlign.center),
              SizedBox(height: 8.h),
              Text(context.l10n.orderPlacedHint,
                  style: AppTextStyles.body(context), textAlign: TextAlign.center),
              SizedBox(height: 8.h),
              Text(context.l10n.orderNumber(order.shortId),
                  style: AppTextStyles.subtitle(context).copyWith(color: AppColors.primaryDark)),
              const Spacer(),
              AppButton(
                label: context.l10n.viewOrder,
                onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => OrderDetailsScreen(orderId: order.id),
                )),
              ),
              SizedBox(height: 12.h),
              AppButton(
                label: context.l10n.continueShopping,
                outlined: true,
                onPressed: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil(LayoutScreen.routeName, (_) => false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
