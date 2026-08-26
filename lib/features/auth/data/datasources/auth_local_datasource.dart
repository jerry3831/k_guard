import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user_model.dart';


abstract class AuthLocalDataSource {
  Future<AppUserModel?> getCachedUser();
  Future<void> cacheUser(AppUserModel user);
  Future<void> clearCache();
  Future<bool> getRememberMe();
  Future<void> setRememberMe(bool value);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _keyUser       = 'auth_user';
  static const _keyRememberMe = 'auth_remember_me';

  SharedPreferences? _prefs;
  Completer<SharedPreferences>? _initCompleter;

  Future<SharedPreferences> get _sp async {
    if (_prefs != null) return _prefs!;
    if (_initCompleter != null) return _initCompleter!.future;

    _initCompleter = Completer<SharedPreferences>();
    try {
      final sp = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 5),
              onTimeout: () => throw TimeoutException(
                  'SharedPreferences.getInstance() timed out'));
      _prefs = sp;
      _initCompleter!.complete(sp);
      return sp;
    } catch (e) {
      _initCompleter = null;
      rethrow;
    }
  }

  bool get _usePreferences => true;


  @override
  Future<AppUserModel?> getCachedUser() async {
    if (!_usePreferences) return null;

    try {
      final sp = await _sp.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw TimeoutException(
          'SharedPreferences access timed out',
        ),
      );
      final raw = sp.getString(_keyUser);
      if (raw == null) return null;
      return AppUserModel.fromCacheMap(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      try {
        await clearCache().timeout(
          const Duration(seconds: 3),
          onTimeout: () => null,
        );
      } catch (_) {
      }
      return null;
    }
  }


  @override
  Future<void> cacheUser(AppUserModel user) async {
    if (!_usePreferences) return;

    final sp = await _sp;
    final encoded = jsonEncode(user.toCacheMap());
    final success = await sp.setString(_keyUser, encoded);
    if (!success) {
      throw Exception(
          'SharedPreferences.setString failed — device storage may be full');
    }
  }


  @override
  Future<void> clearCache() async {
    if (!_usePreferences) return;

    final sp = await _sp;
    await sp.remove(_keyUser);
    await sp.remove(_keyRememberMe);
  }


  @override
  Future<bool> getRememberMe() async {
    if (!_usePreferences) return false;

    try {
      final sp = await _sp;
      return sp.getBool(_keyRememberMe) ?? false;
    } catch (_) {
      return false; // safe default — user just signs in again
    }
  }


  @override
  Future<void> setRememberMe(bool value) async {
    if (!_usePreferences) return;

    final sp = await _sp;
    await sp.setBool(_keyRememberMe, value);
  }
}
