/// Models for the Rubric Reference pillar (Overall / Writing / Speaking).
library;

class OverallDescriptor {
  const OverallDescriptor({required this.band, required this.name, required this.summary});
  final double band;
  final String name;
  final String summary;

  factory OverallDescriptor.fromJson(Map<String, dynamic> j) => OverallDescriptor(
        band: (j['band'] as num).toDouble(),
        name: j['name'] as String,
        summary: j['summary'] as String,
      );
}

class OverallDescriptorSet {
  const OverallDescriptorSet({required this.version, required this.source, required this.bands});
  final String version;
  final String source;
  final List<OverallDescriptor> bands;

  factory OverallDescriptorSet.fromJson(Map<String, dynamic> j) => OverallDescriptorSet(
        version: j['version'] as String,
        source: j['source'] as String,
        bands: (j['bands'] as List)
            .map((e) => OverallDescriptor.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// The descriptor for a rounded band (falls back to the nearest whole band,
  /// since overall descriptors are defined per whole band).
  OverallDescriptor forBand(double band) {
    final whole = band.floorToDouble();
    return bands.firstWhere(
      (b) => b.band == whole,
      orElse: () => bands.reduce((a, b) =>
          (a.band - band).abs() <= (b.band - band).abs() ? a : b),
    );
  }
}

class BandText {
  const BandText({required this.band, required this.text});
  final double band;
  final String text;

  factory BandText.fromJson(Map<String, dynamic> j) =>
      BandText(band: (j['band'] as num).toDouble(), text: j['text'] as String);
}

class RubricCriterion {
  const RubricCriterion({required this.name, required this.abbr, required this.bands});
  final String name;
  final String abbr;
  final List<BandText> bands;

  factory RubricCriterion.fromJson(Map<String, dynamic> j) => RubricCriterion(
        name: j['name'] as String,
        abbr: j['abbr'] as String,
        bands: (j['bands'] as List)
            .map((e) => BandText.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class RubricTask {
  const RubricTask({required this.task, required this.note, required this.criteria});
  final String task;
  final String note;
  final List<RubricCriterion> criteria;

  factory RubricTask.fromJson(Map<String, dynamic> j) => RubricTask(
        task: j['task'] as String,
        note: j['note'] as String? ?? '',
        criteria: (j['criteria'] as List)
            .map((e) => RubricCriterion.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Writing rubric: multiple tasks, each with criteria.
class WritingRubric {
  const WritingRubric({required this.version, required this.source, required this.tasks});
  final String version;
  final String source;
  final List<RubricTask> tasks;

  factory WritingRubric.fromJson(Map<String, dynamic> j) => WritingRubric(
        version: j['version'] as String,
        source: j['source'] as String,
        tasks: (j['tasks'] as List)
            .map((e) => RubricTask.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Speaking rubric: a single set of criteria.
class SpeakingRubric {
  const SpeakingRubric({
    required this.version,
    required this.source,
    required this.note,
    required this.criteria,
  });
  final String version;
  final String source;
  final String note;
  final List<RubricCriterion> criteria;

  factory SpeakingRubric.fromJson(Map<String, dynamic> j) => SpeakingRubric(
        version: j['version'] as String,
        source: j['source'] as String,
        note: j['note'] as String? ?? '',
        criteria: (j['criteria'] as List)
            .map((e) => RubricCriterion.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
