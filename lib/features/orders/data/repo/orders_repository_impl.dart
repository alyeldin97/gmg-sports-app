import '../model/order.dart';
import '../remote/orders_data_source.dart';
import 'orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersDataSource _dataSource;
  OrdersRepositoryImpl(this._dataSource);

  @override
  Future<Order> createOrder({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> items,
  }) =>
      _dataSource.createOrder(orderData: orderData, items: items);

  @override
  Future<List<Order>> getMyOrders() => _dataSource.getMyOrders();

  @override
  Future<Order> getOrderById(String id) => _dataSource.getOrderById(id);
}
