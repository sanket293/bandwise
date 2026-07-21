import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

part 'log_database.g.dart';

/// A single practice/test attempt. Exam-agnostic: the core log never hard-codes
/// IELTS. `examId`/`variantId`/`moduleId` are opaque strings supplied by the
/// active [ExamModule]; `rawScore` and/or `bandScore` may be null depending on
/// the module (Writing/Speaking have no raw score; a raw-only entry has no band).
class LogEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get examId => text().withDefault(const Constant('ielts'))();
  TextColumn get variantId => text().nullable()();
  TextColumn get moduleId => text()(); // 'listening'|'reading'|'writing'|'speaking'|'full'
  TextColumn get source => text().withDefault(const Constant(''))();
  IntColumn get rawScore => integer().nullable()();
  RealColumn get bandScore => real().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get tags => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Filter criteria for the log search/filter screen.
class LogFilter {
  const LogFilter({
    this.examId,
    this.moduleId,
    this.variantId,
    this.searchText,
    this.from,
    this.to,
    this.minBand,
    this.maxBand,
  });

  final String? examId;
  final String? moduleId;
  final String? variantId;
  final String? searchText;
  final DateTime? from;
  final DateTime? to;
  final double? minBand;
  final double? maxBand;

  bool get isEmpty =>
      moduleId == null &&
      variantId == null &&
      (searchText == null || searchText!.isEmpty) &&
      from == null &&
      to == null &&
      minBand == null &&
      maxBand == null;

  LogFilter copyWith({
    String? moduleId,
    String? variantId,
    String? searchText,
    DateTime? from,
    DateTime? to,
    double? minBand,
    double? maxBand,
    bool clearModule = false,
    bool clearVariant = false,
    bool clearDates = false,
    bool clearBands = false,
  }) =>
      LogFilter(
        examId: examId,
        moduleId: clearModule ? null : (moduleId ?? this.moduleId),
        variantId: clearVariant ? null : (variantId ?? this.variantId),
        searchText: searchText ?? this.searchText,
        from: clearDates ? null : (from ?? this.from),
        to: clearDates ? null : (to ?? this.to),
        minBand: clearBands ? null : (minBand ?? this.minBand),
        maxBand: clearBands ? null : (maxBand ?? this.maxBand),
      );
}

@DriftDatabase(tables: [LogEntries])
class LogDatabase extends _$LogDatabase {
  LogDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 1;

  /// Live stream of entries matching [filter], newest first.
  Stream<List<LogEntry>> watchEntries(LogFilter filter) {
    final query = select(logEntries)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);

    if (filter.examId != null) {
      query.where((t) => t.examId.equals(filter.examId!));
    }
    if (filter.moduleId != null) {
      query.where((t) => t.moduleId.equals(filter.moduleId!));
    }
    if (filter.variantId != null) {
      query.where((t) => t.variantId.equals(filter.variantId!));
    }
    if (filter.searchText != null && filter.searchText!.isNotEmpty) {
      final like = '%${filter.searchText!}%';
      query.where((t) => t.source.like(like) | t.notes.like(like) | t.tags.like(like));
    }
    if (filter.from != null) {
      query.where((t) => t.date.isBiggerOrEqualValue(filter.from!));
    }
    if (filter.to != null) {
      query.where((t) => t.date.isSmallerOrEqualValue(filter.to!));
    }
    if (filter.minBand != null) {
      query.where((t) => t.bandScore.isBiggerOrEqualValue(filter.minBand!));
    }
    if (filter.maxBand != null) {
      query.where((t) => t.bandScore.isSmallerOrEqualValue(filter.maxBand!));
    }
    return query.watch();
  }

  Stream<List<LogEntry>> watchAll() =>
      (select(logEntries)..orderBy([(t) => OrderingTerm.asc(t.date)])).watch();

  Future<int> insertEntry(LogEntriesCompanion entry) => into(logEntries).insert(entry);

  Future<bool> updateEntry(LogEntry entry) => update(logEntries).replace(entry);

  Future<int> deleteEntry(int id) =>
      (delete(logEntries)..where((t) => t.id.equals(id))).go();
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'bandwise_log.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
