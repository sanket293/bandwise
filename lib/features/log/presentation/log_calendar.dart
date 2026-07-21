import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/exam/exam_registry.dart';
import '../data/log_database.dart';
import '../data/log_providers.dart';
import 'log_entry_editor.dart';
import 'log_format.dart';

/// Heatmap calendar (GitHub-style) of days with logged practice, plus a gentle
/// streak indicator. Tapping a day shows that day's entries. Deliberately
/// motivating, never shaming — it only ever counts activity, not scores.
class LogCalendar extends ConsumerStatefulWidget {
  const LogCalendar({super.key});

  @override
  ConsumerState<LogCalendar> createState() => _LogCalendarState();
}

class _LogCalendarState extends ConsumerState<LogCalendar> {
  DateTime? _selected;

  static DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(allEntriesProvider);
    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (entries) {
        final byDay = <DateTime, List<LogEntry>>{};
        for (final e in entries) {
          byDay.putIfAbsent(_dayKey(e.date), () => []).add(e);
        }
        final streak = _currentStreak(byDay.keys.toSet());
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            _StreakBanner(streak: streak, totalDays: byDay.length),
            const SizedBox(height: 16),
            _Heatmap(
              byDay: byDay,
              selected: _selected,
              onSelect: (d) => setState(() => _selected = d),
            ),
            const SizedBox(height: 20),
            if (_selected != null) _DayDetail(day: _selected!, entries: byDay[_selected!] ?? []),
          ],
        );
      },
    );
  }

  /// Consecutive days (ending today or yesterday) with at least one entry.
  int _currentStreak(Set<DateTime> days) {
    var cursor = _dayKey(DateTime.now());
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!days.contains(cursor)) return 0;
    }
    var count = 0;
    while (days.contains(cursor)) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }
}

class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.streak, required this.totalDays});
  final int streak;
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(CupertinoIcons.flame_fill,
                color: streak > 0 ? const Color(0xFFE8590C) : scheme.onPrimaryContainer,
                size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    streak > 0
                        ? '$streak-day streak'
                        : 'Start a streak today',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: scheme.onPrimaryContainer),
                  ),
                  Text(
                    '$totalDays day${totalDays == 1 ? '' : 's'} practised in total',
                    style: TextStyle(fontSize: 13, color: scheme.onPrimaryContainer),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.byDay, required this.selected, required this.onSelect});
  final Map<DateTime, List<LogEntry>> byDay;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;

  static const _weeks = 26; // ~6 months
  static const _cell = 15.0;
  static const _gap = 3.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    // Start on the Monday of the week _weeks ago.
    final startOfThisWeek = today.subtract(Duration(days: (today.weekday - 1)));
    final start = startOfThisWeek.subtract(const Duration(days: 7 * (_weeks - 1)));

    Color colorFor(int count) {
      if (count == 0) return scheme.surfaceContainerHighest;
      if (count == 1) return scheme.primary.withValues(alpha: 0.35);
      if (count == 2) return scheme.primary.withValues(alpha: 0.6);
      return scheme.primary;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Practice activity',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int w = 0; w < _weeks; w++)
                    Padding(
                      padding: const EdgeInsets.only(right: _gap),
                      child: Column(
                        children: [
                          for (int d = 0; d < 7; d++)
                            Builder(builder: (_) {
                              final day = start.add(Duration(days: w * 7 + d));
                              if (day.isAfter(today)) {
                                return const SizedBox(width: _cell, height: _cell + _gap);
                              }
                              final count = byDay[day]?.length ?? 0;
                              final isSel = selected == day;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: _gap),
                                child: GestureDetector(
                                  onTap: () => onSelect(day),
                                  child: Container(
                                    width: _cell,
                                    height: _cell,
                                    decoration: BoxDecoration(
                                      color: colorFor(count),
                                      borderRadius: BorderRadius.circular(3),
                                      border: isSel
                                          ? Border.all(color: scheme.onSurface, width: 1.5)
                                          : null,
                                    ),
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Less', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                const SizedBox(width: 6),
                for (final c in [0, 1, 2, 3])
                  Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colorFor(c),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                const SizedBox(width: 3),
                Text('More', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayDetail extends ConsumerWidget {
  const _DayDetail({required this.day, required this.entries});
  final DateTime day;
  final List<LogEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = LogFormat(ref.watch(selectedExamProvider));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LogFormat.date(day),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          Text('No practice logged on this day.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
        else
          for (final e in entries)
            Card(
              child: ListTile(
                onTap: () => LogEntryEditor.open(context, existing: e),
                title: Text(fmt.moduleLabel(e.moduleId),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(LogFormat.score(e) +
                    (e.source.isNotEmpty ? ' · ${e.source}' : '')),
              ),
            ),
      ],
    );
  }
}
