import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/governorate.dart';

class GovernoratesRepository {
  final SupabaseClient _client;
  GovernoratesRepository(this._client);

  Future<List<Governorate>> getActiveGovernorates() async {
    final rows = await _client
        .from('governorates')
        .select()
        .eq('is_active', true)
        .order('name', ascending: true);
    return (rows as List)
        .map((e) => Governorate.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
