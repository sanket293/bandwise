import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../domain/ielts_models.dart';
import '../domain/rubric_models.dart';

/// Loads the versioned IELTS data assets (conversion tables + rubrics) from the
/// bundle. Kept separate from the pure-Dart domain so the scoring logic stays
/// testable without Flutter.
class IeltsRepository {
  static const _dataDir = 'assets/data/ielts';
  static const _rubricDir = 'assets/rubrics/ielts';

  Future<Map<String, dynamic>> _json(String path) async {
    final raw = await rootBundle.loadString(path);
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<IeltsData> load() async {
    final results = await Future.wait([
      _json('$_dataDir/listening_conversion.json'),
      _json('$_dataDir/academic_reading_conversion.json'),
      _json('$_dataDir/general_reading_conversion.json'),
      _json('$_rubricDir/overall_band_descriptors.json'),
      _json('$_rubricDir/writing_rubric.json'),
      _json('$_rubricDir/speaking_rubric.json'),
    ]);

    return IeltsData(
      listening: ConversionTable.fromJson(results[0]),
      academicReading: ConversionTable.fromJson(results[1]),
      generalReading: ConversionTable.fromJson(results[2]),
      overall: OverallDescriptorSet.fromJson(results[3]),
      writing: WritingRubric.fromJson(results[4]),
      speaking: SpeakingRubric.fromJson(results[5]),
    );
  }
}

/// Everything the IELTS UI needs, loaded once.
class IeltsData {
  const IeltsData({
    required this.listening,
    required this.academicReading,
    required this.generalReading,
    required this.overall,
    required this.writing,
    required this.speaking,
  });

  final ConversionTable listening;
  final ConversionTable academicReading;
  final ConversionTable generalReading;
  final OverallDescriptorSet overall;
  final WritingRubric writing;
  final SpeakingRubric speaking;

  /// The reading table for a given variant.
  ConversionTable readingFor(IeltsVariant variant) =>
      variant == IeltsVariant.generalTraining ? generalReading : academicReading;

  /// The single data-version string shown in the UI footer.
  String get dataVersion => listening.version;
}
