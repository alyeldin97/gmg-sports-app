part of 'address_cubit.dart';

enum AddressStatus { initial, loading, success, saving, saved, failure }

class AddressState extends Equatable {
  final AddressStatus status;
  final List<Address> addresses;
  final String? selectedId;
  final String? errorMessage;

  const AddressState({
    this.status = AddressStatus.initial,
    this.addresses = const [],
    this.selectedId,
    this.errorMessage,
  });

  AddressState copyWith({
    AddressStatus? status,
    List<Address>? addresses,
    String? selectedId,
    String? errorMessage,
  }) =>
      AddressState(
        status: status ?? this.status,
        addresses: addresses ?? this.addresses,
        selectedId: selectedId ?? this.selectedId,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, addresses, selectedId, errorMessage];
}
