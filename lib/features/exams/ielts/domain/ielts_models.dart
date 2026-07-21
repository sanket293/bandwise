/// Pure-Dart domain models for the IELTS exam module.
///
/// This file intentionally has NO Flutter imports so the trust-critical scoring
/// logic can be unit-tested in isolation. JSON parsing lives here too (plain
/// `Map`/`List`), while the Flutter asset loader (which uses `rootBundle`) is a
/// thin wrapper in the `data/` layer.
library;

/// IELTS test variant. Affects only the Reading conversion table.
enum IeltsVariant {
  academic('academic', 'Academic'),
  generalTraining('general_training', 'General Training');

  const IeltsVariant(this.id, this.label);
  final String id;
  final String label;

  static IeltsVariant fromId(String id) =>
      values.firstWhere((v) => v.id == id, orElse: () => IeltsVariant.academic);
}

/// The four assessed modules.
enum IeltsModule {
  listening('listening', 'Listening', rawBased: true),
  reading('reading', 'Reading', rawBased: true),
  writing('writing', 'Writing', rawBased: false),
  speaking('speaking', 'Speaking', rawBased: false);

  const IeltsModule(this.id, this.label, {required this.rawBased});
  final String id;
  final String label;

  /// Whether a band comes from a raw 0–40 score (Listening/Reading) or is
  /// assessed directly against a rubric (Writing/Speaking).
  final bool rawBased;

  static IeltsModule fromId(String id) =>
      values.firstWhere((v) => v.id == id, orElse: () => IeltsModule.listening);
}

/// A single raw-score → band boundary row, e.g. raw 30–32 → band 7.0.
class BandRange {
  const BandRange({required this.rawMin, required this.rawMax, required this.band});

  final int rawMin;
  final int rawMax;
  final double band;

  bool contains(int raw) => raw >= rawMin && raw <= rawMax;

  factory BandRange.fromJson(Map<String, dynamic> json) => BandRange(
        rawMin: (json['rawMin'] as num).toInt(),
        rawMax: (json['rawMax'] as num).toInt(),
        band: (json['band'] as num).toDouble(),
      );
}

/// A versioned raw-score → band conversion table for one module/variant.
class ConversionTable {
  const ConversionTable({
    required this.module,
    required this.appliesTo,
    required this.rawMax,
    required this.version,
    required this.source,
    required this.isIndicative,
    required this.bands,
  });

  final String module;
  final List<String> appliesTo;
  final int rawMax;
  final String version;
  final String source;
  final bool isIndicative;

  /// Boundary rows, sorted highest band first (as stored in JSON).
  final List<BandRange> bands;

  factory ConversionTable.fromJson(Map<String, dynamic> json) => ConversionTable(
        module: json['module'] as String,
        appliesTo: (json['appliesTo'] as List).cast<String>(),
        rawMax: (json['rawMax'] as num).toInt(),
        version: json['version'] as String,
        source: json['source'] as String,
        isIndicative: json['isIndicative'] as bool? ?? true,
        bands: (json['bands'] as List)
            .map((e) => BandRange.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// The band for a given raw score. Returns 0.0 for anything outside a defined
  /// row (defensive — the tables cover 0..rawMax fully).
  double bandForRaw(int raw) {
    for (final r in bands) {
      if (r.contains(raw)) return r.band;
    }
    return 0.0;
  }

  /// One (raw, band) point per raw score 0..rawMax — used to draw the chart.
  List<ConversionPoint> expandedPoints() => [
        for (int raw = 0; raw <= rawMax; raw++)
          ConversionPoint(raw: raw, band: bandForRaw(raw)),
      ];
}

/// A single point on the conversion chart.
class ConversionPoint {
  const ConversionPoint({required this.raw, required this.band});
  final int raw;
  final double band;
}

/// Result of a raw-score lookup, including cross-module comparison values so the
/// user can see "the same raw score in the other applicable module(s)".
class RawScoreLookup {
  const RawScoreLookup({
    required this.raw,
    required this.rawMax,
    required this.primaryModule,
    required this.primaryVariant,
    required this.primaryBand,
    required this.comparisons,
  });

  final int raw;
  final int rawMax;
  final IeltsModule primaryModule;
  final IeltsVariant? primaryVariant;
  final double primaryBand;

  /// Other applicable module/variant interpretations of the same raw score.
  final List<CrossModuleBand> comparisons;
}

class CrossModuleBand {
  const CrossModuleBand({required this.label, required this.band});
  final String label;
  final double band;
}

/// Result of a full 4-module Overall Band computation.
class OverallBandResult {
  const OverallBandResult({
    required this.listening,
    required this.reading,
    required this.writing,
    required this.speaking,
    required this.rawAverage,
    required this.overallBand,
    required this.explanation,
  });

  final double listening;
  final double reading;
  final double writing;
  final double speaking;

  /// The exact (unrounded) mean of the four module bands.
  final double rawAverage;

  /// The official rounded Overall Band.
  final double overallBand;

  /// One-line, human-readable explanation of the rounding that just happened.
  final String explanation;
}
