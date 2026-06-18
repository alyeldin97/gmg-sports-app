import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/extensions/price_x.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../data/model/order.dart';
import '../cubits/orders_cubit.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    if (context.read<AuthCubit>().state.isLoggedIn) {
      context.read<OrdersCubit>().loadMyOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        title: Text(context.l10n.myOrders, style: AppTextStyles.heading2(context)),
      ),
      body: !auth.isLoggedIn
          ? EmptyState(
              icon: Icons.receipt_long_outlined,
              title: context.l10n.guestCheckoutTitle,
              subtitle: context.l10n.guestPrompt,
              actionLabel: context.l10n.signIn,
              onAction: () => Navigator.of(context).pushNamed(LoginScreen.routeName),
            )
          : BlocBuilder<OrdersCubit, OrdersState>(
              builder: (context, state) {
                if (state.status == OrdersStatus.loading || state.status == OrdersStatus.initial) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
                }
                if (state.status == OrdersStatus.failure) {
                  return EmptyState(
                    icon: Icons.wifi_off_rounded,
                    title: context.l10n.somethingWrong,
                    actionLabel: context.l10n.retry,
                    onAction: () => context.read<OrdersCubit>().loadMyOrders(),
                  );
                }
                if (state.orders.isEmpty) {
                  return EmptyState(icon: Icons.receipt_long_outlined, title: context.l10n.noOrders);
                }
                return RefreshIndicator(
                  color: AppColors.primaryDark,
                  onRefresh: () => context.read<OrdersCubit>().loadMyOrders(),
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.r),
                    itemCount: state.orders.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, i) => _OrderCard(order: state.orders[i]),
                  ),
                );
              },
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(orderId: order.id),
      )),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppBorderRadius.r16,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(context.l10n.orderNumber(order.shortId), style: AppTextStyles.subtitle(context)),
                const Spacer(),
                _StatusChip(status: order.status),
              ],
            ),
            SizedBox(height: 6.h),
            Text(DateFormat('d MMM yyyy').format(order.createdAt), style: AppTextStyles.bodySmall(context)),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${order.items.length} ${context.l10n.orderItems}', style: AppTextStyles.body(context)),
                Text('${order.total.asPrice} ${context.l10n.currency}', style: AppTextStyles.price(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: AppBorderRadius.full,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14.r, color: status.color),
          SizedBox(width: 4.w),
          Text(status.localizedLabel(context),
              style: AppTextStyles.bodySmall(context).copyWith(color: status.color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
