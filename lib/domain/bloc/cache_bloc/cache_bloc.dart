import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../repositories/cache_repository/cache_repository.dart';
import '../../../static/app_strings.dart';

part 'cache_event.dart';
part 'cache_state.dart';

class CacheBloc extends Bloc<CacheEvent, CacheState> {
  final CacheRepository cacheRepository;
  CacheBloc({
    required this.cacheRepository,
  }) : super(CacheInitialState()) {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    on<AppStarted>((event, emit) async {
      emit(CacheLoadingState());
      try {
        googleSignIn.onCurrentUserChanged
            .listen((GoogleSignInAccount? account) {
          //save account to storage for google
        });
        googleSignIn.signInSilently();
        if (await cacheRepository.hasAuthenticationToken()) {
          emit(CacheFoundState());
        } else {
          if (await cacheRepository.firstAppLaunch()) {
            emit(const CacheNotFoundState(isAppFirstLaunch: false));
          } else {
            emit(const CacheNotFoundState(isAppFirstLaunch: true));
          }
        }
      } catch (e) {
        emit(
          const CacheErrorState(
            message: AppStrings.errorMessage,
          ),
        );
      }
    });
  }
}
