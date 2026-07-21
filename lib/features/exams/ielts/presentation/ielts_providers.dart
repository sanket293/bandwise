import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ielts_repository.dart';
import '../domain/ielts_models.dart';
import '../domain/ielts_scoring.dart';

/// Loads all IELTS data assets once and caches them.
final ieltsRepositoryProvider = Provider((ref) => IeltsRepository());

final ieltsDataProvider = FutureProvider<IeltsData>((ref) async {
  return ref.watch(ieltsRepositoryProvider).load();
});

/// Global exam variant (Academic / General Training) — shared across the
/// simulator, rubrics and log. Persisted via settings elsewhere.
final ieltsVariantProvider =
    StateProvider<IeltsVariant>((ref) => IeltsVariant.academic);

// ---------------------------------------------------------------------------
// Mode A — Simulate Overall Band
// ---------------------------------------------------------------------------

/// The four module bands the user is dialling in. Defaults to a mid value.
class ModuleBands {
  const ModuleBands({
    this.listening = 6.5,
    this.reading = 6.5,
    this.writing = 6.0,
    this.speaking = 6.5,
  });

  final double listening;
  final double reading;
  final double writing;
  final double speaking;

  ModuleBands copyWith({double? listening, double? reading, double? writing, double? speaking}) =>
      ModuleBands(
        listening: listening ?? this.listening,
        reading: reading ?? this.reading,
        writing: writing ?? this.writing,
        speaking: speaking ?? this.speaking,
      );

  double bandFor(IeltsModule m) => switch (m) {
        IeltsModule.listening => listening,
        IeltsModule.reading => reading,
        IeltsModule.writing => writing,
        IeltsModule.speaking => speaking,
      };
}

class ModuleBandsNotifier extends StateNotifier<ModuleBands> {
  ModuleBandsNotifier() : super(const ModuleBands());

  void set(IeltsModule m, double band) {
    state = switch (m) {
      IeltsModule.listening => state.copyWith(listening: band),
      IeltsModule.reading => state.copyWith(reading: band),
      IeltsModule.writing => state.copyWith(writing: band),
      IeltsModule.speaking => state.copyWith(speaking: band),
    };
  }
}

final moduleBandsProvider =
    StateNotifierProvider<ModuleBandsNotifier, ModuleBands>((ref) => ModuleBandsNotifier());

/// Live-computed Overall Band result — updates as the user drags any picker.
final overallResultProvider = Provider<OverallBandResult>((ref) {
  final b = ref.watch(moduleBandsProvider);
  return IeltsScoring.overallBand(
    listening: b.listening,
    reading: b.reading,
    writing: b.writing,
    speaking: b.speaking,
  );
});

// ---------------------------------------------------------------------------
// Mode B — What band is my raw score?
// ---------------------------------------------------------------------------

/// Which raw-based module Mode B is inspecting.
final modeBModuleProvider =
    StateProvider<IeltsModule>((ref) => IeltsModule.listening);

/// The raw score (out of 40) the user has entered.
final modeBRawProvider = StateProvider<int>((ref) => 30);

/// Whether Mode B shows the conversion as a graph or a table.
enum ModeBView { graph, table }

/// Defaults to table; the persisted choice is applied at startup by
/// [SettingsController] and updated via `setRawView`.
final modeBViewProvider = StateProvider<ModeBView>((ref) => ModeBView.table);
