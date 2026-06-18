part of 'coupon_cubit.dart';

enum CouponStatus { initial, loading, applied, invalid }

class CouponState extends Equatable {
  final CouponStatus status;
  final Coupon? coupon;
  final double discount;

  const CouponState({
    this.status = CouponStatus.initial,
    this.coupon,
    this.discount = 0,
  });

  bool get isApplied => status == CouponStatus.applied && coupon != null;

  CouponState copyWith({CouponStatus? status, Coupon? coupon, double? discount}) =>
      CouponState(
        status: status ?? this.status,
        coupon: coupon ?? this.coupon,
        discount: discount ?? this.discount,
      );

  @override
  List<Object?> get props => [status, coupon, discount];
}
