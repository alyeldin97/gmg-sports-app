part of 'collections_cubit.dart';

enum CollectionsStatus { initial, loading, success, failure }

class CollectionsState extends Equatable {
  final CollectionsStatus status;
  final List<Collection> collections;
  final String? errorMessage;

  const CollectionsState({
    this.status = CollectionsStatus.initial,
    this.collections = const [],
    this.errorMessage,
  });

  CollectionsState copyWith({
    CollectionsStatus? status,
    List<Collection>? collections,
    String? errorMessage,
  }) =>
      CollectionsState(
        status: status ?? this.status,
        collections: collections ?? this.collections,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, collections, errorMessage];
}
