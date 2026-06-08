import '../model/product.dart';

abstract class ProductsDataSource {
  Future<List<Product>> getProducts({String? collectionId, bool featuredOnly = false, String? search});
  Future<Product> getProductById(String id);
}
