import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/order.dart';
import '../orders_data_source.dart';

class SupabaseOrdersDataSource implements OrdersDataSource {
  final SupabaseClient _client;
  SupabaseOrdersDataSource(this._client);

  static const _select = '*, order_items(*), order_status_history(*)';

  String? get _uid => _client.auth.currentUser?.id;

  @override
  Future<Order> createOrder({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> items,
  }) async {
    final uid = _uid;
    final data = uid != null ? {...orderData, 'user_id': uid} : orderData;
    final inserted =
        await _client.from('orders').insert(data).select().single();
    final orderId = inserted['id'] as String;
    List<dynamic> insertedItems = [];
    if (items.isNotEmpty) {
      insertedItems = await _client
          .from('order_items')
          .insert(items.map((i) => {...i, 'order_id': orderId}).toList())
          .select();
    }
    // Authenticated users: fetch full order (includes history from trigger).
    if (uid != null) return getOrderById(orderId);
    // Guest users have no SELECT permission — build the Order from insert data.
    return Order.fromJson({
      ...inserted,
      'order_items': insertedItems,
      'order_status_history': [
        {'status': inserted['status'] ?? 'pending', 'created_at': inserted['created_at']},
      ],
    });
  }

  @override
  Future<List<Order>> getMyOrders() async {
    final uid = _uid;
    if (uid == null) return [];
    final rows = await _client
        .from('orders')
        .select(_select)
        .eq('user_id', uid)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Order> getOrderById(String id) async {
    final row =
        await _client.from('orders').select(_select).eq('id', id).single();
    return Order.fromJson(row);
  }

  @override
  Future<void> cancelOrder(String id) async {
    final uid = _uid;
    if (uid == null) return;
    await _client
        .from('orders')
        .update({'status': 'cancelled'})
        .eq('id', id)
        .eq('user_id', uid);
  }
}
