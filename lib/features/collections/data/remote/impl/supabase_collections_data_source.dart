import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/collection.dart';
import '../collections_data_source.dart';

class SupabaseCollectionsDataSource implements CollectionsDataSource {
  final SupabaseClient _client;
  SupabaseCollectionsDataSource(this._client);

  @override
  Future<List<Collection>> getCollections() async {
    final rows = await _client
        .from('collections')
        .select()
        .eq('is_active', true)
        .order('sort_order');
    return (rows as List).map((e) => Collection.fromJson(e as Map<String, dynamic>)).toList();
  }
}
