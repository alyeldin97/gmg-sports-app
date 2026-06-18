import 'package:equatable/equatable.dart';

class Governorate extends Equatable {
  final String id;
  final String name;
  final String? nameAr;
  final double shippingCost;
  final int deliveryDays;
  final bool isActive;

  const Governorate({
    required this.id,
    required this.name,
    this.nameAr,
    required this.shippingCost,
    required this.deliveryDays,
    this.isActive = true,
  });

  String localizedName(bool isArabic) =>
      isArabic && nameAr != null && nameAr!.isNotEmpty ? nameAr! : name;

  factory Governorate.fromJson(Map<String, dynamic> j) => Governorate(
        id: j['id'] as String,
        name: j['name'] as String,
        nameAr: j['name_ar'] as String?,
        shippingCost: (j['shipping_cost'] as num?)?.toDouble() ?? 0,
        deliveryDays: j['delivery_days'] as int? ?? 3,
        isActive: j['is_active'] as bool? ?? true,
      );

  @override
  List<Object?> get props => [id, name, shippingCost, deliveryDays, isActive];
}
