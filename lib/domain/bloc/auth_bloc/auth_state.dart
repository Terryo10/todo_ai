part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

class AuthLoadingState extends AuthState {}

class UnAuthenticatedState extends AuthState {}

class AuthAuthenticatedState extends AuthState {
  final String userId;
  final String email;
  final String displayName;
  final String provider;

  const AuthAuthenticatedState({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.provider,
  });

  @override
  List<Object> get props => [userId, provider];
}

class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState(this.message);
}
