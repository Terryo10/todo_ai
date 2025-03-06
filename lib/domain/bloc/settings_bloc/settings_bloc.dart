import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../model/settings_model.dart';
import '../../repositories/auth_repository/auth_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final AuthRepository authRepository;

  SettingsBloc(this.authRepository) : super(SettingsInitial()) {
    on<SaveSettings>((event, emit) {
      // TODO: implement event handler
    });

    on<GetUserSettings>((event, emit) {
      // TODO: implement event handler
    });
  }
}
