abstract class SettingsEvent {
  const SettingsEvent();
}

class SettingsLoaded extends SettingsEvent {
  const SettingsLoaded();
}

class SettingsNotificationsToggled extends SettingsEvent {
  final bool value;
  const SettingsNotificationsToggled(this.value);
}

class SettingsDarkModeToggled extends SettingsEvent {
  final bool value;
  const SettingsDarkModeToggled(this.value);
}

class SettingsSoundEffectsToggled extends SettingsEvent {
  final bool value;
  const SettingsSoundEffectsToggled(this.value);
}

class SettingsVibrationToggled extends SettingsEvent {
  final bool value;
  const SettingsVibrationToggled(this.value);
}

class SettingsSignOutRequested extends SettingsEvent {
  const SettingsSignOutRequested();
}
