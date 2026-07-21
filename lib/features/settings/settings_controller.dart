import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../exams/ielts/domain/ielts_models.dart';
import '../exams/ielts/presentation/ielts_providers.dart';

/// Lightweight app settings, persisted with shared_preferences.
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.variantId = 'academic',
    this.rewardUnlockedDate,
  });

  final ThemeMode themeMode;
  final String variantId;

  /// The date (yyyy-MM-dd) the daily rewarded perk was last unlocked.
  final String? rewardUnlockedDate;

  AppSettings copyWith({ThemeMode? themeMode, String? variantId, String? rewardUnlockedDate}) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        variantId: variantId ?? this.variantId,
        rewardUnlockedDate: rewardUnlockedDate ?? this.rewardUnlockedDate,
      );
}

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._ref, this._prefs) : super(const AppSettings()) {
    _load();
  }

  final Ref _ref;
  final SharedPreferences _prefs;

  static const _kTheme = 'theme_mode';
  static const _kVariant = 'exam_variant';
  static const _kReward = 'reward_unlocked_date';

  void _load() {
    final theme = switch (_prefs.getString(_kTheme)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final variant = _prefs.getString(_kVariant) ?? 'academic';
    state = state.copyWith(
      themeMode: theme,
      variantId: variant,
      rewardUnlockedDate: _prefs.getString(_kReward),
    );
    // Keep the IELTS variant provider in sync at startup. Deferred to a
    // microtask because a provider may not modify another provider during its
    // own initialization (Riverpod throws an assertion otherwise). By the time
    // the microtask runs, this provider has finished building.
    Future.microtask(() {
      _ref.read(ieltsVariantProvider.notifier).state = IeltsVariant.fromId(variant);
    });
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(_kTheme, mode.name);
  }

  Future<void> setVariant(IeltsVariant variant) async {
    state = state.copyWith(variantId: variant.id);
    _ref.read(ieltsVariantProvider.notifier).state = variant;
    await _prefs.setString(_kVariant, variant.id);
  }

  Future<void> unlockRewardToday(String today) async {
    state = state.copyWith(rewardUnlockedDate: today);
    await _prefs.setString(_kReward, today);
  }
}

/// Provided at app start (overridden with a real SharedPreferences instance).
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

final settingsProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
  return SettingsController(ref, ref.watch(sharedPreferencesProvider));
});
