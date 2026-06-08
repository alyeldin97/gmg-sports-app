import '../model/app_banner.dart';

abstract class HomeDataSource {
  Future<List<AppBanner>> getBanners();
}
