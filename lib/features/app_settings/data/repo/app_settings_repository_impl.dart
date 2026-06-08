import '../model/app_settings.dart';
import '../remote/app_settings_data_source.dart';
import 'app_settings_repository.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  final AppSettingsDataSource _dataSource;
  AppSettingsRepositoryImpl(this._dataSource);

  @override
  Future<AppSettings> getSettings() => _dataSource.getSettings();
}
