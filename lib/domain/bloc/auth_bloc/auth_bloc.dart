import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../model/user_model.dart';
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
      emit(UnAuthenticatedState());
    });

    authRepository.authStateChanges.listen((user) {
      if (user != null) {
        add(AuthStateChanged(user));
      } 
    });

    on<CheckAuthStatus>((event, emit) async {
      final currentUser = authRepository.getCurrentUser();
      if (currentUser != null) {
        emit(AuthAuthenticatedState(
          userId: currentUser.uid,
          email: currentUser.email ?? '',
          displayName: currentUser.displayName ?? '',
          provider: currentUser.provider,
        ));
      } else {
        emit(UnAuthenticatedState());
      }
    });

    on<AuthStateChanged>((event, emit) {
      final user = event.user;
      emit(AuthAuthenticatedState(
        userId: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        provider: user.provider,
      ));
    });

    on<LoginWithGoogle>((event, emit) async {
      try {
        emit(AuthLoadingState());
        final result = await authRepository.loginWithGoogle();

        emit(AuthAuthenticatedState(
          userId: result.uid,
          email: result.email ?? '',
          displayName: result.displayName ?? '',
          provider: 'google',
        ));
      } catch (e) {
        print('kkkkkkkk ${e.toString()}');
        emit(AuthErrorState('Google sign in error: ${e.toString()}'));
      }
    });

    on<LoginWithApple>((event, emit) async {
      try {
        emit(AuthLoadingState());
        final result = await authRepository.loginWithApple();

        emit(AuthAuthenticatedState(
          userId: result.uid,
          email: result.email ?? '',
          displayName: result.displayName ?? '',
          provider: 'google',
        ));
      } catch (e) {
        emit(AuthErrorState('Apple sign in error: ${e.toString()}'));
      }
    });
  }
}
