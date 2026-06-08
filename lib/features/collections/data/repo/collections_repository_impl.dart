import '../model/collection.dart';
import '../remote/collections_data_source.dart';
import 'collections_repository.dart';

class CollectionsRepositoryImpl implements CollectionsRepository {
  final CollectionsDataSource _dataSource;
  CollectionsRepositoryImpl(this._dataSource);

  @override
  Future<List<Collection>> getCollections() => _dataSource.getCollections();
}
