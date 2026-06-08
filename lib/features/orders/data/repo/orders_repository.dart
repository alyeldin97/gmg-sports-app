import '../model/order.dart';

abstract class OrdersRepository {
  Future<Order> createOrder({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> items,
  });
  Future<List<Order>> getMyOrders();
  Future<Order> getOrderById(String id);
}
