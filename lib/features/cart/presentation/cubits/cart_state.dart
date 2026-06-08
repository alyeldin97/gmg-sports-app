part of 'cart_cubit.dart';

class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => items.fold(0, (sum, i) => sum + i.subtotal);
  bool get isEmpty => items.isEmpty;

  CartState copyWith({List<CartItem>? items}) => CartState(items: items ?? this.items);

  @override
  List<Object?> get props => [items];
}
