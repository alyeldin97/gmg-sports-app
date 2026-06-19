import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../collections/data/model/collection.dart';
import '../../../collections/data/repo/collections_repository.dart';
import '../../../products/data/model/product.dart';
import '../../../products/data/repo/products_repository.dart';
import '../../data/model/app_banner.dart';
import '../../data/repo/home_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository;
  final ProductsRepository _productsRepository;
  final CollectionsRepository _collectionsRepository;

  HomeCubit(this._homeRepository, this._productsRepository, this._collectionsRepository)
      : super(const HomeState());

  Future<void> load({bool autoRetry = true}) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final results = await Future.wait([
        _homeRepository.getBanners(),
        _productsRepository.getProducts(featuredOnly: true),
        _collectionsRepository.getCollections(),
      ]);
      emit(state.copyWith(
        status: HomeStatus.success,
        banners: results[0] as List<AppBanner>,
        featured: results[1] as List<Product>,
        collections: results[2] as List<Collection>,
      ));
    } catch (e) {
      if (autoRetry && !isClosed) {
        await Future.delayed(const Duration(seconds: 2));
        if (!isClosed) return load(autoRetry: false);
      }
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()));
    }
  }
}
