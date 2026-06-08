import '../model/collection.dart';

abstract class CollectionsRepository {
  Future<List<Collection>> getCollections();
}
