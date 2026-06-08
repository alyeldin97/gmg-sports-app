part of 'auth_cubit.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  guest,
  unauthenticated,
  failure,
  passwordResetSent,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isGuest => status == AuthStatus.guest;
  bool get isLoggedIn => status == AuthStatus.authenticated && user != null;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? errorMessage,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, user, errorMessage];
}
