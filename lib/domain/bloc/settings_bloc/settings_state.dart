part of 'settings_bloc.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

final class SettingsInitial extends SettingsState {}

class UserSettingsLoadedState extends SettingsState {
  final String message;
  final SettingsModel settings;

  const UserSettingsLoadedState(this.message, this.settings);
}

class UserSettingsErrorState extends SettingsState {
  final String message;

  const UserSettingsErrorState(this.message);
}
