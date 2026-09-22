import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_preferences.dart';

abstract class SettingsLocalDataSource {
  Future<UserPreferences> getPreferences();
  Future<void> savePreferences(UserPreferences prefs);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const _key = 'user_preferences';

  SharedPreferences? _prefs;
  Completer<SharedPreferences>? _initCompleter;

  Future<SharedPreferences> get _sp async {
    if (_prefs != null) return _prefs!;
    if (_initCompleter != null) return _initCompleter!.future;

    _initCompleter = Completer<SharedPreferences>();
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException(
          'SharedPreferences.getInstance() timed out',
        ),
      );
      _prefs = prefs;
      _initCompleter!.complete(prefs);
      return prefs;
    } catch (e) {
      _initCompleter = null;
      rethrow;
    }
  }

  @override
  Future<UserPreferences> getPreferences() async {
    try {
      final prefs = await _sp;
      final raw = prefs.getString(_key);
      if (raw == null) return const UserPreferences.defaults();
      return UserPreferences.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const UserPreferences.defaults();
    }
  }

  @override
  Future<void> savePreferences(UserPreferences prefs) async {
    final sp = await _sp;
    final success = await sp.setString(_key, jsonEncode(prefs.toMap()));
    if (!success) {
      throw Exception('Failed to persist user preferences');
    }
  }
}
