/// Trust-critical IELTS scoring logic. Pure Dart, fully unit-tested.
///
/// ## Overall Band rounding rule (official)
/// The Overall Band is the mean of the four module bands, rounded to the
/// nearest whole or half band, with exact half-way points rounded **up**:
///
///   * average ending in **.25**  → round **up** to the next half band
///     (e.g. 6.25 → 6.5)
///   * average ending in **.75**  → round **up** to the next whole band
///     (e.g. 6.75 → 7.0)
///   * every other average        → round to the **nearest** half band
///     (e.g. 6.125 → 6.0, 6.375 → 6.5, 6.625 → 6.5, 6.875 → 7.0)
///
/// Because each module band is in 0.5 steps, the mean of four of them can only
/// end in .0, .125, .25, .375, .5, .625, .75 or .875 — the cases above cover
/// them all. Mathematically this is exactly "round the average to the nearest
/// 0.5, ties away from zero", which `(avg * 2).round() / 2` computes.
///
/// NOTE: The original product brief listed .375 and .875 as rounding *down*.
/// That contradicts the official IELTS convention (and would under-report a
/// band by half a point), so this implementation follows the official rule.
library;

import 'ielts_models.dart';

class IeltsScoring {
  const IeltsScoring._();

  /// Valid band values a user may pick for a module: 0.0, 0.5, … 9.0.
  static const List<double> bandSteps = [
    0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5,
    5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0,
  ];

  /// Rounds an Overall-Band average per the official convention above.
  static double roundOverall(double average) {
    // Round to nearest 0.5 with halves going up (Dart's round() is half-away
    // from zero, and averages are non-negative here).
    final rounded = (average * 2).round() / 2.0;
    // Clamp defensively to the valid 0..9 range.
    return rounded.clamp(0.0, 9.0).toDouble();
  }

  /// Computes the Overall Band from four module bands, with an explanation.
  static OverallBandResult overallBand({
    required double listening,
    required double reading,
    required double writing,
    required double speaking,
  }) {
    final sum = listening + reading + writing + speaking;
    final average = sum / 4.0;
    final overall = roundOverall(average);
    return OverallBandResult(
      listening: listening,
      reading: reading,
      writing: writing,
      speaking: speaking,
      rawAverage: average,
      overallBand: overall,
      explanation: _explain(average, overall),
    );
  }

  /// Builds a one-line, plain-language explanation of the rounding.
  static String _explain(double average, double overall) {
    final avgStr = _fmt(average);
    final overStr = _fmt(overall);
    // Fractional part of the average, in eighths, to identify the case.
    final frac = average - average.floorToDouble();
    // Use a small epsilon when comparing floating-point fractions.
    bool near(double a, double b) => (a - b).abs() < 1e-9;

    if (near(frac, 0.0) || near(frac, 0.5)) {
      return 'Average is $avgStr, which is already a valid band → Overall $overStr.';
    }
    if (near(frac, 0.25)) {
      return 'Average is $avgStr. A .25 average rounds up to the next half band → Overall $overStr.';
    }
    if (near(frac, 0.75)) {
      return 'Average is $avgStr. A .75 average rounds up to the next whole band → Overall $overStr.';
    }
    // .125 / .375 / .625 / .875 → nearest half band.
    final direction = overall > average ? 'up' : 'down';
    return 'Average is $avgStr, which rounds $direction to the nearest half band → Overall $overStr.';
  }

  /// Formats a band as "7", "6.5" etc. (drops a trailing ".0").
  static String _fmt(double band) {
    if (band == band.roundToDouble()) return band.toInt().toString();
    return band.toStringAsFixed(1);
  }

  /// Looks up a raw score in the given table and, for Reading, also reports how
  /// the same raw score reads in the other applicable module/variant tables.
  static RawScoreLookup rawScoreLookup({
    required int raw,
    required IeltsModule module,
    required IeltsVariant? variant,
    required ConversionTable listeningTable,
    required ConversionTable academicReadingTable,
    required ConversionTable generalReadingTable,
  }) {
    assert(module.rawBased, 'Raw-score lookup only applies to Listening/Reading');

    final ConversionTable primaryTable;
    if (module == IeltsModule.listening) {
      primaryTable = listeningTable;
    } else {
      primaryTable = variant == IeltsVariant.generalTraining
          ? generalReadingTable
          : academicReadingTable;
    }
    final rawMax = primaryTable.rawMax;
    final clampedRaw = raw.clamp(0, rawMax);
    final primaryBand = primaryTable.bandForRaw(clampedRaw);

    // Cross-module comparisons for the same raw score.
    final comparisons = <CrossModuleBand>[];
    if (module == IeltsModule.listening) {
      comparisons
        ..add(CrossModuleBand(
            label: 'Academic Reading',
            band: academicReadingTable.bandForRaw(clampedRaw)))
        ..add(CrossModuleBand(
            label: 'GT Reading',
            band: generalReadingTable.bandForRaw(clampedRaw)));
    } else {
      comparisons.add(CrossModuleBand(
          label: 'Listening', band: listeningTable.bandForRaw(clampedRaw)));
      if (variant == IeltsVariant.generalTraining) {
        comparisons.add(CrossModuleBand(
            label: 'Academic Reading',
            band: academicReadingTable.bandForRaw(clampedRaw)));
      } else {
        comparisons.add(CrossModuleBand(
            label: 'GT Reading',
            band: generalReadingTable.bandForRaw(clampedRaw)));
      }
    }

    return RawScoreLookup(
      raw: clampedRaw,
      rawMax: rawMax,
      primaryModule: module,
      primaryVariant: variant,
      primaryBand: primaryBand,
      comparisons: comparisons,
    );
  }

  /// Formats any band value for display ("7", "6.5", "0").
  static String formatBand(double band) => _fmt(band);
}
