import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/wishlist_repository.dart';

part 'wishlist_state.dart';

class WishlistCubit extends Cubit<WishlistState> {
  final WishlistRepository _repository;
  WishlistCubit(this._repository) : super(const WishlistState());

  Future<void> load(String userId) async {
    emit(state.copyWith(status: WishlistStatus.loading));
    try {
      final ids = await _repository.getProductIds(userId);
      emit(state.copyWith(status: WishlistStatus.loaded, productIds: ids.toSet()));
    } catch (_) {
      emit(state.copyWith(status: WishlistStatus.loaded, productIds: {}));
    }
  }

  Future<void> toggle(String userId, String productId) async {
    final isIn = state.productIds.contains(productId);
    final updated = Set<String>.from(state.productIds);
    if (isIn) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }
    emit(state.copyWith(productIds: updated));
    try {
      if (isIn) {
        await _repository.remove(userId, productId);
      } else {
        await _repository.add(userId, productId);
      }
    } catch (_) {
      final reverted = Set<String>.from(state.productIds);
      if (isIn) reverted.add(productId); else reverted.remove(productId);
      emit(state.copyWith(productIds: reverted));
    }
  }

  void clear() => emit(const WishlistState());
}
