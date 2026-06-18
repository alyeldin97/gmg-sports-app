part of 'governorates_cubit.dart';

enum GovernoratesStatus { initial, loading, success, failure }

class GovernoratesState extends Equatable {
  final GovernoratesStatus status;
  final List<Governorate> governorates;
  final String? errorMessage;

  const GovernoratesState({
    this.status = GovernoratesStatus.initial,
    this.governorates = const [],
    this.errorMessage,
  });

  GovernoratesState copyWith({
    GovernoratesStatus? status,
    List<Governorate>? governorates,
    String? errorMessage,
  }) =>
      GovernoratesState(
        status: status ?? this.status,
        governorates: governorates ?? this.governorates,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, governorates, errorMessage];
}
