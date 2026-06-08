import '../model/address.dart';
import '../remote/address_data_source.dart';
import 'address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressDataSource _dataSource;
  AddressRepositoryImpl(this._dataSource);

  @override
  Future<List<Address>> getAddresses() => _dataSource.getAddresses();

  @override
  Future<Address> addAddress(Address address) => _dataSource.addAddress(address);

  @override
  Future<Address> updateAddress(Address address) => _dataSource.updateAddress(address);

  @override
  Future<void> deleteAddress(String id) => _dataSource.deleteAddress(id);
}
