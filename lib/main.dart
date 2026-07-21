import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/ads/ad_service.dart';
import 'features/settings/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted settings before first frame so the theme is correct.
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );
  // Ensure settings load (and sync the exam-variant provider) at startup.
  container.read(settingsProvider);

  // Fire ad init + cold-launch app-open ad (non-blocking; ads never gate the UI).
  final adService = container.read(adServiceProvider);
  adService.init().then((_) => adService.showAppOpenIfAvailable());

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BandWiseApp(),
    ),
  );
}
