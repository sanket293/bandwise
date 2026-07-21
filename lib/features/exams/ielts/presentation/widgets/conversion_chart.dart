import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../domain/ielts_models.dart';
import '../../domain/ielts_scoring.dart';

/// A raw-score → band line chart with the user's current raw score highlighted
/// by a marker + vertical guide line. Visual-first per the brief (not a table).
class ConversionChart extends StatelessWidget {
  const ConversionChart({
    super.key,
    required this.table,
    required this.highlightRaw,
  });

  final ConversionTable table;
  final int highlightRaw;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final points = table.expandedPoints();
    final spots = points
        .map((p) => FlSpot(p.raw.toDouble(), p.band))
        .toList(growable: false);
    final highlightBand = table.bandForRaw(highlightRaw);
    final highlightColor = AppTheme.bandColor(highlightBand, scheme);

    return AspectRatio(
      aspectRatio: 1.5,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: table.rawMax.toDouble(),
          minY: 0,
          maxY: 9,
          gridData: FlGridData(
            show: true,
            horizontalInterval: 1,
            verticalInterval: 10,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: scheme.outlineVariant.withValues(alpha: 0.4), strokeWidth: 1),
            getDrawingVerticalLine: (_) =>
                FlLine(color: scheme.outlineVariant.withValues(alpha: 0.4), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              axisNameWidget: const Text('Band', style: TextStyle(fontSize: 11)),
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 28,
                getTitlesWidget: (v, meta) =>
                    Text(v.toInt().toString(), style: const TextStyle(fontSize: 10)),
              ),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: const Text('Raw score (/40)', style: TextStyle(fontSize: 11)),
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                reservedSize: 24,
                getTitlesWidget: (v, meta) =>
                    Text(v.toInt().toString(), style: const TextStyle(fontSize: 10)),
              ),
            ),
          ),
          extraLinesData: ExtraLinesData(
            verticalLines: [
              VerticalLine(
                x: highlightRaw.toDouble(),
                color: highlightColor.withValues(alpha: 0.7),
                strokeWidth: 2,
                dashArray: [5, 4],
              ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isStepLineChart: true,
              isCurved: false,
              color: scheme.primary,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, _) => spot.x == highlightRaw.toDouble(),
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 6,
                  color: highlightColor,
                  strokeColor: scheme.surface,
                  strokeWidth: 2,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: scheme.primary.withValues(alpha: 0.08),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        '${s.x.toInt()}/40 → ${IeltsScoring.formatBand(s.y)}',
                        TextStyle(color: scheme.onInverseSurface, fontWeight: FontWeight.w600),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
