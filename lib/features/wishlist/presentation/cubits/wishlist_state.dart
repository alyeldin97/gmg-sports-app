part of 'wishlist_cubit.dart';

enum WishlistStatus { initial, loading, loaded }

class WishlistState extends Equatable {
  final WishlistStatus status;
  final Set<String> productIds;

  const WishlistState({
    this.status = WishlistStatus.initial,
    this.productIds = const {},
  });

  bool contains(String id) => productIds.contains(id);

  WishlistState copyWith({WishlistStatus? status, Set<String>? productIds}) => WishlistState(
        status: status ?? this.status,
        productIds: productIds ?? this.productIds,
      );

  @override
  List<Object?> get props => [status, productIds];
}
