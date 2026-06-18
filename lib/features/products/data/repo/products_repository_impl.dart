import '../model/product.dart';
import '../remote/products_data_source.dart';
import 'products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsDataSource _dataSource;
  ProductsRepositoryImpl(this._dataSource);

  @override
  Future<List<Product>> getProducts({String? collectionId, bool featuredOnly = false, String? search}) =>
      _dataSource.getProducts(collectionId: collectionId, featuredOnly: featuredOnly, search: search);

  @override
  Future<Product> getProductById(String id) => _dataSource.getProductById(id);

  @override
  Future<List<Product>> getProductsByIds(List<String> ids) => _dataSource.getProductsByIds(ids);
}
