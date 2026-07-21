import 'package:intl/intl.dart';

import '../../../core/exam/exam_module.dart';
import '../data/log_database.dart';

/// Formatting helpers that keep the log exam-agnostic by resolving opaque ids
/// against the active [ExamModule].
class LogFormat {
  const LogFormat(this.exam);
  final ExamModule exam;

  static final _date = DateFormat('d MMM yyyy');
  static final _dayMonth = DateFormat('d MMM');

  String moduleLabel(String id) => exam.moduleOptions
      .firstWhere((m) => m.id == id,
          orElse: () => ExamModuleOption(id: id, label: id))
      .label;

  String variantLabel(String? id) {
    if (id == null) return '';
    return exam.variants
        .firstWhere((v) => v.id == id,
            orElse: () => ExamVariantOption(id: id, label: id))
        .label;
  }

  static String date(DateTime d) => _date.format(d);
  static String shortDate(DateTime d) => _dayMonth.format(d);

  /// A compact score string, e.g. "Band 7.0", "32/40", "32/40 · Band 7.0".
  static String score(LogEntry e) {
    final parts = <String>[];
    if (e.rawScore != null) parts.add('${e.rawScore}/40');
    if (e.bandScore != null) parts.add('Band ${_band(e.bandScore!)}');
    return parts.isEmpty ? '—' : parts.join(' · ');
  }

  static String _band(double b) =>
      b == b.roundToDouble() ? b.toInt().toString() : b.toStringAsFixed(1);

  static String band(double b) => _band(b);
}
