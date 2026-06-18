import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../cart/data/model/cart_item.dart';
import '../../../orders/data/model/order.dart';
import '../../../orders/data/repo/orders_repository.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final OrdersRepository _repository;
  CheckoutCubit(this._repository) : super(const CheckoutState());

  void setDeliveryDate(DateTime date) =>
      emit(state.copyWith(status: CheckoutStatus.initial, deliveryDate: date));

  void setPaymentMethod(String method) =>
      emit(state.copyWith(status: CheckoutStatus.initial, paymentMethod: method));

  void reset() => emit(const CheckoutState());

  Future<void> placeOrder({
    required List<CartItem> items,
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required String governorateId,
    required String governorateName,
    required double shippingCost,
    required String city,
    required String street,
    String? apartment,
    String? notes,
  }) async {
    if (state.deliveryDate == null) {
      emit(state.copyWith(
          status: CheckoutStatus.failure, errorMessage: 'Please select a delivery date'));
      return;
    }
    emit(state.copyWith(status: CheckoutStatus.placing));
    try {
      final subtotal = items.fold(0.0, (sum, i) => sum + i.subtotal);
      final total = subtotal + shippingCost;

      final addressParts = [street.trim()];
      if (apartment != null && apartment.trim().isNotEmpty) addressParts.add(apartment.trim());
      addressParts.add(city.trim());
      addressParts.add(governorateName);

      final orderData = {
        'client_ref': const Uuid().v4(),
        'status': 'pending',
        'subtotal': subtotal,
        'delivery_fee': shippingCost,
        'total': total,
        'payment_method': state.paymentMethod,
        'delivery_date': state.deliveryDate!.toIso8601String().split('T').first,
        'recipient_name': '${firstName.trim()} ${lastName.trim()}',
        'recipient_phone': phone.trim(),
        'address_text': addressParts.join(', '),
        'guest_email': email.trim(),
        'governorate_id': governorateId,
        'governorate_name': governorateName,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
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

      final order =
          await _repository.createOrder(orderData: orderData, items: orderItems);
      emit(state.copyWith(status: CheckoutStatus.success, createdOrder: order));
    } catch (e) {
      emit(state.copyWith(status: CheckoutStatus.failure, errorMessage: e.toString()));
    }
  }
}
