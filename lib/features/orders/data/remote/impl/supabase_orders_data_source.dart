import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/order.dart';
import '../orders_data_source.dart';

class SupabaseOrdersDataSource implements OrdersDataSource {
  final SupabaseClient _client;
  SupabaseOrdersDataSource(this._client);

  static const _select = '*, order_items(*), order_status_history(*)';

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw Exception('Not authenticated');
    return id;
  }

  @override
  Future<Order> createOrder({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> items,
  }) async {
    final inserted = await _client
        .from('orders')
        .insert({...orderData, 'user_id': _uid})
        .select()
        .single();
    final orderId = inserted['id'] as String;
    if (items.isNotEmpty) {
      await _client.from('order_items').insert(
            items.map((i) => {...i, 'order_id': orderId}).toList(),
          );
    }
    return getOrderById(orderId);
  }

  @override
  Future<List<Order>> getMyOrders() async {
    final rows = await _client
        .from('orders')
        .select(_select)
        .eq('user_id', _uid)
        .order('created_at', ascending: false);
    return (rows as List).map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Order> getOrderById(String id) async {
    final row = await _client.from('orders').select(_select).eq('id', id).single();
    return Order.fromJson(row);
  }

  @override
  Future<void> cancelOrder(String id) async {
    await _client
        .from('orders')
        .update({'status': 'cancelled'})
        .eq('id', id)
        .eq('user_id', _uid);
  }
}
