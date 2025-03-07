import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsModel {
  final bool isVibrationMode;
  final bool isDarkMode;
  final bool isSilenceMode;
  final String userId;

  SettingsModel({
    required this.isVibrationMode,
    required this.isDarkMode,
    required this.isSilenceMode,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'isVibrationMode': isVibrationMode,
      'userId': userId,
      'isSilenceMode': isSilenceMode,

      'isDarkMode': isDarkMode, // Added to map
    };
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      isVibrationMode: map['isVibrationMode'] ?? false,
      userId: map['userId'] ?? '',
      isSilenceMode: map['isSilenceMode'] ?? true,
      isDarkMode: map['isDarkMode'] ?? false,
    );
  }

  SettingsModel copyWith({
    bool? id,
    String? userId,
    bool? isSilenceMode,
    bool? isDarkMode,
  }) {
    return SettingsModel(
      isVibrationMode: isVibrationMode,
      isSilenceMode: this.isSilenceMode,
      userId: userId ?? '',
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
