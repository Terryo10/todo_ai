part of 'cache_bloc.dart';

sealed class CacheState extends Equatable {
  const CacheState();

  @override
  List<Object> get props => [];
}

final class CacheInitialState extends CacheState {}

final class CacheLoadingState extends CacheState {}

final class CacheFoundState extends CacheState {}

final class CacheNotFoundState extends CacheState {
  final bool isAppFirstLaunch;
  const CacheNotFoundState({required this.isAppFirstLaunch});
}

final class CacheErrorState extends CacheState {
  final String message;
  const CacheErrorState({required this.message});
}
