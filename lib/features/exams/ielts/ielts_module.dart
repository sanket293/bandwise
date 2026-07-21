import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/exam/exam_module.dart';
import 'domain/ielts_models.dart' as models;
import 'presentation/ielts_providers.dart';
import 'presentation/ielts_rubrics_page.dart';
import 'presentation/ielts_simulator_page.dart';

/// IELTS implementation of the [ExamModule] plugin contract. The only place
/// IELTS-specific wiring meets the exam-agnostic core.
class IeltsModule implements ExamModule {
  const IeltsModule();

  @override
  String get id => 'ielts';

  @override
  String get displayName => 'IELTS';

  @override
  String get tagline => 'International English Language Testing System';

  @override
  List<ExamVariantOption> get variants => const [
        ExamVariantOption(id: 'academic', label: 'Academic'),
        ExamVariantOption(id: 'general_training', label: 'General Training'),
      ];

  @override
  List<ExamModuleOption> get moduleOptions => const [
        ExamModuleOption(id: 'listening', label: 'Listening', isRawBased: true),
        ExamModuleOption(id: 'reading', label: 'Reading', isRawBased: true),
        ExamModuleOption(id: 'writing', label: 'Writing'),
        ExamModuleOption(id: 'speaking', label: 'Speaking'),
        ExamModuleOption(id: 'full', label: 'Full Test'),
      ];

  @override
  ScoreScale get scoreScale => const ScoreScale(
        min: 0,
        max: 9,
        step: 0.5,
        rawMax: 40,
        label: 'Band',
      );

  @override
  Widget buildSimulatorPage(BuildContext context) => const IeltsSimulatorPage();

  @override
  Widget buildRubricsPage(BuildContext context) => const IeltsRubricsPage();

  @override
  Future<void> warmUp(WidgetRef ref) => ref.read(ieltsDataProvider.future);

  @override
  double? autoBandForRaw(
    WidgetRef ref, {
    required String moduleId,
    String? variantId,
    required int raw,
  }) {
    // Only Listening and Reading are raw-based; Writing/Speaking/Full are not.
    final isListening = moduleId == 'listening';
    final isReading = moduleId == 'reading';
    if (!isListening && !isReading) return null;
    final data = ref.read(ieltsDataProvider).valueOrNull;
    if (data == null) return null;
    final table = isListening
        ? data.listening
        : data.readingFor(models.IeltsVariant.fromId(variantId ?? 'academic'));
    return table.bandForRaw(raw.clamp(0, table.rawMax));
  }
}
