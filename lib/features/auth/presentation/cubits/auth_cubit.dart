import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/model/app_user.dart';
import '../../data/repo/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  static const _tag = 'AuthCubit';
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthState()) {
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _repository.getCurrentUser();
      emit(user != null
          ? state.copyWith(status: AuthStatus.authenticated, user: user)
          : const AuthState(status: AuthStatus.guest));
    } catch (e, st) {
      AppLogger.e(_tag, 'checkCurrentUser failed', e, st);
      emit(const AuthState(status: AuthStatus.guest));
    }
  }

  /// Browse without an account. Cart stays local; checkout will prompt sign-in.
  void continueAsGuest() => emit(const AuthState(status: AuthStatus.guest));

  bool get isAuthenticated => state.status == AuthStatus.authenticated;

  Future<void> signIn({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _repository.signIn(email: email, password: password);
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (e, st) {
      AppLogger.e(_tag, 'signIn failed', e, st);
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: _parseError(e)));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _repository.signUp(email: email, password: password, name: name, phone: phone);
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (e, st) {
      AppLogger.e(_tag, 'signUp failed', e, st);
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: _parseError(e)));
    }
  }

  Future<void> sendPasswordReset({required String email}) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _repository.sendPasswordReset(email: email);
      emit(state.copyWith(status: AuthStatus.passwordResetSent));
    } catch (e, st) {
      AppLogger.e(_tag, 'sendPasswordReset failed', e, st);
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: _parseError(e)));
    }
  }

  Future<void> updateProfile({String? name, String? phone}) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final updated = await _repository.updateProfile(name: name, phone: phone);
      emit(state.copyWith(status: AuthStatus.authenticated, user: updated));
    } catch (e, st) {
      AppLogger.e(_tag, 'updateProfile failed', e, st);
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    emit(const AuthState(status: AuthStatus.guest));
  }

  String _parseError(Object e) {
    final msg = e.toString();
    if (msg.contains('Invalid login credentials')) return 'Invalid email or password';
    if (msg.contains('Email not confirmed')) return 'Please confirm your email first';
    if (msg.contains('User already registered')) return 'An account with this email already exists';
    if (msg.contains('SocketException') || msg.contains('network')) return 'Network error. Check your connection';
    return 'Something went wrong. Please try again';
  }
}
