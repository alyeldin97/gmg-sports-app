import '../model/address.dart';

abstract class AddressDataSource {
  Future<List<Address>> getAddresses();
  Future<Address> addAddress(Address address);
  Future<Address> updateAddress(Address address);
  Future<void> deleteAddress(String id);
}
