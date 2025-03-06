import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsModel {
  final bool isVibration;
  final bool isDarkMode;
  final bool isSilentMode;
  final String userId;

  SettingsModel({
    required this.isVibration,
    required this.isDarkMode,
    required this.isSilentMode,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'isVibration': isVibration,
      'userId': userId,
      'isSilentMode': isSilentMode,

      'isDarkMode': isDarkMode, // Added to map
    };
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      isVibration: map['isVibration'] ?? false,
      userId: map['userId'] ?? '',
      isSilentMode: map['isSilentMode'] ?? true,
      isDarkMode: map['isDarkMode'] ?? false,
    );
  }

  SettingsModel copyWith({
    bool? id,
    String? userId,
    bool? isSilentMode,
    bool? isDarkMode,
  }) {
    return SettingsModel(
      isVibration: isVibration,
      isSilentMode: this.isSilentMode,
      userId: userId ?? '',
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
