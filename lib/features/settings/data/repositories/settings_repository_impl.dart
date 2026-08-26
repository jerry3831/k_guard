import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _local;
  const SettingsRepositoryImpl({required SettingsLocalDataSource local})
      : _local = local;

  @override
  Future<UserPreferences> getPreferences() => _local.getPreferences();

  @override
  Future<void> savePreferences(UserPreferences prefs) =>
      _local.savePreferences(prefs);
}
