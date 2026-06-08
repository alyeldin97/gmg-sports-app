import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/address.dart';
import '../../data/repo/address_repository.dart';

part 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final AddressRepository _repository;
  AddressCubit(this._repository) : super(const AddressState());

  Future<void> load() async {
    emit(state.copyWith(status: AddressStatus.loading));
    try {
      final addresses = await _repository.getAddresses();
      final selected = state.selectedId ??
          (addresses.where((a) => a.isDefault).isNotEmpty
              ? addresses.firstWhere((a) => a.isDefault).id
              : (addresses.isNotEmpty ? addresses.first.id : null));
      emit(state.copyWith(status: AddressStatus.success, addresses: addresses, selectedId: selected));
    } catch (e) {
      emit(state.copyWith(status: AddressStatus.failure, errorMessage: e.toString()));
    }
  }

  void select(String id) => emit(state.copyWith(selectedId: id));

  Future<void> save(Address address) async {
    emit(state.copyWith(status: AddressStatus.saving));
    try {
      final saved = address.id.isEmpty
          ? await _repository.addAddress(address)
          : await _repository.updateAddress(address);
      await load();
      emit(state.copyWith(status: AddressStatus.saved, selectedId: saved.id));
    } catch (e) {
      emit(state.copyWith(status: AddressStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> delete(String id) async {
    await _repository.deleteAddress(id);
    await load();
  }

  Address? get selectedAddress {
    final match = state.addresses.where((a) => a.id == state.selectedId);
    return match.isNotEmpty ? match.first : null;
  }
}
