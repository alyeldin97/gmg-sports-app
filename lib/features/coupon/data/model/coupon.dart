import 'package:equatable/equatable.dart';

enum DiscountType { percentage, fixed }

class Coupon extends Equatable {
  final String id;
  final String code;
  final DiscountType discountType;
  final double discountValue;
  final double? minOrderAmount;
  final int? maxUses;
  final int usedCount;
  final bool isActive;
  final DateTime? expiresAt;

  const Coupon({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount,
    this.maxUses,
    this.usedCount = 0,
    this.isActive = true,
    this.expiresAt,
  });

  bool get isValid {
    if (!isActive) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    if (maxUses != null && usedCount >= maxUses!) return false;
    return true;
  }

  double discountFor(double subtotal) {
    if (minOrderAmount != null && subtotal < minOrderAmount!) return 0;
    if (discountType == DiscountType.percentage) {
      return (subtotal * discountValue / 100).roundToDouble();
    }
    return discountValue.clamp(0, subtotal);
  }

  factory Coupon.fromJson(Map<String, dynamic> j) => Coupon(
        id: j['id'] as String,
        code: (j['code'] as String).toUpperCase(),
        discountType: (j['discount_type'] as String?) == 'fixed'
            ? DiscountType.fixed
            : DiscountType.percentage,
        discountValue: (j['discount_value'] as num?)?.toDouble() ?? 0,
        minOrderAmount: (j['min_order_amount'] as num?)?.toDouble(),
        maxUses: j['max_uses'] as int?,
        usedCount: j['used_count'] as int? ?? 0,
        isActive: j['is_active'] as bool? ?? true,
        expiresAt: j['expires_at'] == null
            ? null
            : DateTime.tryParse(j['expires_at'] as String),
      );

  @override
  List<Object?> get props => [id, code];
}
