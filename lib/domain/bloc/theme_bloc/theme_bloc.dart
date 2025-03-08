import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'theme_event.dart';
part 'theme_state.dart';

enum AppTheme { light, dark, system }

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final FlutterSecureStorage storage;
  static const String _themeKey = 'app_theme';

  ThemeBloc({required this.storage}) : super(ThemeState.initial()) {
    on<ThemeLoaded>(_onThemeLoaded);
    on<ThemeChanged>(_onThemeChanged);
  }

  Future<void> _onThemeLoaded(
    ThemeLoaded event,
    Emitter<ThemeState> emit,
  ) async {
    final savedTheme = await storage.read(key: _themeKey);
    if (savedTheme != null) {
      final appTheme = AppTheme.values.firstWhere(
        (e) => e.toString() == savedTheme,
        orElse: () => AppTheme.system,
      );
      emit(_mapAppThemeToState(appTheme));
    }
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    final appTheme = event.theme;
    await storage.write(key: _themeKey, value: appTheme.toString());
    emit(_mapAppThemeToState(appTheme));
  }
  ThemeState _mapAppThemeToState(AppTheme appTheme) {
    ThemeMode themeMode;
    switch (appTheme) {
      case AppTheme.light:
        themeMode = ThemeMode.light;
        break;
      case AppTheme.dark:
        themeMode = ThemeMode.dark;
        break;
      case AppTheme.system:
        themeMode = ThemeMode.system;
        break;
    }
    return state.copyWith(themeMode: themeMode, appTheme: appTheme);
  }
}
