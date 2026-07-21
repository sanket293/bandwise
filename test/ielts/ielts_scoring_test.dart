import 'dart:convert';
import 'dart:io';

import 'package:bandwise/features/exams/ielts/domain/ielts_models.dart';
import 'package:bandwise/features/exams/ielts/domain/ielts_scoring.dart';
import 'package:flutter_test/flutter_test.dart';

ConversionTable _load(String path) {
  final json = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return ConversionTable.fromJson(json);
}

void main() {
  group('Overall Band rounding (official convention)', () {
    // roundOverall must round the average to nearest 0.5, ties up.
    test('.25 average rounds UP to next half band', () {
      expect(IeltsScoring.roundOverall(6.25), 6.5);
      expect(IeltsScoring.roundOverall(5.25), 5.5);
      expect(IeltsScoring.roundOverall(0.25), 0.5);
    });

    test('.75 average rounds UP to next whole band', () {
      expect(IeltsScoring.roundOverall(6.75), 7.0);
      expect(IeltsScoring.roundOverall(8.75), 9.0);
    });

    test('.125 rounds down to nearest half', () {
      expect(IeltsScoring.roundOverall(6.125), 6.0);
    });

    test('.375 rounds to nearest half (UP to .5) — brief said down; official is up', () {
      expect(IeltsScoring.roundOverall(6.375), 6.5);
    });

    test('.625 rounds to nearest half (down to .5)', () {
      expect(IeltsScoring.roundOverall(6.625), 6.5);
    });

    test('.875 rounds to nearest half (UP to next whole) — brief said down; official is up', () {
      expect(IeltsScoring.roundOverall(6.875), 7.0);
    });

    test('exact bands are unchanged', () {
      expect(IeltsScoring.roundOverall(7.0), 7.0);
      expect(IeltsScoring.roundOverall(6.5), 6.5);
      expect(IeltsScoring.roundOverall(0.0), 0.0);
      expect(IeltsScoring.roundOverall(9.0), 9.0);
    });
  });

  group('overallBand from four modules — canonical official examples', () {
    test('6.5 / 6.5 / 5.0 / 7.0 → avg 6.25 → 6.5', () {
      final r = IeltsScoring.overallBand(
          listening: 6.5, reading: 6.5, writing: 5.0, speaking: 7.0);
      expect(r.rawAverage, 6.25);
      expect(r.overallBand, 6.5);
      expect(r.explanation, contains('rounds up'));
    });

    test('4.0 / 3.5 / 4.0 / 4.0 → avg 3.875 → 4.0', () {
      final r = IeltsScoring.overallBand(
          listening: 4.0, reading: 3.5, writing: 4.0, speaking: 4.0);
      expect(r.rawAverage, 3.875);
      expect(r.overallBand, 4.0);
    });

    test('6.5 / 6.5 / 6.5 / 6.0 → avg 6.375 → 6.5', () {
      final r = IeltsScoring.overallBand(
          listening: 6.5, reading: 6.5, writing: 6.5, speaking: 6.0);
      expect(r.rawAverage, 6.375);
      expect(r.overallBand, 6.5);
    });

    test('all 7.0 → 7.0', () {
      final r = IeltsScoring.overallBand(
          listening: 7.0, reading: 7.0, writing: 7.0, speaking: 7.0);
      expect(r.rawAverage, 7.0);
      expect(r.overallBand, 7.0);
    });

    test('6.0 / 7.0 / 7.0 / 7.0 → avg 6.75 → 7.0 (round up to whole)', () {
      final r = IeltsScoring.overallBand(
          listening: 6.0, reading: 7.0, writing: 7.0, speaking: 7.0);
      expect(r.rawAverage, 6.75);
      expect(r.overallBand, 7.0);
      expect(r.explanation, contains('whole band'));
    });

    test('exhaustive: every 4-band combination stays within [0,9] and on a valid step', () {
      for (final l in IeltsScoring.bandSteps) {
        for (final r in IeltsScoring.bandSteps) {
          for (final w in IeltsScoring.bandSteps) {
            for (final s in IeltsScoring.bandSteps) {
              final res = IeltsScoring.overallBand(
                  listening: l, reading: r, writing: w, speaking: s);
              expect(res.overallBand, inInclusiveRange(0.0, 9.0));
              expect(IeltsScoring.bandSteps.contains(res.overallBand), isTrue,
                  reason: 'Overall ${res.overallBand} not a valid band step');
            }
          }
        }
      }
    });
  });

  group('Shipped conversion tables (real JSON assets)', () {
    late ConversionTable listening;
    late ConversionTable academicReading;
    late ConversionTable generalReading;

    setUp(() {
      listening = _load('assets/data/ielts/listening_conversion.json');
      academicReading = _load('assets/data/ielts/academic_reading_conversion.json');
      generalReading = _load('assets/data/ielts/general_reading_conversion.json');
    });

    test('every raw score 0..40 maps to exactly one band (no gaps/overlaps)', () {
      for (final table in [listening, academicReading, generalReading]) {
        for (int raw = 0; raw <= 40; raw++) {
          final matches =
              table.bands.where((b) => b.contains(raw)).toList();
          expect(matches.length, 1,
              reason:
                  '${table.appliesTo} raw $raw matched ${matches.length} rows');
        }
      }
    });

    test('bands are monotonic non-decreasing as raw score rises', () {
      for (final table in [listening, academicReading, generalReading]) {
        double prev = -1;
        for (int raw = 0; raw <= 40; raw++) {
          final band = table.bandForRaw(raw);
          expect(band, greaterThanOrEqualTo(prev),
              reason: '${table.appliesTo} band dropped at raw $raw');
          prev = band;
        }
      }
    });

    test('40/40 is band 9.0 for all tables', () {
      expect(listening.bandForRaw(40), 9.0);
      expect(academicReading.bandForRaw(40), 9.0);
      expect(generalReading.bandForRaw(40), 9.0);
    });

    test('GT Reading needs more correct answers than Academic for same band', () {
      // At band 6.0, GT requires a higher raw score than Academic.
      final academicMin =
          academicReading.bands.firstWhere((b) => b.band == 6.0).rawMin;
      final gtMin = generalReading.bands.firstWhere((b) => b.band == 6.0).rawMin;
      expect(gtMin, greaterThan(academicMin));
    });

    test('expandedPoints yields 41 points (0..40)', () {
      expect(listening.expandedPoints().length, 41);
    });
  });

  group('Raw-score lookup with cross-module comparison', () {
    late ConversionTable listening;
    late ConversionTable academicReading;
    late ConversionTable generalReading;

    setUp(() {
      listening = _load('assets/data/ielts/listening_conversion.json');
      academicReading = _load('assets/data/ielts/academic_reading_conversion.json');
      generalReading = _load('assets/data/ielts/general_reading_conversion.json');
    });

    test('Listening lookup compares to both reading tables', () {
      final r = IeltsScoring.rawScoreLookup(
        raw: 30,
        module: IeltsModule.listening,
        variant: null,
        listeningTable: listening,
        academicReadingTable: academicReading,
        generalReadingTable: generalReading,
      );
      expect(r.primaryBand, 7.0);
      expect(r.comparisons.map((c) => c.label),
          containsAll(['Academic Reading', 'GT Reading']));
    });

    test('Academic Reading lookup compares to Listening and GT Reading', () {
      final r = IeltsScoring.rawScoreLookup(
        raw: 30,
        module: IeltsModule.reading,
        variant: IeltsVariant.academic,
        listeningTable: listening,
        academicReadingTable: academicReading,
        generalReadingTable: generalReading,
      );
      expect(r.primaryBand, 7.0);
      expect(r.comparisons.map((c) => c.label),
          containsAll(['Listening', 'GT Reading']));
    });

    test('out-of-range raw is clamped', () {
      final r = IeltsScoring.rawScoreLookup(
        raw: 99,
        module: IeltsModule.listening,
        variant: null,
        listeningTable: listening,
        academicReadingTable: academicReading,
        generalReadingTable: generalReading,
      );
      expect(r.raw, 40);
      expect(r.primaryBand, 9.0);
    });
  });

  group('formatBand', () {
    test('drops trailing .0', () {
      expect(IeltsScoring.formatBand(7.0), '7');
      expect(IeltsScoring.formatBand(6.5), '6.5');
      expect(IeltsScoring.formatBand(0.0), '0');
    });
  });
}
