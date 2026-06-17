import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../model/app_user.dart';
import '../auth_data_source.dart';

class SupabaseAuthDataSource implements AuthDataSource {
  static const _tag = 'AuthDataSource';
  final SupabaseClient _client;

  SupabaseAuthDataSource(this._client);

  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    AppLogger.net(_tag, 'signIn attempt', email);
    try {
      final response = await _client.auth.signInWithPassword(email: email, password: password);
      AppLogger.d(_tag, 'signInWithPassword response: user=${response.user?.id}, session=${response.session != null}');

      final uid = response.user?.id;
      if (uid == null) {
        AppLogger.e(_tag, 'signIn failed: response.user is null');
        throw Exception('Sign-in failed');
      }

      AppLogger.i(_tag, 'auth ok uid=$uid, fetching profile...');
      return await _fetchProfile(uid, response.user!.email ?? email);
    } catch (e, st) {
      AppLogger.e(_tag, 'signIn error', e, st);
      rethrow;
    }
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    AppLogger.net(_tag, 'signUp', email);
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'phone': phone},
    );
    final uid = response.user?.id;
    if (uid == null) throw Exception('Registration failed');
    // A DB trigger creates the profile row; upsert as a safety net.
    await _client.from('profiles').upsert({
      'id': uid,
      'email': email,
      'name': name,
      'phone': phone,
    }, onConflict: 'id');
    return AppUser(id: uid, email: email, name: name, phone: phone);
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<AppUser?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    try {
      return await _fetchProfile(user.id, user.email ?? '');
    } catch (e) {
      AppLogger.w(_tag, 'getCurrentUser profile fetch failed', e);
      return null;
    }
  }

  @override
  Future<AppUser> updateProfile({String? name, String? phone}) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated');
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (updates.isNotEmpty) {
      await _client.from('profiles').update(updates).eq('id', uid);
    }
    return _fetchProfile(uid, _client.auth.currentUser!.email ?? '');
  }

  @override
  Future<void> sendPasswordReset({required String email}) =>
      _client.auth.resetPasswordForEmail(email);

  Future<AppUser> _fetchProfile(String uid, String email) async {
    AppLogger.net(_tag, 'fetchProfile from profiles uid=$uid');
    try {
      final data = await _client.from('profiles').select().eq('id', uid).single();
      AppLogger.d(_tag, 'profiles row: $data');
      return AppUser.fromJson({'id': uid, 'email': email, ...Map<String, dynamic>.from(data)});
    } catch (e, st) {
      AppLogger.e(_tag, 'fetchProfile failed uid=$uid', e, st);
      rethrow;
    }
  }
}
