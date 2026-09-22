import '../entities/user_preferences.dart';
import '../repositories/settings_repository.dart';

class GetPreferencesUseCase {
  final SettingsRepository _repository;
  const GetPreferencesUseCase(this._repository);

  Future<UserPreferences> call() => _repository.getPreferences();
}

class SavePreferencesUseCase {
  final SettingsRepository _repository;
  const SavePreferencesUseCase(this._repository);

  Future<void> call(UserPreferences prefs) =>
      _repository.savePreferences(prefs);
}
