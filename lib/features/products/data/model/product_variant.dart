import 'package:equatable/equatable.dart';

class ProductVariant extends Equatable {
  final String id;
  final String productId;
  final String name;
  final String? nameAr;
  final double? price; // null → use product base price
  final int stock;
  final String? sku;
  final int sortOrder;

  const ProductVariant({
    required this.id,
    required this.productId,
    required this.name,
    this.nameAr,
    this.price,
    this.stock = 0,
    this.sku,
    this.sortOrder = 0,
  });

  bool get inStock => stock > 0;

  String localizedName(bool isArabic) =>
      (isArabic && nameAr != null && nameAr!.isNotEmpty) ? nameAr! : name;

  factory ProductVariant.fromJson(Map<String, dynamic> j) => ProductVariant(
        id: j['id'] as String,
        productId: j['product_id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        nameAr: j['name_ar'] as String?,
        price: (j['price'] as num?)?.toDouble(),
        stock: j['stock'] as int? ?? 0,
        sku: j['sku'] as String?,
        sortOrder: j['sort_order'] as int? ?? 0,
      );

  static ProductVariant fromLocalJson(Map<String, dynamic> j) => ProductVariant.fromJson(j);

  Map<String, dynamic> toJsonLocal() => {
        'id': id,
        'product_id': productId,
        'name': name,
        'name_ar': nameAr,
        'price': price,
        'stock': stock,
        'sku': sku,
        'sort_order': sortOrder,
      };

  @override
  List<Object?> get props => [id, name, price, stock];
}
