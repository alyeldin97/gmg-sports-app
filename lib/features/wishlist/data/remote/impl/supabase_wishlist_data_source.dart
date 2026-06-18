import 'package:supabase_flutter/supabase_flutter.dart';
import '../wishlist_data_source.dart';

class SupabaseWishlistDataSource implements WishlistDataSource {
  final SupabaseClient _client;
  SupabaseWishlistDataSource(this._client);

  @override
  Future<List<String>> getProductIds(String userId) async {
    final rows = await _client
        .from('wishlists')
        .select('product_id')
        .eq('user_id', userId);
    return (rows as List).map((e) => e['product_id'] as String).toList();
  }

  @override
  Future<void> add(String userId, String productId) async {
    await _client.from('wishlists').upsert({
      'user_id': userId,
      'product_id': productId,
    }, onConflict: 'user_id,product_id');
  }

  @override
  Future<void> remove(String userId, String productId) async {
    await _client
        .from('wishlists')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }
}
