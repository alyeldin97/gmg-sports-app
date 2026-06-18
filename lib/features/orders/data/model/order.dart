import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/styling/colors.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  outForDelivery,
  delivered,
  cancelled;

  static OrderStatus fromString(String v) => switch (v) {
        'confirmed' => OrderStatus.confirmed,
        'processing' => OrderStatus.processing,
        'out_for_delivery' => OrderStatus.outForDelivery,
        'delivered' => OrderStatus.delivered,
        'cancelled' => OrderStatus.cancelled,
        _ => OrderStatus.pending,
      };

  String get dbValue => switch (this) {
        OrderStatus.outForDelivery => 'out_for_delivery',
        _ => name,
      };

  String localizedLabel(BuildContext context) => switch (this) {
        OrderStatus.pending => context.l10n.statusPending,
        OrderStatus.confirmed => context.l10n.statusConfirmed,
        OrderStatus.processing => context.l10n.statusProcessing,
        OrderStatus.outForDelivery => context.l10n.statusOutForDelivery,
        OrderStatus.delivered => context.l10n.statusDelivered,
        OrderStatus.cancelled => context.l10n.statusCancelled,
      };

  Color get color => switch (this) {
        OrderStatus.pending => AppColors.accentOrange,
        OrderStatus.confirmed => AppColors.primaryDark,
        OrderStatus.processing => AppColors.primaryDark,
        OrderStatus.outForDelivery => AppColors.accentOrange,
        OrderStatus.delivered => AppColors.accentGreen,
        OrderStatus.cancelled => AppColors.error,
      };

  IconData get icon => switch (this) {
        OrderStatus.pending => Icons.schedule_rounded,
        OrderStatus.confirmed => Icons.check_circle_outline_rounded,
        OrderStatus.processing => Icons.inventory_2_outlined,
        OrderStatus.outForDelivery => Icons.local_shipping_outlined,
        OrderStatus.delivered => Icons.task_alt_rounded,
        OrderStatus.cancelled => Icons.cancel_outlined,
      };

  /// Ordered pipeline used to render the tracking timeline.
  static const pipeline = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.processing,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];
}

class OrderItem extends Equatable {
  final String name;
  final String? variantName;
  final double unitPrice;
  final int quantity;
  final double subtotal;

  const OrderItem({
    required this.name,
    this.variantName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        name: j['name'] as String? ?? '',
        variantName: j['variant_name'] as String?,
        unitPrice: (j['unit_price'] as num?)?.toDouble() ?? 0,
        quantity: j['quantity'] as int? ?? 1,
        subtotal: (j['subtotal'] as num?)?.toDouble() ?? 0,
      );

  @override
  List<Object?> get props => [name, variantName, unitPrice, quantity];
}

class OrderStatusEvent extends Equatable {
  final OrderStatus status;
  final DateTime createdAt;

  const OrderStatusEvent({required this.status, required this.createdAt});

  factory OrderStatusEvent.fromJson(Map<String, dynamic> j) => OrderStatusEvent(
        status: OrderStatus.fromString(j['status'] as String? ?? 'pending'),
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  @override
  List<Object?> get props => [status, createdAt];
}

class Order extends Equatable {
  final String id;
  final OrderStatus status;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String paymentMethod; // cod | instapay
  final DateTime? deliveryDate;
  final String recipientName;
  final String recipientPhone;
  final String addressText;
  final String? notes;
  final DateTime createdAt;
  final List<OrderItem> items;
  final List<OrderStatusEvent> history;
  final String? guestEmail;
  final String? governorateName;

  const Order({
    required this.id,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    this.deliveryDate,
    required this.recipientName,
    required this.recipientPhone,
    required this.addressText,
    this.notes,
    required this.createdAt,
    this.items = const [],
    this.history = const [],
    this.guestEmail,
    this.governorateName,
  });

  String get shortId => id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
  bool get isCod => paymentMethod == 'cod';

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'] as String,
        status: OrderStatus.fromString(j['status'] as String? ?? 'pending'),
        subtotal: (j['subtotal'] as num?)?.toDouble() ?? 0,
        deliveryFee: (j['delivery_fee'] as num?)?.toDouble() ?? 0,
        total: (j['total'] as num?)?.toDouble() ?? 0,
        paymentMethod: j['payment_method'] as String? ?? 'cod',
        deliveryDate: j['delivery_date'] != null ? DateTime.tryParse(j['delivery_date'] as String) : null,
        recipientName: j['recipient_name'] as String? ?? '',
        recipientPhone: j['recipient_phone'] as String? ?? '',
        addressText: j['address_text'] as String? ?? '',
        notes: j['notes'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
        guestEmail: j['guest_email'] as String?,
        governorateName: j['governorate_name'] as String?,
        items: (j['order_items'] as List<dynamic>? ?? [])
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        history: ((j['order_status_history'] as List<dynamic>? ?? [])
            .map((e) => OrderStatusEvent.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt))),
      );

  @override
  List<Object?> get props => [id, status, total, guestEmail, governorateName];
}
