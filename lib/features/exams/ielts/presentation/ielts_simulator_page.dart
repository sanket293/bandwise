import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../data/ielts_repository.dart';
import '../domain/ielts_models.dart';
import '../domain/ielts_scoring.dart';
import '../domain/rubric_models.dart';
import 'ielts_providers.dart';
import 'widgets/band_slider.dart';
import 'widgets/conversion_chart.dart';

/// The IELTS Score Simulator: Mode A (Overall Band) and Mode B (raw → band).
class IeltsSimulatorPage extends ConsumerWidget {
  const IeltsSimulatorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(ieltsDataProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('IELTS Simulator'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overall Band'),
              Tab(text: 'Raw → Band'),
            ],
          ),
        ),
        body: dataAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Failed to load data: $e')),
          data: (data) => TabBarView(
            children: [
              _ModeAView(data: data),
              _ModeBView(data: data),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shared exam-variant (Academic / General Training) segmented control.
class ExamVariantSelector extends ConsumerWidget {
  const ExamVariantSelector({super.key, this.subtitle});
  final String? subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variant = ref.watch(ieltsVariantProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<IeltsVariant>(
          segments: const [
            ButtonSegment(value: IeltsVariant.academic, label: Text('Academic')),
            ButtonSegment(
                value: IeltsVariant.generalTraining, label: Text('General Training')),
          ],
          selected: {variant},
          onSelectionChanged: (s) =>
              ref.read(ieltsVariantProvider.notifier).state = s.first,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!,
              style: TextStyle(
                  fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Mode A — Simulate Overall Band
// ---------------------------------------------------------------------------

class _ModeAView extends ConsumerWidget {
  const _ModeAView({required this.data});
  final IeltsData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bands = ref.watch(moduleBandsProvider);
    final result = ref.watch(overallResultProvider);
    final notifier = ref.read(moduleBandsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _OverallResultCard(result: result, overall: data.overall),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                BandSlider(
                  label: 'Listening',
                  icon: CupertinoIcons.ear,
                  value: bands.listening,
                  onChanged: (v) => notifier.set(IeltsModule.listening, v),
                ),
                BandSlider(
                  label: 'Reading',
                  icon: CupertinoIcons.book,
                  value: bands.reading,
                  onChanged: (v) => notifier.set(IeltsModule.reading, v),
                ),
                BandSlider(
                  label: 'Writing',
                  icon: CupertinoIcons.pencil,
                  value: bands.writing,
                  onChanged: (v) => notifier.set(IeltsModule.writing, v),
                ),
                BandSlider(
                  label: 'Speaking',
                  icon: CupertinoIcons.mic,
                  value: bands.speaking,
                  onChanged: (v) => notifier.set(IeltsModule.speaking, v),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Writing & Speaking are assessed against rubrics — enter the band directly. '
          'Listening & Reading bands can be found from a raw score in the Raw → Band tab.',
          style: TextStyle(
              fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _OverallResultCard extends StatelessWidget {
  const _OverallResultCard({required this.result, required this.overall});
  final OverallBandResult result;
  final OverallDescriptorSet overall;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final descriptor = overall.forBand(result.overallBand);
    final color = AppTheme.bandColor(result.overallBand, scheme);

    return Card(
      color: color.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OVERALL BAND',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: scheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  IeltsScoring.formatBand(result.overallBand),
                  style: TextStyle(
                      fontSize: 56, fontWeight: FontWeight.w800, color: color, height: 1),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      descriptor.name,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700, color: scheme.onSurface),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(descriptor.summary,
                style: TextStyle(fontSize: 13.5, color: scheme.onSurface, height: 1.35)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(CupertinoIcons.info_circle, size: 18, color: scheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(result.explanation,
                        style: const TextStyle(fontSize: 12.5, height: 1.3)),
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

// ---------------------------------------------------------------------------
// Mode B — Raw score → Band
// ---------------------------------------------------------------------------

class _ModeBView extends ConsumerWidget {
  const _ModeBView({required this.data});
  final IeltsData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final module = ref.watch(modeBModuleProvider);
    final variant = ref.watch(ieltsVariantProvider);
    final raw = ref.watch(modeBRawProvider);
    final view = ref.watch(modeBViewProvider);
    final table =
        module == IeltsModule.listening ? data.listening : data.readingFor(variant);
    final band = table.bandForRaw(raw);
    final moduleLabel =
        module == IeltsModule.listening ? 'Listening' : '${variant.label} Reading';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // 1) Which module — and, for Reading only, which test type.
        SegmentedButton<IeltsModule>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: IeltsModule.listening, label: Text('Listening')),
            ButtonSegment(value: IeltsModule.reading, label: Text('Reading')),
          ],
          selected: {module},
          onSelectionChanged: (s) =>
              ref.read(modeBModuleProvider.notifier).state = s.first,
        ),
        if (module == IeltsModule.reading) ...[
          const SizedBox(height: 10),
          SegmentedButton<IeltsVariant>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: IeltsVariant.academic, label: Text('Academic')),
              ButtonSegment(
                  value: IeltsVariant.generalTraining, label: Text('General')),
            ],
            selected: {variant},
            onSelectionChanged: (s) =>
                ref.read(ieltsVariantProvider.notifier).state = s.first,
          ),
        ],
        const SizedBox(height: 20),

        // 2) The one clear answer.
        _BandResultCard(band: band, moduleLabel: moduleLabel, raw: raw),
        const SizedBox(height: 20),

        // 3) Adjust the raw score.
        Row(
          children: [
            const Text('Your raw score', style: TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('$raw / 40',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: scheme.primary)),
          ],
        ),
        Slider(
          value: raw.toDouble(),
          min: 0,
          max: 40,
          divisions: 40,
          label: '$raw',
          onChanged: (v) => ref.read(modeBRawProvider.notifier).state = v.round(),
        ),
        const SizedBox(height: 8),

        // 4) See it as a graph or a table — user's choice.
        Center(
          child: SegmentedButton<ModeBView>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                  value: ModeBView.graph,
                  label: Text('Graph'),
                  icon: Icon(CupertinoIcons.graph_square)),
              ButtonSegment(
                  value: ModeBView.table,
                  label: Text('Table'),
                  icon: Icon(CupertinoIcons.list_bullet)),
            ],
            selected: {view},
            onSelectionChanged: (s) =>
                ref.read(modeBViewProvider.notifier).state = s.first,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: view == ModeBView.graph
                ? const EdgeInsets.fromLTRB(12, 16, 16, 12)
                : const EdgeInsets.symmetric(vertical: 4),
            child: view == ModeBView.graph
                ? ConversionChart(table: table, highlightRaw: raw)
                : _ConversionTable(table: table, highlightRaw: raw),
          ),
        ),
        const SizedBox(height: 10),
        if (table.isIndicative)
          _IndicativeNote(version: table.version, source: table.source),
      ],
    );
  }
}

/// The single, prominent "raw → band" answer.
class _BandResultCard extends StatelessWidget {
  const _BandResultCard(
      {required this.band, required this.moduleLabel, required this.raw});
  final double band;
  final String moduleLabel;
  final int raw;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = AppTheme.bandColor(band, scheme);
    return Card(
      color: color.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BAND',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: scheme.onSurfaceVariant)),
                Text(
                  IeltsScoring.formatBand(band),
                  style: TextStyle(
                      fontSize: 56, fontWeight: FontWeight.w800, color: color, height: 1),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(moduleLabel,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('$raw of 40 correct',
                      style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact raw-range → band table with the current score's row highlighted.
class _ConversionTable extends StatelessWidget {
  const _ConversionTable({required this.table, required this.highlightRaw});
  final ConversionTable table;
  final int highlightRaw;

  String _rawRange(BandRange r) =>
      r.rawMin == r.rawMax ? '${r.rawMin}' : '${r.rawMin}–${r.rawMax}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            children: [
              Expanded(
                  child: Text('Raw score',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurfaceVariant))),
              Text('Band',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
        for (final r in table.bands)
          Builder(builder: (_) {
            final isCurrent = r.contains(highlightRaw);
            final color = AppTheme.bandColor(r.band, scheme);
            return Container(
              color: isCurrent ? color.withValues(alpha: 0.15) : null,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Row(
                children: [
                  if (isCurrent)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(CupertinoIcons.arrow_right_circle_fill,
                          size: 16, color: color),
                    ),
                  Expanded(
                    child: Text('${_rawRange(r)} / 40',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500)),
                  ),
                  Text(IeltsScoring.formatBand(r.band),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isCurrent ? color : scheme.onSurface)),
                ],
              ),
            );
          }),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _IndicativeNote extends StatelessWidget {
  const _IndicativeNote({required this.version, required this.source});
  final String version;
  final String source;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(CupertinoIcons.exclamationmark_circle, size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Indicative table (v$version). IELTS does not publish a single fixed '
            'conversion table; boundaries vary slightly between test versions.',
            style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant, height: 1.3),
          ),
        ),
      ],
    );
  }
}
