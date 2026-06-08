part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<AppBanner> banners;
  final List<Product> featured;
  final List<Collection> collections;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.banners = const [],
    this.featured = const [],
    this.collections = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<AppBanner>? banners,
    List<Product>? featured,
    List<Collection>? collections,
    String? errorMessage,
  }) =>
      HomeState(
        status: status ?? this.status,
        banners: banners ?? this.banners,
        featured: featured ?? this.featured,
        collections: collections ?? this.collections,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, banners, featured, collections, errorMessage];
}
