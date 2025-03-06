part of 'edit_profile_bloc.dart';

sealed class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  @override
  List<Object> get props => [];
}

class EditProfile extends EditProfileEvent {
  final String userId;
  final String displayName;

  const EditProfile({required this.userId, required this.displayName});
}
