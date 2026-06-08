import 'package:equatable/equatable.dart';
import 'product_variant.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String? nameAr;
  final String? description;
  final String? descriptionAr;
  final double price;
  final double? compareAtPrice;
  final List<String> images;
  final int stock;
  final bool isActive;
  final bool isFeatured;
  final List<String> collectionIds;
  final List<ProductVariant> variants;

  const Product({
    required this.id,
    required this.name,
    this.nameAr,
    this.description,
    this.descriptionAr,
    required this.price,
    this.compareAtPrice,
    this.images = const [],
    this.stock = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.collectionIds = const [],
    this.variants = const [],
  });

  String? get primaryImage => images.isNotEmpty ? images.first : null;
  bool get hasVariants => variants.isNotEmpty;
  bool get inStock => hasVariants ? variants.any((v) => v.inStock) : stock > 0;

  bool get hasDiscount => compareAtPrice != null && compareAtPrice! > price;
  int get discountPercent =>
      hasDiscount ? (((compareAtPrice! - price) / compareAtPrice!) * 100).round() : 0;

  String localizedName(bool isArabic) =>
      (isArabic && nameAr != null && nameAr!.isNotEmpty) ? nameAr! : name;

  String? localizedDescription(bool isArabic) =>
      (isArabic && descriptionAr != null && descriptionAr!.isNotEmpty)
          ? descriptionAr
          : description;

  factory Product.fromJson(Map<String, dynamic> j) {
    final variants = (j['product_variants'] as List<dynamic>? ?? [])
        .where((v) => (v as Map<String, dynamic>)['is_active'] as bool? ?? true)
        .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return Product(
      id: j['id'] as String,
      name: j['name'] as String? ?? '',
      nameAr: j['name_ar'] as String?,
      description: j['description'] as String?,
      descriptionAr: j['description_ar'] as String?,
      price: (j['price'] as num?)?.toDouble() ?? 0,
      compareAtPrice: (j['compare_at_price'] as num?)?.toDouble(),
      images: (j['images'] as List<dynamic>?)?.cast<String>() ?? const [],
      stock: j['stock'] as int? ?? 0,
      isActive: j['is_active'] as bool? ?? true,
      isFeatured: j['is_featured'] as bool? ?? false,
      collectionIds: (j['product_collections'] as List<dynamic>? ?? [])
          .map((c) => (c as Map<String, dynamic>)['collection_id'] as String)
          .toList(),
      variants: variants,
    );
  }

  static Product fromLocalJson(Map<String, dynamic> j) => Product.fromJson(j);

  Map<String, dynamic> toJsonLocal() => {
        'id': id,
        'name': name,
        'name_ar': nameAr,
        'description': description,
        'description_ar': descriptionAr,
        'price': price,
        'compare_at_price': compareAtPrice,
        'images': images,
        'stock': stock,
        'is_active': isActive,
        'is_featured': isFeatured,
        'product_collections': collectionIds.map((id) => {'collection_id': id}).toList(),
        'product_variants': variants.map((v) => v.toJsonLocal()).toList(),
      };

  @override
  List<Object?> get props => [id, name, price, stock, isActive, variants];
}
