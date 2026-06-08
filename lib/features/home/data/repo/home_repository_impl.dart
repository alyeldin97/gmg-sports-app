import '../model/app_banner.dart';
import '../remote/home_data_source.dart';
import 'home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDataSource _dataSource;
  HomeRepositoryImpl(this._dataSource);

  @override
  Future<List<AppBanner>> getBanners() => _dataSource.getBanners();
}
