part of 'orders_cubit.dart';

enum OrdersStatus { initial, loading, success, failure }

class OrdersState extends Equatable {
  final OrdersStatus status;
  final List<Order> orders;
  final Order? selected;
  final String? errorMessage;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.selected,
    this.errorMessage,
  });

  OrdersState copyWith({
    OrdersStatus? status,
    List<Order>? orders,
    Order? selected,
    String? errorMessage,
  }) =>
      OrdersState(
        status: status ?? this.status,
        orders: orders ?? this.orders,
        selected: selected ?? this.selected,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, orders, selected, errorMessage];
}
