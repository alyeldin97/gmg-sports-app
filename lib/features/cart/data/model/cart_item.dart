import 'package:equatable/equatable.dart';
import '../../../products/data/model/product.dart';
import '../../../products/data/model/product_variant.dart';

class CartItem extends Equatable {
  final Product product;
  final ProductVariant? variant;
  final int quantity;

  const CartItem({
    required this.product,
    this.variant,
    required this.quantity,
  });

  double get unitPrice => variant?.price ?? product.price;
  double get subtotal => unitPrice * quantity;

  String get cartKey => '${product.id}__${variant?.id ?? ''}';

  CartItem copyWith({int? quantity}) => CartItem(
        product: product,
        variant: variant,
        quantity: quantity ?? this.quantity,
      );

  Map<String, dynamic> toLocalJson() => {
        'product': product.toJsonLocal(),
        'variant': variant?.toJsonLocal(),
        'quantity': quantity,
      };

  static CartItem fromLocalJson(Map<String, dynamic> j) => CartItem(
        product: Product.fromLocalJson(j['product'] as Map<String, dynamic>),
        variant: j['variant'] != null
            ? ProductVariant.fromLocalJson(j['variant'] as Map<String, dynamic>)
            : null,
        quantity: j['quantity'] as int,
      );

  @override
  List<Object?> get props => [product.id, variant?.id, quantity];
}
