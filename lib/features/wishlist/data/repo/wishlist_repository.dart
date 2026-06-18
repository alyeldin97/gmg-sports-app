abstract class WishlistRepository {
  Future<List<String>> getProductIds(String userId);
  Future<void> add(String userId, String productId);
  Future<void> remove(String userId, String productId);
}
