import '../model/app_settings.dart';

abstract class AppSettingsDataSource {
  Future<AppSettings> getSettings();
}
