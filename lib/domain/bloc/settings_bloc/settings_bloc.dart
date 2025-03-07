import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../model/settings_model.dart';
import '../../repositories/auth_repository/auth_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final AuthRepository authRepository;

  SettingsBloc(this.authRepository) : super(SettingsInitial()) {
    on<SaveSettings>((event, emit) async {
      try {
        emit(SettingsloadingState());
        SettingsModel settings = await authRepository.saveSettings(
            userId: event.userId,
            isSilenceMode: event.isSilentMode,
            isDarkMode: event.isDarkMode,
            isVibrationMode: event.isVibration);
        emit(UserSettingsLoadedState(
            'Settings updated successfully!!', settings));
      } catch (e) {
        emit(UserSettingsErrorState(e.toString()));
      }
    });

    on<GetUserSettings>((event, emit) async {
      try {
        emit(SettingsloadingState());
        SettingsModel settings =
            await authRepository.getSettings(userId: event.userId);
        emit(UserSettingsLoadedState(
            'Settings fetched successfully!!', settings));
      } catch (e) {
        emit(UserSettingsErrorState(e.toString()));
      }
    });
  }
}
