part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthAuthenticatedState extends AuthState {
  final dynamic loginResponseModel;

  const AuthAuthenticatedState(this.loginResponseModel);
}

class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState(this.message);
}

class AuthRegistrationSuccessState extends AuthState {
  final dynamic registerResponseModel;
  const AuthRegistrationSuccessState({
    required this.registerResponseModel,
  });
}

class AuthVerificationSuccessState extends AuthState {}
