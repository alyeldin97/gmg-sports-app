import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/product.dart';
import '../../data/repo/products_repository.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductsRepository _repository;
  ProductsCubit(this._repository) : super(const ProductsState());

  Future<void> loadForCollection(String collectionId) async {
    emit(state.copyWith(status: ProductsStatus.loading));
    try {
      final products = await _repository.getProducts(collectionId: collectionId);
      emit(state.copyWith(status: ProductsStatus.success, products: products));
    } catch (e) {
      emit(state.copyWith(status: ProductsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> search(String term) async {
    emit(state.copyWith(status: ProductsStatus.loading));
    try {
      final products = await _repository.getProducts(search: term);
      emit(state.copyWith(status: ProductsStatus.success, products: products));
    } catch (e) {
      emit(state.copyWith(status: ProductsStatus.failure, errorMessage: e.toString()));
    }
  }
}
