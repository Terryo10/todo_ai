import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/auth_repository/auth_repository.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final AuthRepository authRepository;

  EditProfileBloc(this.authRepository) : super(EditProfileInitial()) {
    on<EditProfile>((event, emit) async {
      try {
        emit(EditProfileLoadingState());
        await authRepository.editProfile(
            userId: event.userId, displayName: event.displayName);
        emit(EditProfileLoadedState('Profile saved successfully!!'));
      } catch (e) {
        emit(EditProfileErrorState(e.toString()));
      }
    });
  }
}
