import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/meta_pixel_service.dart';
import '../../data/model/app_settings.dart';
import '../../data/repo/app_settings_repository.dart';

class AppSettingsCubit extends Cubit<AppSettings> {
  final AppSettingsRepository _repository;
  AppSettingsCubit(this._repository) : super(const AppSettings());

  Future<void> load() async {
    try {
      final settings = await _repository.getSettings();
      emit(settings);
      if (settings.metaPixelId.isNotEmpty) {
        MetaPixelService.init(settings.metaPixelId);
      }
    } catch (_) {}
  }
}
