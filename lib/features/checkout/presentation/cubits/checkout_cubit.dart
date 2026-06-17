import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../address/data/model/address.dart';
import '../../../cart/data/model/cart_item.dart';
import '../../../orders/data/model/order.dart';
import '../../../orders/data/repo/orders_repository.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final OrdersRepository _repository;
  CheckoutCubit(this._repository) : super(const CheckoutState());

  void setDeliveryDate(DateTime date) => emit(state.copyWith(status: CheckoutStatus.initial, deliveryDate: date));
  void setPaymentMethod(String method) => emit(state.copyWith(status: CheckoutStatus.initial, paymentMethod: method));

  Future<void> placeOrder({
    required List<CartItem> items,
    required Address address,
    required double subtotal,
    required double deliveryFee,
    String? notes,
  }) async {
    if (state.deliveryDate == null) {
      emit(state.copyWith(status: CheckoutStatus.failure, errorMessage: 'Please select a delivery date'));
      return;
    }
    emit(state.copyWith(status: CheckoutStatus.placing));
    try {
      final total = subtotal + deliveryFee;
      final orderData = {
        'status': 'pending',
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'total': total,
        'payment_method': state.paymentMethod,
        'delivery_date': state.deliveryDate!.toIso8601String().split('T').first,
        'recipient_name': address.fullName,
        'recipient_phone': address.phone,
        'address_text': address.fullAddress,
        'notes': notes,
      };
      final orderItems = items
          .map((i) => {
                'product_id': i.product.id,
                'variant_id': i.variant?.id,
                'name': i.product.name,
                'variant_name': i.variant?.name,
                'unit_price': i.unitPrice,
                'quantity': i.quantity,
                'subtotal': i.subtotal,
              })
          .toList();
      final order = await _repository.createOrder(orderData: orderData, items: orderItems);
      emit(state.copyWith(status: CheckoutStatus.success, createdOrder: order));
    } catch (e) {
      emit(state.copyWith(status: CheckoutStatus.failure, errorMessage: e.toString()));
    }
  }
}
