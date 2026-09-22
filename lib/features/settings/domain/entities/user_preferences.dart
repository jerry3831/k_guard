class UserPreferences {
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final bool soundEffectsEnabled;
  final bool vibrationEnabled;

  const UserPreferences({
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.soundEffectsEnabled = true,
    this.vibrationEnabled = true,
  });

  const UserPreferences.defaults()
      : notificationsEnabled = true,
        darkModeEnabled = false,
        soundEffectsEnabled = true,
        vibrationEnabled = true;

  UserPreferences copyWith({
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    bool? soundEffectsEnabled,
    bool? vibrationEnabled,
  }) {
    return UserPreferences(
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  Map<String, dynamic> toMap() => {
        'notifications_enabled': notificationsEnabled,
        'dark_mode_enabled': darkModeEnabled,
        'sound_effects_enabled': soundEffectsEnabled,
        'vibration_enabled': vibrationEnabled,
      };

  factory UserPreferences.fromMap(Map<String, dynamic> map) =>
      UserPreferences(
        notificationsEnabled:
            map['notifications_enabled'] as bool? ?? true,
        darkModeEnabled: map['dark_mode_enabled'] as bool? ?? false,
        soundEffectsEnabled:
            map['sound_effects_enabled'] as bool? ?? true,
        vibrationEnabled: map['vibration_enabled'] as bool? ?? true,
      );
}
