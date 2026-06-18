import '../model/coupon.dart';

abstract class CouponDataSource {
  Future<Coupon?> getCouponByCode(String code);
  Future<void> incrementUsedCount(String couponId);
}
