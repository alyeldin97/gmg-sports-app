import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/app_banner.dart';
import '../home_data_source.dart';

class SupabaseHomeDataSource implements HomeDataSource {
  final SupabaseClient _client;
  SupabaseHomeDataSource(this._client);

  @override
  Future<List<AppBanner>> getBanners() async {
    final rows = await _client
        .from('banners')
        .select()
        .eq('is_active', true)
        .order('sort_order');
    return (rows as List).map((e) => AppBanner.fromJson(e as Map<String, dynamic>)).toList();
  }
}
