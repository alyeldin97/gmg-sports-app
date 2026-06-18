import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/product.dart';
import '../products_data_source.dart';

class SupabaseProductsDataSource implements ProductsDataSource {
  final SupabaseClient _client;
  SupabaseProductsDataSource(this._client);

  static const _select = '*, product_variants(*), product_collections(collection_id)';

  @override
  Future<List<Product>> getProducts({
    String? collectionId,
    bool featuredOnly = false,
    String? search,
  }) async {
    if (collectionId != null) {
      // Resolve product ids in this collection first, then fetch them.
      final links = await _client
          .from('product_collections')
          .select('product_id')
          .eq('collection_id', collectionId);
      final ids = (links as List).map((e) => e['product_id'] as String).toList();
      if (ids.isEmpty) return [];
      final rows = await _client
          .from('products')
          .select(_select)
          .inFilter('id', ids)
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return (rows as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    }

    var query = _client.from('products').select(_select).eq('is_active', true);
    if (featuredOnly) query = query.eq('is_featured', true);
    if (search != null && search.trim().isNotEmpty) {
      query = query.ilike('name', '%${search.trim()}%');
    }
    final rows = await query.order('created_at', ascending: false);
    return (rows as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Product> getProductById(String id) async {
    final row = await _client.from('products').select(_select).eq('id', id).single();
    return Product.fromJson(row);
  }

  @override
  Future<List<Product>> getProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final rows = await _client
        .from('products')
        .select(_select)
        .inFilter('id', ids)
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return (rows as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }
}
