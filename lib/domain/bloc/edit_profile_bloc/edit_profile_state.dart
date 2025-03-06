part of 'edit_profile_bloc.dart';

sealed class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object> get props => [];
}

final class EditProfileInitial extends EditProfileState {}

class EditProfileLoadingState extends EditProfileState {}

class EditProfileLoadedState extends EditProfileState {
  final String message;

  const EditProfileLoadedState(this.message);
}

class EditProfileErrorState extends EditProfileState {
  final String message;

  const EditProfileErrorState(this.message);
}
