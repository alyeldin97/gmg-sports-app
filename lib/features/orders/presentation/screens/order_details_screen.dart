import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/extensions/price_x.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../data/model/order.dart';
import '../cubits/orders_cubit.dart';

class OrderDetailsScreen extends StatelessWidget {
  static const String routeName = '/order-details';
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DependencyInjector().ordersCubit..loadOrder(orderId),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldBg,
          elevation: 0,
          title: Text(context.l10n.orderDetails, style: AppTextStyles.heading3(context)),
        ),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state.status == OrdersStatus.loading || state.selected == null) {
              if (state.status == OrdersStatus.failure) {
                return EmptyState(icon: Icons.error_outline, title: context.l10n.somethingWrong);
              }
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
            }
            final order = state.selected!;
            return ListView(
              padding: EdgeInsets.all(16.r),
              children: [
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(context.l10n.orderNumber(order.shortId), style: AppTextStyles.subtitle(context)),
                          const Spacer(),
                          Text(DateFormat('d MMM yyyy').format(order.createdAt),
                              style: AppTextStyles.bodySmall(context)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                Text(context.l10n.orderTracking, style: AppTextStyles.heading3(context)),
                SizedBox(height: 10.h),
                _Card(child: _Timeline(order: order)),
                SizedBox(height: 14.h),
                Text(context.l10n.orderItems, style: AppTextStyles.heading3(context)),
                SizedBox(height: 10.h),
                _Card(
                  child: Column(
                    children: [
                      for (final item in order.items) _ItemRow(item: item),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: const Divider(height: 1, color: AppColors.border),
                      ),
                      _summaryRow(context, context.l10n.subtotal, order.subtotal),
                      SizedBox(height: 4.h),
                      _summaryRow(context, context.l10n.deliveryFee, order.deliveryFee),
                      SizedBox(height: 6.h),
                      _summaryRow(context, context.l10n.total, order.total, bold: true),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.deliveryAddress, style: AppTextStyles.subtitle(context)),
                      SizedBox(height: 6.h),
                      Text('${order.recipientName} · ${order.recipientPhone}',
                          style: AppTextStyles.bodySmall(context)),
                      Text(order.addressText, style: AppTextStyles.body(context)),
                      SizedBox(height: 10.h),
                      Text(context.l10n.paymentMethod, style: AppTextStyles.subtitle(context)),
                      SizedBox(height: 4.h),
                      Text(order.isCod ? context.l10n.cod : context.l10n.instapay,
                          style: AppTextStyles.body(context)),
                      if (order.deliveryDate != null) ...[
                        SizedBox(height: 10.h),
                        Text(context.l10n.deliveryDate, style: AppTextStyles.subtitle(context)),
                        SizedBox(height: 4.h),
                        Text(DateFormat('EEE, d MMM yyyy').format(order.deliveryDate!),
                            style: AppTextStyles.body(context)),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, double value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: bold ? AppTextStyles.subtitle(context) : AppTextStyles.label(context)),
        Text('${value.asPrice} ${context.l10n.currency}',
            style: bold ? AppTextStyles.price(context) : AppTextStyles.body(context)),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.r16,
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.primaryMist, borderRadius: AppBorderRadius.r8),
            child: Text('${item.quantity}×',
                style: AppTextStyles.bodySmall(context).copyWith(color: AppColors.primaryDark)),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTextStyles.body(context)),
                if (item.variantName != null)
                  Text(item.variantName!, style: AppTextStyles.bodySmall(context)),
              ],
            ),
          ),
          Text('${item.subtotal.asPrice} ${context.l10n.currency}', style: AppTextStyles.label(context)),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    if (order.status == OrderStatus.cancelled) {
      return Row(
        children: [
          Icon(OrderStatus.cancelled.icon, color: AppColors.error),
          SizedBox(width: 10.w),
          Text(OrderStatus.cancelled.localizedLabel(context),
              style: AppTextStyles.subtitle(context).copyWith(color: AppColors.error)),
        ],
      );
    }
    final currentIndex = OrderStatus.pipeline.indexOf(order.status);
    return Column(
      children: List.generate(OrderStatus.pipeline.length, (i) {
        final status = OrderStatus.pipeline[i];
        final reached = i <= currentIndex;
        final isLast = i == OrderStatus.pipeline.length - 1;
        final event = order.history.where((e) => e.status == status);
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: reached ? AppColors.primary : AppColors.scaffoldBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: reached ? AppColors.primaryDark : AppColors.border),
                    ),
                    child: Icon(status.icon,
                        size: 15.r, color: reached ? AppColors.ink : AppColors.textLight),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: i < currentIndex ? AppColors.primaryDark : AppColors.border,
                      ),
                    ),
                ],
              ),
              SizedBox(width: 12.w),
              Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 18.h, top: 4.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.localizedLabel(context),
                      style: AppTextStyles.label(context).copyWith(
                        color: reached ? AppColors.textDark : AppColors.textLight,
                        fontWeight: reached ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (event.isNotEmpty)
                      Text(DateFormat('d MMM, h:mm a').format(event.first.createdAt),
                          style: AppTextStyles.bodySmall(context)),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
