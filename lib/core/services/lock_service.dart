import 'package:shared_preferences/shared_preferences.dart';

class LockService {
  LockService(this._prefs);
  final SharedPreferences _prefs;

  static const _appLockKey    = 'app_lock_enabled';
  static const _appPinKey     = 'app_pin';

  // ── App Lock ──────────────────────────────────────────────────────────
  bool get isAppLockEnabled => _prefs.getBool(_appLockKey) ?? false;
  String get appPin => _prefs.getString(_appPinKey) ?? '';

  Future<void> enableAppLock(String pin) async {
    await _prefs.setBool(_appLockKey, true);
    await _prefs.setString(_appPinKey, pin);
  }

  Future<void> disableAppLock() async {
    await _prefs.setBool(_appLockKey, false);
    await _prefs.remove(_appPinKey);
  }

  bool verifyAppPin(String input) => input == appPin;
}
