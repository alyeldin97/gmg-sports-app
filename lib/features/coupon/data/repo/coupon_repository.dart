import '../model/coupon.dart';

abstract class CouponRepository {
  Future<Coupon?> getCouponByCode(String code);
  Future<void> incrementUsedCount(String couponId);
}
