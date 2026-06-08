import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/address.dart';
import '../address_data_source.dart';

class SupabaseAddressDataSource implements AddressDataSource {
  final SupabaseClient _client;
  SupabaseAddressDataSource(this._client);

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw Exception('Not authenticated');
    return id;
  }

  @override
  Future<List<Address>> getAddresses() async {
    final rows = await _client
        .from('addresses')
        .select()
        .eq('user_id', _uid)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);
    return (rows as List).map((e) => Address.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _clearDefaults() async {
    await _client.from('addresses').update({'is_default': false}).eq('user_id', _uid);
  }

  @override
  Future<Address> addAddress(Address address) async {
    if (address.isDefault) await _clearDefaults();
    final row = await _client
        .from('addresses')
        .insert(address.toInsertJson(_uid))
        .select()
        .single();
    return Address.fromJson(row);
  }

  @override
  Future<Address> updateAddress(Address address) async {
    if (address.isDefault) await _clearDefaults();
    final row = await _client
        .from('addresses')
        .update(address.toInsertJson(_uid))
        .eq('id', address.id)
        .select()
        .single();
    return Address.fromJson(row);
  }

  @override
  Future<void> deleteAddress(String id) =>
      _client.from('addresses').delete().eq('id', id);
}
