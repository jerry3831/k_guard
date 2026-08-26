import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/settings_usecases.dart';
import '../../domain/entities/user_preferences.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetPreferencesUseCase _getPreferences;
  final SavePreferencesUseCase _savePreferences;

  SettingsBloc({
    required GetPreferencesUseCase getPreferences,
    required SavePreferencesUseCase savePreferences,
  })  : _getPreferences = getPreferences,
        _savePreferences = savePreferences,
        super(const SettingsInitial()) {
    on<SettingsLoaded>(_onLoaded);
    on<SettingsNotificationsToggled>(_onNotifications);
    on<SettingsDarkModeToggled>(_onDarkMode);
    on<SettingsSoundEffectsToggled>(_onSoundEffects);
    on<SettingsVibrationToggled>(_onVibration);
  }

  Future<void> _onLoaded(
    SettingsLoaded event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final prefs = await _getPreferences().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException(
          'Settings load timed out',
        ),
      );
      emit(SettingsLoadSuccess(prefs));
    } on TimeoutException {
      emit(const SettingsLoadSuccess(UserPreferences.defaults()));
    } catch (_) {
      emit(const SettingsLoadSuccess(UserPreferences.defaults()));
    }
  }

  Future<void> _onNotifications(
    SettingsNotificationsToggled event,
    Emitter<SettingsState> emit,
  ) =>
      _updatePrefs(
        emit,
        (p) => p.copyWith(notificationsEnabled: event.value),
      );

  Future<void> _onDarkMode(
    SettingsDarkModeToggled event,
    Emitter<SettingsState> emit,
  ) =>
      _updatePrefs(
        emit,
        (p) => p.copyWith(darkModeEnabled: event.value),
      );

  Future<void> _onSoundEffects(
    SettingsSoundEffectsToggled event,
    Emitter<SettingsState> emit,
  ) =>
      _updatePrefs(
        emit,
        (p) => p.copyWith(soundEffectsEnabled: event.value),
      );

  Future<void> _onVibration(
    SettingsVibrationToggled event,
    Emitter<SettingsState> emit,
  ) =>
      _updatePrefs(
        emit,
        (p) => p.copyWith(vibrationEnabled: event.value),
      );

  Future<void> _updatePrefs(
    Emitter<SettingsState> emit,
    UserPreferences Function(UserPreferences) update,
  ) async {
    if (state is! SettingsLoadSuccess) return;
    final current = (state as SettingsLoadSuccess).preferences;
    final updated = update(current);
    emit(SettingsLoadSuccess(updated));
    try {
      await _savePreferences(updated).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException(
          'Settings save timed out',
        ),
      );
    } catch (_) {
    }
  }
}
