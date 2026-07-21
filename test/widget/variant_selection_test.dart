import 'dart:convert';
import 'dart:io';

import 'package:bandwise/features/exams/ielts/data/ielts_repository.dart';
import 'package:bandwise/features/exams/ielts/domain/ielts_models.dart';
import 'package:bandwise/features/exams/ielts/domain/rubric_models.dart';
import 'package:bandwise/features/exams/ielts/presentation/ielts_providers.dart';
import 'package:bandwise/features/exams/ielts/presentation/ielts_simulator_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _j(String p) =>
    jsonDecode(File(p).readAsStringSync()) as Map<String, dynamic>;

IeltsData _loadData() => IeltsData(
      listening: ConversionTable.fromJson(_j('assets/data/ielts/listening_conversion.json')),
      academicReading:
          ConversionTable.fromJson(_j('assets/data/ielts/academic_reading_conversion.json')),
      generalReading:
          ConversionTable.fromJson(_j('assets/data/ielts/general_reading_conversion.json')),
      overall: OverallDescriptorSet.fromJson(_j('assets/rubrics/ielts/overall_band_descriptors.json')),
      writing: WritingRubric.fromJson(_j('assets/rubrics/ielts/writing_rubric.json')),
      speaking: SpeakingRubric.fromJson(_j('assets/rubrics/ielts/speaking_rubric.json')),
    );

void main() {
  testWidgets('Mode B Reading + Academic/GT selector renders at phone width without overflow',
      (tester) async {
    // Narrow phone surface (e.g. iPhone 13 mini logical width).
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final data = _loadData();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ieltsDataProvider.overrideWith((ref) async => data),
        ],
        child: const MaterialApp(home: IeltsSimulatorPage()),
      ),
    );
    await tester.pumpAndSettle();

    // Go to the Raw -> Band tab.
    await tester.tap(find.text('Raw → Band'));
    await tester.pumpAndSettle();

    // Select Reading -> this reveals the Academic / General Training selector.
    await tester.tap(find.text('Reading'));
    await tester.pumpAndSettle();

    expect(find.text('General Training'), findsOneWidget);

    // Toggle to General Training.
    await tester.tap(find.text('General Training'));
    await tester.pumpAndSettle();

    // If the SegmentedButton overflowed, tester would already have thrown.
    expect(tester.takeException(), isNull);
  });
}
