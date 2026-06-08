import '../model/collection.dart';

abstract class CollectionsDataSource {
  Future<List<Collection>> getCollections();
}
