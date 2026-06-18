import '../model/product.dart';

abstract class ProductsRepository {
  Future<List<Product>> getProducts({String? collectionId, bool featuredOnly = false, String? search});
  Future<Product> getProductById(String id);
  Future<List<Product>> getProductsByIds(List<String> ids);
}
