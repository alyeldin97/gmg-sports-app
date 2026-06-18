import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/coupon.dart';
import '../../data/repo/coupon_repository.dart';

part 'coupon_state.dart';

class CouponCubit extends Cubit<CouponState> {
  final CouponRepository _repository;
  CouponCubit(this._repository) : super(const CouponState());

  Future<void> apply(String code, double subtotal) async {
    if (code.trim().isEmpty) return;
    emit(state.copyWith(status: CouponStatus.loading));
    try {
      final coupon = await _repository.getCouponByCode(code.trim());
      if (coupon == null || !coupon.isValid) {
        emit(state.copyWith(status: CouponStatus.invalid));
        return;
      }
      final discount = coupon.discountFor(subtotal);
      if (discount <= 0) {
        emit(state.copyWith(status: CouponStatus.invalid));
        return;
      }
      emit(state.copyWith(
          status: CouponStatus.applied, coupon: coupon, discount: discount));
    } catch (_) {
      emit(state.copyWith(status: CouponStatus.invalid));
    }
  }

  void clear() => emit(const CouponState());
}
