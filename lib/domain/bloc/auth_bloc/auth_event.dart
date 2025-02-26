part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginWithGoogle extends AuthEvent {}

class LoginWithApple extends AuthEvent {}

class LogOut extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class AuthStateChanged extends AuthEvent {
  final UserModel user;

  const AuthStateChanged(this.user);
}
