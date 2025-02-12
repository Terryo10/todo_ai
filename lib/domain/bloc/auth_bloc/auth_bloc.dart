import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/auth_repository/auth_repository.dart';
import '../cache_bloc/cache_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final CacheBloc cacheBloc;

  AuthBloc({
    required this.authRepository,
    required this.cacheBloc,
  }) : super(AuthInitial()) {
    on<LogOut>((event, emit) async {
      await authRepository.logOut();
      cacheBloc.add(AppStarted());
      emit(AuthInitial());
    });

    on<LoginWithGoogle>((event, emit) async {
      try {
        emit(AuthLoadingState());
        final result = await authRepository.loginWithGoogle();

        emit(AuthAuthenticatedState(
          userId: result?.uid ?? '',
          email: result?.email,
          displayName: result?.displayName,
          provider: 'google',
        ));
      } catch (e) {
        emit(AuthErrorState('Google sign in error: ${e.toString()}'));
      }
    });

    on<LoginWithApple>((event, emit) {
      print('fired apple');
    });

    on<LoginWithFacebook>((event, emit) {
      print('fired facebook');
    });
  }
}
