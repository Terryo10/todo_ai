part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginWithCredentials extends AuthEvent {
  final String identifier;
  final String password;

  const LoginWithCredentials({
    required this.identifier,
    required this.password,
  });
}

class RegisterUser extends AuthEvent {
  final String name;
  final String identifier;
  final String password;
  final String passwordConfirmation;

  const RegisterUser({
    required this.name,
    required this.identifier,
    required this.password,
    required this.passwordConfirmation,
  });
}

class VerifyOTP extends AuthEvent {
  final String phone;
  final String otp;

 const VerifyOTP({
    required this.phone,
    required this.otp,
  });
}

class LoginWithGoogle extends AuthEvent {}

class LoginWithApple extends AuthEvent {}

class LogOut extends AuthEvent {}
