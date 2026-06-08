import '../model/app_user.dart';
import '../remote/auth_data_source.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;
  AuthRepositoryImpl(this._dataSource);

  @override
  Future<AppUser> signIn({required String email, required String password}) =>
      _dataSource.signIn(email: email, password: password);

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) =>
      _dataSource.signUp(email: email, password: password, name: name, phone: phone);

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  Future<AppUser?> getCurrentUser() => _dataSource.getCurrentUser();

  @override
  Future<AppUser> updateProfile({String? name, String? phone}) =>
      _dataSource.updateProfile(name: name, phone: phone);

  @override
  Future<void> sendPasswordReset({required String email}) =>
      _dataSource.sendPasswordReset(email: email);
}
