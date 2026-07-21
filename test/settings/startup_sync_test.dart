import 'package:bandwise/features/exams/ielts/domain/ielts_models.dart';
import 'package:bandwise/features/exams/ielts/presentation/ielts_providers.dart';
import 'package:bandwise/features/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reading settingsProvider at startup does not throw and syncs the variant',
      () async {
    // Persisted preference: General Training.
    SharedPreferences.setMockInitialValues({'exam_variant': 'general_training'});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ]);
    addTearDown(container.dispose);

    // Mirrors main.dart: eagerly initialise settings. Previously this threw a
    // Riverpod "modified another provider during initialization" assertion.
    expect(() => container.read(settingsProvider), returnsNormally);

    // The deferred sync runs on a microtask; let it flush.
    await Future<void>.delayed(Duration.zero);

    expect(container.read(settingsProvider).variantId, 'general_training');
    expect(container.read(ieltsVariantProvider), IeltsVariant.generalTraining);
  });

  test('defaults to academic when nothing persisted', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ]);
    addTearDown(container.dispose);

    container.read(settingsProvider);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(ieltsVariantProvider), IeltsVariant.academic);
  });
}
