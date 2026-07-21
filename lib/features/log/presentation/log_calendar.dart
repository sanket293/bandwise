import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
  late DateTime _month; // first day of the displayed month

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  static DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  void _shiftMonth(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

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
            _MonthCalendar(
              month: _month,
              byDay: byDay,
              selected: _selected,
              onSelect: (d) => setState(() => _selected = d),
              onPrev: () => _shiftMonth(-1),
              onNext: () => _shiftMonth(1),
            ),
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

/// A traditional month-grid calendar. Days with logged practice are tinted and
/// dotted; the selected day is filled and today is outlined. Tapping a day
/// selects it (shared with the day-detail panel below).
class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.month,
    required this.byDay,
    required this.selected,
    required this.onSelect,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month; // first day of the displayed month
  final Map<DateTime, List<LogEntry>> byDay;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  static const _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = DateTime(month.year, month.month, 1).weekday - 1; // Mon=0
    final canGoNext = DateTime(month.year, month.month)
        .isBefore(DateTime(today.year, today.month));

    final cells = <Widget>[
      for (int i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
      for (int day = 1; day <= daysInMonth; day++)
        _DayCell(
          day: day,
          dayKey: DateTime(month.year, month.month, day),
          count: byDay[DateTime(month.year, month.month, day)]?.length ?? 0,
          isToday: DateTime(month.year, month.month, day) == todayKey,
          isSelected: selected == DateTime(month.year, month.month, day),
          onTap: onSelect,
          scheme: scheme,
        ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(CupertinoIcons.chevron_left, size: 20),
                  onPressed: onPrev,
                ),
                Expanded(
                  child: Text(
                    DateFormat('MMMM yyyy').format(month),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.chevron_right, size: 20),
                  onPressed: canGoNext ? onNext : null,
                ),
              ],
            ),
            Row(
              children: [
                for (final w in _weekdayLabels)
                  Expanded(
                    child: Center(
                      child: Text(w,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurfaceVariant)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: cells,
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.dayKey,
    required this.count,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
    required this.scheme,
  });

  final int day;
  final DateTime dayKey;
  final int count;
  final bool isToday;
  final bool isSelected;
  final ValueChanged<DateTime> onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final hasEntries = count > 0;
    final Color bg;
    final Color fg;
    if (isSelected) {
      bg = scheme.primary;
      fg = scheme.onPrimary;
    } else if (hasEntries) {
      bg = scheme.primaryContainer;
      fg = scheme.onPrimaryContainer;
    } else {
      bg = Colors.transparent;
      fg = scheme.onSurface;
    }
    return Padding(
      padding: const EdgeInsets.all(3),
      child: GestureDetector(
        onTap: () => onTap(dayKey),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: isToday && !isSelected
                ? Border.all(color: scheme.primary, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$day',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: hasEntries ? FontWeight.w800 : FontWeight.w500,
                      color: fg)),
              if (hasEntries)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isSelected ? scheme.onPrimary : scheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
