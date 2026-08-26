import '../../domain/entities/user_preferences.dart';

abstract class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoadSuccess extends SettingsState {
  final UserPreferences preferences;
  const SettingsLoadSuccess(this.preferences);

  SettingsLoadSuccess copyWith({UserPreferences? preferences}) =>
      SettingsLoadSuccess(preferences ?? this.preferences);
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
}
