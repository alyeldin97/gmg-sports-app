import '../model/coupon.dart';
import '../remote/coupon_data_source.dart';
import 'coupon_repository.dart';

class CouponRepositoryImpl implements CouponRepository {
  final CouponDataSource _dataSource;
  CouponRepositoryImpl(this._dataSource);

  @override
  Future<Coupon?> getCouponByCode(String code) => _dataSource.getCouponByCode(code);

  @override
  Future<void> incrementUsedCount(String couponId) => _dataSource.incrementUsedCount(couponId);
}
