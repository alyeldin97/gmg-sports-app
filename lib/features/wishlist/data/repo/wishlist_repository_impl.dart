import '../remote/wishlist_data_source.dart';
import 'wishlist_repository.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistDataSource _dataSource;
  WishlistRepositoryImpl(this._dataSource);

  @override
  Future<List<String>> getProductIds(String userId) => _dataSource.getProductIds(userId);

  @override
  Future<void> add(String userId, String productId) => _dataSource.add(userId, productId);

  @override
  Future<void> remove(String userId, String productId) => _dataSource.remove(userId, productId);
}
