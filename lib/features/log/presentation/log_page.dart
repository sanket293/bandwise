import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/exam/exam_registry.dart';
import '../../../core/theme/app_theme.dart';
import '../data/log_database.dart';
import '../data/log_providers.dart';
import 'log_calendar.dart';
import 'log_entry_editor.dart';
import 'log_filter_sheet.dart';
import 'log_format.dart';
import 'log_trends.dart';

class LogPage extends ConsumerWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Practice Log'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Entries'),
              Tab(text: 'Calendar'),
              Tab(text: 'Trends'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => LogEntryEditor.open(context),
          icon: const Icon(Icons.add),
          label: const Text('Log'),
        ),
        body: const TabBarView(
          children: [
            _EntriesTab(),
            LogCalendar(),
            LogTrends(),
          ],
        ),
      ),
    );
  }
}

class _EntriesTab extends ConsumerWidget {
  const _EntriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(filteredEntriesProvider);
    final filter = ref.watch(logFilterProvider);
    final exam = ref.watch(selectedExamProvider);
    final fmt = LogFormat(exam);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(CupertinoIcons.search, size: 20),
                    hintText: 'Search source, notes, tags',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  ),
                  onChanged: (v) => ref.read(logFilterProvider.notifier).state =
                      filter.copyWith(searchText: v),
                ),
              ),
              const SizedBox(width: 8),
              Badge(
                isLabelVisible: !filter.isEmpty,
                child: IconButton.filledTonal(
                  icon: const Icon(CupertinoIcons.slider_horizontal_3),
                  onPressed: () => LogFilterSheet.open(context, ref),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: entriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (entries) {
              if (entries.isEmpty) return const _EmptyState();
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _EntryTile(entry: entries[i], fmt: fmt),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EntryTile extends ConsumerWidget {
  const _EntryTile({required this.entry, required this.fmt});
  final LogEntry entry;
  final LogFormat fmt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final band = entry.bandScore;
    final accent = band != null ? AppTheme.bandColor(band, scheme) : scheme.primary;
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(CupertinoIcons.delete, color: scheme.onErrorContainer),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete entry?'),
                content: Text('${fmt.moduleLabel(entry.moduleId)} · ${LogFormat.score(entry)}'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => ref.read(logDatabaseProvider).deleteEntry(entry.id),
      child: Card(
        child: ListTile(
          onTap: () => LogEntryEditor.open(context, existing: entry),
          leading: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              band != null ? LogFormat.band(band) : '${entry.rawScore ?? '—'}',
              style: TextStyle(fontWeight: FontWeight.w800, color: accent, fontSize: 16),
            ),
          ),
          title: Text(
            '${fmt.moduleLabel(entry.moduleId)}'
            '${entry.variantId != null && (entry.moduleId == 'reading') ? ' · ${fmt.variantLabel(entry.variantId)}' : ''}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${LogFormat.score(entry)} · ${LogFormat.date(entry.date)}'),
              if (entry.source.isNotEmpty)
                Text(entry.source,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
            ],
          ),
          isThreeLine: entry.source.isNotEmpty,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.doc_text_search, size: 56, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No entries yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              'Tap “Log” to record a practice or test attempt. Everything stays on this device.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
