import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../domain/rubric_models.dart';
import 'ielts_providers.dart';

/// Rubric Reference pillar: Overall / Writing / Speaking descriptors as clean,
/// collapsible cards (headline per band, expand for full official text).
class IeltsRubricsPage extends ConsumerWidget {
  const IeltsRubricsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(ieltsDataProvider);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Band Descriptors'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Overall'),
              Tab(text: 'Writing'),
              Tab(text: 'Speaking'),
            ],
          ),
        ),
        body: dataAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Failed to load rubrics: $e')),
          data: (data) => TabBarView(
            children: [
              _OverallTab(set: data.overall),
              _WritingTab(rubric: data.writing),
              _SpeakingTab(rubric: data.speaking),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverallTab extends StatelessWidget {
  const _OverallTab({required this.set});
  final OverallDescriptorSet set;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final d in set.bands)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BandBadge(band: d.band),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(d.summary,
                              style: TextStyle(
                                  fontSize: 13,
                                  height: 1.35,
                                  color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const _SourceFooter(),
      ],
    );
  }
}

class _WritingTab extends StatelessWidget {
  const _WritingTab({required this.rubric});
  final WritingRubric rubric;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final task in rubric.tasks) ...[
          _TaskHeader(title: task.task, note: task.note),
          for (final c in task.criteria) _CriterionCard(criterion: c),
          const SizedBox(height: 8),
        ],
        _SourceFooter(text: rubric.source),
      ],
    );
  }
}

class _SpeakingTab extends StatelessWidget {
  const _SpeakingTab({required this.rubric});
  final SpeakingRubric rubric;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (rubric.note.isNotEmpty) _TaskHeader(title: 'Speaking', note: rubric.note),
        for (final c in rubric.criteria) _CriterionCard(criterion: c),
        const SizedBox(height: 8),
        _SourceFooter(text: rubric.source),
      ],
    );
  }
}

class _TaskHeader extends StatelessWidget {
  const _TaskHeader({required this.title, required this.note});
  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: scheme.primary)),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(note,
                style: TextStyle(
                    fontSize: 12.5, height: 1.35, color: scheme.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}

/// A criterion rendered as an accordion: the four/nine bands collapse into a
/// single expandable card headed by the criterion name + abbreviation.
class _CriterionCard extends StatelessWidget {
  const _CriterionCard({required this.criterion});
  final RubricCriterion criterion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            shape: const Border(),
            collapsedShape: const Border(),
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: scheme.secondaryContainer,
              child: Text(criterion.abbr,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSecondaryContainer)),
            ),
            title: Text(criterion.name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            subtitle: Text('${criterion.bands.length} bands · tap to expand',
                style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
            children: [
              for (final b in criterion.bands)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BandBadge(band: b.band, small: true),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(b.text,
                            style: const TextStyle(fontSize: 13, height: 1.4)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BandBadge extends StatelessWidget {
  const _BandBadge({required this.band, this.small = false});
  final double band;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = AppTheme.bandColor(band, scheme);
    final size = small ? 34.0 : 44.0;
    final label = band == band.roundToDouble() ? band.toInt().toString() : band.toStringAsFixed(1);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: small ? 14 : 18,
              color: color)),
    );
  }
}

class _SourceFooter extends StatelessWidget {
  const _SourceFooter({this.text});
  final String? text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(CupertinoIcons.doc_text, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text ??
                  'Band names are the official published designations; summaries are '
                      'paraphrased. See official IELTS band descriptor documents for authoritative wording.',
              style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
