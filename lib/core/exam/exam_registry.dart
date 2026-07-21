import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/exams/ielts/ielts_module.dart';
import 'exam_module.dart';

/// The set of exams the app ships with. To add a new exam (CELPIP, PTE, …),
/// implement [ExamModule] and add an instance here — nothing else in the core
/// needs to change.
final examRegistryProvider = Provider<List<ExamModule>>((ref) {
  return const [
    IeltsModule(),
    // Future: CelpipModule(), PteModule(), ...
  ];
});

/// The currently-selected exam (index into the registry). V1 ships one exam, but
/// the shell already supports switching so adding exams needs no shell rewrite.
final selectedExamIndexProvider = StateProvider<int>((ref) => 0);

final selectedExamProvider = Provider<ExamModule>((ref) {
  final exams = ref.watch(examRegistryProvider);
  final index = ref.watch(selectedExamIndexProvider).clamp(0, exams.length - 1);
  return exams[index];
});
