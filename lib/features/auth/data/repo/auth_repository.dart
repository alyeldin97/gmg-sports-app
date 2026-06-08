import '../model/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signIn({required String email, required String password});

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  });

  Future<void> signOut();

  Future<AppUser?> getCurrentUser();

  Future<AppUser> updateProfile({String? name, String? phone});

  Future<void> sendPasswordReset({required String email});
}
