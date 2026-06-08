import '../model/app_settings.dart';

abstract class AppSettingsRepository {
  Future<AppSettings> getSettings();
}
