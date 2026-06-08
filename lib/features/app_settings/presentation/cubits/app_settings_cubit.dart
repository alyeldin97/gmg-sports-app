import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/app_settings.dart';
import '../../data/repo/app_settings_repository.dart';

class AppSettingsCubit extends Cubit<AppSettings> {
  final AppSettingsRepository _repository;
  AppSettingsCubit(this._repository) : super(const AppSettings());

  Future<void> load() async {
    try {
      emit(await _repository.getSettings());
    } catch (_) {}
  }
}
