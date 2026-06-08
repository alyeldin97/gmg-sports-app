import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/app_settings.dart';
import '../app_settings_data_source.dart';

class SupabaseAppSettingsDataSource implements AppSettingsDataSource {
  final SupabaseClient _client;
  SupabaseAppSettingsDataSource(this._client);

  @override
  Future<AppSettings> getSettings() async {
    try {
      final row = await _client.from('app_settings').select().eq('id', 1).single();
      return AppSettings.fromJson(row);
    } catch (_) {
      return const AppSettings();
    }
  }
}
