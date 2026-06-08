part of 'checkout_cubit.dart';

enum CheckoutStatus { initial, placing, success, failure }

class CheckoutState extends Equatable {
  final CheckoutStatus status;
  final DateTime? deliveryDate;
  final String paymentMethod; // cod | instapay
  final Order? createdOrder;
  final String? errorMessage;

  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.deliveryDate,
    this.paymentMethod = 'cod',
    this.createdOrder,
    this.errorMessage,
  });

  CheckoutState copyWith({
    CheckoutStatus? status,
    DateTime? deliveryDate,
    String? paymentMethod,
    Order? createdOrder,
    String? errorMessage,
  }) =>
      CheckoutState(
        status: status ?? this.status,
        deliveryDate: deliveryDate ?? this.deliveryDate,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        createdOrder: createdOrder ?? this.createdOrder,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, deliveryDate, paymentMethod, createdOrder, errorMessage];
}
