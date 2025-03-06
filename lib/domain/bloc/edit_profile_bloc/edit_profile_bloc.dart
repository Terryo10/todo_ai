import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../model/user_model.dart';
import '../../repositories/auth_repository/auth_repository.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final AuthRepository authRepository;

  EditProfileBloc(this.authRepository) : super(EditProfileInitial()) {
    on<EditProfile>((event, emit) async {
      try {
        emit(EditProfileLoadingState());
        UserModel user = await authRepository.editProfile(
            userId: event.userId, displayName: event.displayName);
        emit(EditProfileLoadedState('Profile saved successfully!!', user));
      } catch (e) {
        emit(EditProfileErrorState(e.toString()));
      }
    });

    on<GetProfile>((event, emit) async {
      try {
        emit(EditProfileLoadingState());
        UserModel user = await authRepository.getProfile(userId: event.userId);
        emit(EditProfileLoadedState('Profile fetched successfully!!', user));
      } catch (e) {
        emit(EditProfileErrorState(e.toString()));
      }
    });
  }
}
