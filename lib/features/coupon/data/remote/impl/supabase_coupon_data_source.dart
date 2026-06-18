import 'package:supabase_flutter/supabase_flutter.dart';
import '../coupon_data_source.dart';
import '../../model/coupon.dart';

class SupabaseCouponDataSource implements CouponDataSource {
  final SupabaseClient _client;
  SupabaseCouponDataSource(this._client);

  @override
  Future<Coupon?> getCouponByCode(String code) async {
    final rows = await _client
        .from('coupons')
        .select()
        .eq('code', code.trim().toUpperCase())
        .limit(1);
    if ((rows as List).isEmpty) return null;
    return Coupon.fromJson(rows.first as Map<String, dynamic>);
  }

  @override
  Future<void> incrementUsedCount(String couponId) async {
    await _client.rpc('increment_coupon_used_count', params: {'coupon_id': couponId});
  }
}
