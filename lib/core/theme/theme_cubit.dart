import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(ThemeMode.light) {
    _loadTheme();
  }

  final SharedPreferences _prefs;
  static const _themeKey = 'theme_mode';

  void _loadTheme() {
    final saved = _prefs.getString(_themeKey);
    if (saved == 'dark') {
      emit(ThemeMode.dark);
    } else if (saved == 'system') {
      emit(ThemeMode.system);
    } else {
      emit(ThemeMode.light);
    }
  }

  void setLight() {
    _prefs.setString(_themeKey, 'light');
    emit(ThemeMode.light);
  }

  void setDark() {
    _prefs.setString(_themeKey, 'dark');
    emit(ThemeMode.dark);
  }

  void setSystem() {
    _prefs.setString(_themeKey, 'system');
    emit(ThemeMode.system);
  }

  void toggle() {
    if (state == ThemeMode.light) {
      setDark();
    } else {
      setLight();
    }
  }

  bool get isDark => state == ThemeMode.dark;
}
