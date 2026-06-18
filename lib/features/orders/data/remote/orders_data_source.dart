import '../model/order.dart';

abstract class OrdersDataSource {
  Future<Order> createOrder({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> items,
  });
  Future<List<Order>> getMyOrders();
  Future<Order> getOrderById(String id);
  Future<void> cancelOrder(String id);
}
