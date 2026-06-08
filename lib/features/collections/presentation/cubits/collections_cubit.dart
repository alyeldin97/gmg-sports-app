import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/collection.dart';
import '../../data/repo/collections_repository.dart';

part 'collections_state.dart';

class CollectionsCubit extends Cubit<CollectionsState> {
  final CollectionsRepository _repository;
  CollectionsCubit(this._repository) : super(const CollectionsState());

  Future<void> load() async {
    emit(state.copyWith(status: CollectionsStatus.loading));
    try {
      final collections = await _repository.getCollections();
      emit(state.copyWith(status: CollectionsStatus.success, collections: collections));
    } catch (e) {
      emit(state.copyWith(status: CollectionsStatus.failure, errorMessage: e.toString()));
    }
  }
}
