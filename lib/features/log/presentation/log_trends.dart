import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/exam/exam_registry.dart';
import '../data/log_database.dart';
import '../data/log_providers.dart';
import 'log_format.dart';

/// Band trend over time, per module (plus an overall trend), from logged entries
/// that recorded a band. Motivating framing: shows progress, no shaming.
class LogTrends extends ConsumerWidget {
  const LogTrends({super.key});

  // Distinct colours per module series.
  static const _seriesColors = {
    'listening': Color(0xFF2C7A7B),
    'reading': Color(0xFF6B46C1),
    'writing': Color(0xFFC05621),
    'speaking': Color(0xFF2B6CB0),
    'full': Color(0xFF718096),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(allEntriesProvider);
    final exam = ref.watch(selectedExamProvider);
    final fmt = LogFormat(exam);

    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (all) {
        final banded = all.where((e) => e.bandScore != null).toList()
          ..sort((a, b) => a.date.compareTo(b.date));
        if (banded.length < 2) {
          return _NotEnough(count: banded.length);
        }

        // Group by module.
        final byModule = <String, List<LogEntry>>{};
        for (final e in banded) {
          byModule.putIfAbsent(e.moduleId, () => []).add(e);
        }

        final minDate = banded.first.date;
        final maxDate = banded.last.date;
        final spanDays =
            maxDate.difference(minDate).inDays.clamp(1, 100000).toDouble();

        double x(DateTime d) => d.difference(minDate).inDays.toDouble();

        final bars = <LineChartBarData>[];
        byModule.forEach((moduleId, list) {
          final color = _seriesColors[moduleId] ?? Theme.of(context).colorScheme.primary;
          bars.add(LineChartBarData(
            spots: [for (final e in list) FlSpot(x(e.date), e.bandScore!)],
            isCurved: false,
            color: color,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (s, _, __, ___) =>
                  FlDotCirclePainter(radius: 3.5, color: color),
            ),
          ));
        });

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text('Band trend over time',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                    AspectRatio(
                      aspectRatio: 1.4,
                      child: LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: spanDays,
                          minY: 0,
                          maxY: 9,
                          gridData: FlGridData(show: true, horizontalInterval: 1),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                reservedSize: 28,
                                getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                                    style: const TextStyle(fontSize: 10)),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: (spanDays / 4).ceilToDouble().clamp(1, spanDays),
                                reservedSize: 28,
                                getTitlesWidget: (v, _) {
                                  final d = minDate.add(Duration(days: v.toInt()));
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(LogFormat.shortDate(d),
                                        style: const TextStyle(fontSize: 9)),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineBarsData: bars,
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (spots) => spots
                                  .map((s) => LineTooltipItem(
                                        'Band ${LogFormat.band(s.y)}',
                                        const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: byModule.keys.map((m) {
                final color =
                    _seriesColors[m] ?? Theme.of(context).colorScheme.primary;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(3))),
                    const SizedBox(width: 6),
                    Text(fmt.moduleLabel(m), style: const TextStyle(fontSize: 13)),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _PerModuleSummary(byModule: byModule, fmt: fmt),
          ],
        );
      },
    );
  }
}

class _PerModuleSummary extends StatelessWidget {
  const _PerModuleSummary({required this.byModule, required this.fmt});
  final Map<String, List<LogEntry>> byModule;
  final LogFormat fmt;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Latest by module',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 8),
        for (final entry in byModule.entries)
          Builder(builder: (_) {
            final list = entry.value;
            final first = list.first.bandScore!;
            final last = list.last.bandScore!;
            final delta = last - first;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
              child: ListTile(
                dense: true,
                title: Text(fmt.moduleLabel(entry.key),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${list.length} logged · latest Band ${LogFormat.band(last)}'),
                trailing: delta == 0
                    ? Text('±0', style: TextStyle(color: scheme.onSurfaceVariant))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            delta > 0
                                ? CupertinoIcons.arrow_up_right
                                : CupertinoIcons.arrow_down_right,
                            size: 16,
                            color: delta > 0
                                ? const Color(0xFF2E7D32)
                                : scheme.error,
                          ),
                          Text('${delta > 0 ? '+' : ''}${LogFormat.band(delta)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: delta > 0
                                      ? const Color(0xFF2E7D32)
                                      : scheme.error)),
                        ],
                      ),
              ),
            ),
            );
          }),
      ],
    );
  }
}

class _NotEnough extends StatelessWidget {
  const _NotEnough({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.chart_bar_alt_fill,
                size: 52, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('Not enough data yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              'Log at least two attempts with a band score to see your trend.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
