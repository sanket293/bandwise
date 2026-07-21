import 'package:flutter/widgets.dart';

/// Contract every exam (IELTS, and later CELPIP/PTE/TOEFL) must implement.
///
/// The core app — navigation shell, Practice Log, calendar, graphs, settings —
/// is exam-agnostic and talks only to this interface. Adding a new exam means
/// implementing [ExamModule] and registering it in the [ExamRegistry]; no core
/// code changes. See README "Adding a new exam module".
abstract class ExamModule {
  /// Stable machine id, e.g. `ielts`. Stored on log entries.
  String get id;

  /// Human name shown in tabs, e.g. `IELTS`.
  String get displayName;

  /// Short tagline for cards/headers.
  String get tagline;

  /// Variants a user chooses between (e.g. Academic / General Training).
  /// Empty if the exam has none.
  List<ExamVariantOption> get variants;

  /// Modules/skills this exam scores (e.g. Listening, Reading, …). Used by the
  /// exam-agnostic log to offer a module dropdown.
  List<ExamModuleOption> get moduleOptions;

  /// Describes the score scale so the log can validate/format entries without
  /// knowing exam specifics (IELTS 0–9 step .5; CELPIP 1–12 step 1; …).
  ScoreScale get scoreScale;

  /// The exam's simulator screen (Score Simulator pillar).
  Widget buildSimulatorPage(BuildContext context);

  /// The exam's rubric reference screen (Rubric Reference pillar).
  Widget buildRubricsPage(BuildContext context);
}

/// A selectable exam variant (e.g. Academic).
class ExamVariantOption {
  const ExamVariantOption({required this.id, required this.label});
  final String id;
  final String label;
}

/// A selectable module/skill (e.g. Listening). [isRawBased] indicates whether a
/// numeric raw score applies (vs. a directly-assessed band).
class ExamModuleOption {
  const ExamModuleOption({
    required this.id,
    required this.label,
    this.isRawBased = false,
  });
  final String id;
  final String label;
  final bool isRawBased;
}

/// A generic band/score scale used by the exam-agnostic log & graphs.
class ScoreScale {
  const ScoreScale({
    required this.min,
    required this.max,
    required this.step,
    required this.rawMax,
    required this.label,
  });

  /// Lowest valid band (IELTS 0, CELPIP 1).
  final double min;

  /// Highest valid band (IELTS 9, CELPIP 12).
  final double max;

  /// Increment between valid bands (IELTS 0.5, CELPIP 1).
  final double step;

  /// Max raw score for raw-based modules (IELTS 40). Null if none.
  final int? rawMax;

  /// Axis label, e.g. "Band".
  final String label;

  /// All valid band values on the scale.
  List<double> get steps {
    final out = <double>[];
    for (double v = min; v <= max + 1e-9; v += step) {
      out.add(double.parse(v.toStringAsFixed(2)));
    }
    return out;
  }
}
