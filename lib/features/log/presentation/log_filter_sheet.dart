import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/exam/exam_registry.dart';
import '../data/log_database.dart';
import '../data/log_providers.dart';
import 'log_format.dart';

/// Bottom sheet for filtering the log by module, exam type, date range and band
/// range. Text search lives in the list header.
class LogFilterSheet {
  static Future<void> open(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _FilterSheetBody(),
    );
  }
}

class _FilterSheetBody extends ConsumerWidget {
  const _FilterSheetBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(logFilterProvider);
    final exam = ref.watch(selectedExamProvider);
    final controller = ref.read(logFilterProvider.notifier);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Filter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    controller.state = LogFilter(examId: exam.id, searchText: filter.searchText),
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _SectionLabel('Module'),
          Wrap(
            spacing: 8,
            children: [
              for (final m in exam.moduleOptions)
                FilterChip(
                  label: Text(m.label),
                  selected: filter.moduleId == m.id,
                  onSelected: (sel) => controller.state = sel
                      ? filter.copyWith(moduleId: m.id)
                      : filter.copyWith(clearModule: true),
                ),
            ],
          ),
          if (exam.variants.isNotEmpty) ...[
            const SizedBox(height: 16),
            const _SectionLabel('Exam type'),
            Wrap(
              spacing: 8,
              children: [
                for (final v in exam.variants)
                  FilterChip(
                    label: Text(v.label),
                    selected: filter.variantId == v.id,
                    onSelected: (sel) => controller.state = sel
                        ? filter.copyWith(variantId: v.id)
                        : filter.copyWith(clearVariant: true),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const _SectionLabel('Date range'),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2015),
                      lastDate: now.add(const Duration(days: 1)),
                      initialDateRange: filter.from != null && filter.to != null
                          ? DateTimeRange(start: filter.from!, end: filter.to!)
                          : null,
                    );
                    if (range != null) {
                      controller.state = filter.copyWith(
                        from: DateTime(range.start.year, range.start.month, range.start.day),
                        to: DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59),
                      );
                    }
                  },
                  child: Text(
                    filter.from != null && filter.to != null
                        ? '${LogFormat.shortDate(filter.from!)} – ${LogFormat.shortDate(filter.to!)}'
                        : 'Any date',
                  ),
                ),
              ),
              if (filter.from != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => controller.state = filter.copyWith(clearDates: true),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionLabel('Band range: '
              '${filter.minBand == null ? '0' : LogFormat.band(filter.minBand!)}'
              ' – '
              '${filter.maxBand == null ? '9' : LogFormat.band(filter.maxBand!)}'),
          RangeSlider(
            values: RangeValues(filter.minBand ?? 0, filter.maxBand ?? 9),
            min: 0,
            max: 9,
            divisions: 18,
            labels: RangeLabels(
              LogFormat.band(filter.minBand ?? 0),
              LogFormat.band(filter.maxBand ?? 9),
            ),
            onChanged: (v) => controller.state = filter.copyWith(
              minBand: v.start == 0 ? null : v.start,
              maxBand: v.end == 9 ? null : v.end,
              clearBands: v.start == 0 && v.end == 9,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Show results'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}
