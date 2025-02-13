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
         print('fired goog');
        emit(AuthLoadingState());
        final result = await authRepository.loginWithGoogle();
        print('fired goog kkkkkkk${result.toString()}');

        emit(AuthAuthenticatedState(
          userId: result?.uid ?? '',
          email: result?.email,
          displayName: result?.displayName,
          provider: 'google',
        ));
      } catch (e) {
         print('fired goog $e');
        emit(AuthErrorState('Google sign in error: ${e.toString()}'));
      }
    });

    on<LoginWithApple>((event, emit) {
      print('fired apple');
    });

    on<LoginWithFacebook>((event, emit) async{
      try {
         print('fired ffaa');
        emit(AuthLoadingState());
        final result = await authRepository.loginWithFacebook();
        print('fired faaa kkkkkkk${result.toString()}');

        emit(AuthAuthenticatedState(
          userId: result?.uid ?? '',
          email: result?.email,
          displayName: result?.displayName,
          provider: 'facebook',
        ));
      } catch (e) {
         print('fired faceboo $e');
        emit(AuthErrorState('faceboo sign in error: ${e.toString()}'));
      }
    });
  }
}
