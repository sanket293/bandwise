import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'log_database.dart';

/// Single app-wide database instance.
final logDatabaseProvider = Provider<LogDatabase>((ref) {
  final db = LogDatabase();
  ref.onDispose(db.close);
  return db;
});

/// The active filter for the log list/search screen.
final logFilterProvider = StateProvider<LogFilter>(
  (ref) => const LogFilter(examId: 'ielts'),
);

/// Live, filtered entries for the list view.
final filteredEntriesProvider = StreamProvider<List<LogEntry>>((ref) {
  final db = ref.watch(logDatabaseProvider);
  final filter = ref.watch(logFilterProvider);
  return db.watchEntries(filter);
});

/// All entries (unfiltered), used by the calendar heatmap and trend graphs.
final allEntriesProvider = StreamProvider<List<LogEntry>>((ref) {
  final db = ref.watch(logDatabaseProvider);
  return db.watchAll();
});
