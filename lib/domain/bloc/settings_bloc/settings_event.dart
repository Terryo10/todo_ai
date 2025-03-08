part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class SaveSettings extends SettingsEvent {
  final String userId;
  final bool isDarkMode;
  final bool isSilentMode;
  final bool isVibration;

  const SaveSettings(this.isSilentMode, this.isVibration,
      {required this.userId, required this.isDarkMode});
}

class GetUserSettings extends SettingsEvent {
  final String userId;

  const GetUserSettings({required this.userId});
}
