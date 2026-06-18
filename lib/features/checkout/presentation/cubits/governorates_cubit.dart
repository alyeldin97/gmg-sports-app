import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/governorate.dart';
import '../../data/repo/governorates_repository.dart';

part 'governorates_state.dart';

class GovernoratesCubit extends Cubit<GovernoratesState> {
  final GovernoratesRepository _repository;
  GovernoratesCubit(this._repository) : super(const GovernoratesState());

  Future<void> load() async {
    emit(state.copyWith(status: GovernoratesStatus.loading));
    try {
      final govs = await _repository.getActiveGovernorates();
      emit(state.copyWith(status: GovernoratesStatus.success, governorates: govs));
    } catch (e) {
      emit(state.copyWith(status: GovernoratesStatus.failure, errorMessage: e.toString()));
    }
  }
}
