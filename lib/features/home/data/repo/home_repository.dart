import '../model/app_banner.dart';

abstract class HomeRepository {
  Future<List<AppBanner>> getBanners();
}
