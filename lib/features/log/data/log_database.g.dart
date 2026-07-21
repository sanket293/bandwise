// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_database.dart';

// ignore_for_file: type=lint
class $LogEntriesTable extends LogEntries
    with TableInfo<$LogEntriesTable, LogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _examIdMeta = const VerificationMeta('examId');
  @override
  late final GeneratedColumn<String> examId = GeneratedColumn<String>(
    'exam_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ielts'),
  );
  static const VerificationMeta _variantIdMeta = const VerificationMeta(
    'variantId',
  );
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
    'variant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moduleIdMeta = const VerificationMeta(
    'moduleId',
  );
  @override
  late final GeneratedColumn<String> moduleId = GeneratedColumn<String>(
    'module_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _rawScoreMeta = const VerificationMeta(
    'rawScore',
  );
  @override
  late final GeneratedColumn<int> rawScore = GeneratedColumn<int>(
    'raw_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bandScoreMeta = const VerificationMeta(
    'bandScore',
  );
  @override
  late final GeneratedColumn<double> bandScore = GeneratedColumn<double>(
    'band_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    examId,
    variantId,
    moduleId,
    source,
    rawScore,
    bandScore,
    date,
    notes,
    tags,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'log_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LogEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exam_id')) {
      context.handle(
        _examIdMeta,
        examId.isAcceptableOrUnknown(data['exam_id']!, _examIdMeta),
      );
    }
    if (data.containsKey('variant_id')) {
      context.handle(
        _variantIdMeta,
        variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta),
      );
    }
    if (data.containsKey('module_id')) {
      context.handle(
        _moduleIdMeta,
        moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('raw_score')) {
      context.handle(
        _rawScoreMeta,
        rawScore.isAcceptableOrUnknown(data['raw_score']!, _rawScoreMeta),
      );
    }
    if (data.containsKey('band_score')) {
      context.handle(
        _bandScoreMeta,
        bandScore.isAcceptableOrUnknown(data['band_score']!, _bandScoreMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LogEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      examId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exam_id'],
      )!,
      variantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_id'],
      ),
      moduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      rawScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}raw_score'],
      ),
      bandScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}band_score'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LogEntriesTable createAlias(String alias) {
    return $LogEntriesTable(attachedDatabase, alias);
  }
}

class LogEntry extends DataClass implements Insertable<LogEntry> {
  final int id;
  final String examId;
  final String? variantId;
  final String moduleId;
  final String source;
  final int? rawScore;
  final double? bandScore;
  final DateTime date;
  final String notes;
  final String tags;
  final DateTime createdAt;
  const LogEntry({
    required this.id,
    required this.examId,
    this.variantId,
    required this.moduleId,
    required this.source,
    this.rawScore,
    this.bandScore,
    required this.date,
    required this.notes,
    required this.tags,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exam_id'] = Variable<String>(examId);
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    map['module_id'] = Variable<String>(moduleId);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || rawScore != null) {
      map['raw_score'] = Variable<int>(rawScore);
    }
    if (!nullToAbsent || bandScore != null) {
      map['band_score'] = Variable<double>(bandScore);
    }
    map['date'] = Variable<DateTime>(date);
    map['notes'] = Variable<String>(notes);
    map['tags'] = Variable<String>(tags);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LogEntriesCompanion toCompanion(bool nullToAbsent) {
    return LogEntriesCompanion(
      id: Value(id),
      examId: Value(examId),
      variantId: variantId == null && nullToAbsent
          ? const Value.absent()
          : Value(variantId),
      moduleId: Value(moduleId),
      source: Value(source),
      rawScore: rawScore == null && nullToAbsent
          ? const Value.absent()
          : Value(rawScore),
      bandScore: bandScore == null && nullToAbsent
          ? const Value.absent()
          : Value(bandScore),
      date: Value(date),
      notes: Value(notes),
      tags: Value(tags),
      createdAt: Value(createdAt),
    );
  }

  factory LogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LogEntry(
      id: serializer.fromJson<int>(json['id']),
      examId: serializer.fromJson<String>(json['examId']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      moduleId: serializer.fromJson<String>(json['moduleId']),
      source: serializer.fromJson<String>(json['source']),
      rawScore: serializer.fromJson<int?>(json['rawScore']),
      bandScore: serializer.fromJson<double?>(json['bandScore']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String>(json['notes']),
      tags: serializer.fromJson<String>(json['tags']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'examId': serializer.toJson<String>(examId),
      'variantId': serializer.toJson<String?>(variantId),
      'moduleId': serializer.toJson<String>(moduleId),
      'source': serializer.toJson<String>(source),
      'rawScore': serializer.toJson<int?>(rawScore),
      'bandScore': serializer.toJson<double?>(bandScore),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String>(notes),
      'tags': serializer.toJson<String>(tags),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LogEntry copyWith({
    int? id,
    String? examId,
    Value<String?> variantId = const Value.absent(),
    String? moduleId,
    String? source,
    Value<int?> rawScore = const Value.absent(),
    Value<double?> bandScore = const Value.absent(),
    DateTime? date,
    String? notes,
    String? tags,
    DateTime? createdAt,
  }) => LogEntry(
    id: id ?? this.id,
    examId: examId ?? this.examId,
    variantId: variantId.present ? variantId.value : this.variantId,
    moduleId: moduleId ?? this.moduleId,
    source: source ?? this.source,
    rawScore: rawScore.present ? rawScore.value : this.rawScore,
    bandScore: bandScore.present ? bandScore.value : this.bandScore,
    date: date ?? this.date,
    notes: notes ?? this.notes,
    tags: tags ?? this.tags,
    createdAt: createdAt ?? this.createdAt,
  );
  LogEntry copyWithCompanion(LogEntriesCompanion data) {
    return LogEntry(
      id: data.id.present ? data.id.value : this.id,
      examId: data.examId.present ? data.examId.value : this.examId,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      source: data.source.present ? data.source.value : this.source,
      rawScore: data.rawScore.present ? data.rawScore.value : this.rawScore,
      bandScore: data.bandScore.present ? data.bandScore.value : this.bandScore,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
      tags: data.tags.present ? data.tags.value : this.tags,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LogEntry(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('variantId: $variantId, ')
          ..write('moduleId: $moduleId, ')
          ..write('source: $source, ')
          ..write('rawScore: $rawScore, ')
          ..write('bandScore: $bandScore, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    examId,
    variantId,
    moduleId,
    source,
    rawScore,
    bandScore,
    date,
    notes,
    tags,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LogEntry &&
          other.id == this.id &&
          other.examId == this.examId &&
          other.variantId == this.variantId &&
          other.moduleId == this.moduleId &&
          other.source == this.source &&
          other.rawScore == this.rawScore &&
          other.bandScore == this.bandScore &&
          other.date == this.date &&
          other.notes == this.notes &&
          other.tags == this.tags &&
          other.createdAt == this.createdAt);
}

class LogEntriesCompanion extends UpdateCompanion<LogEntry> {
  final Value<int> id;
  final Value<String> examId;
  final Value<String?> variantId;
  final Value<String> moduleId;
  final Value<String> source;
  final Value<int?> rawScore;
  final Value<double?> bandScore;
  final Value<DateTime> date;
  final Value<String> notes;
  final Value<String> tags;
  final Value<DateTime> createdAt;
  const LogEntriesCompanion({
    this.id = const Value.absent(),
    this.examId = const Value.absent(),
    this.variantId = const Value.absent(),
    this.moduleId = const Value.absent(),
    this.source = const Value.absent(),
    this.rawScore = const Value.absent(),
    this.bandScore = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.tags = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LogEntriesCompanion.insert({
    this.id = const Value.absent(),
    this.examId = const Value.absent(),
    this.variantId = const Value.absent(),
    required String moduleId,
    this.source = const Value.absent(),
    this.rawScore = const Value.absent(),
    this.bandScore = const Value.absent(),
    required DateTime date,
    this.notes = const Value.absent(),
    this.tags = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : moduleId = Value(moduleId),
       date = Value(date);
  static Insertable<LogEntry> custom({
    Expression<int>? id,
    Expression<String>? examId,
    Expression<String>? variantId,
    Expression<String>? moduleId,
    Expression<String>? source,
    Expression<int>? rawScore,
    Expression<double>? bandScore,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<String>? tags,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (examId != null) 'exam_id': examId,
      if (variantId != null) 'variant_id': variantId,
      if (moduleId != null) 'module_id': moduleId,
      if (source != null) 'source': source,
      if (rawScore != null) 'raw_score': rawScore,
      if (bandScore != null) 'band_score': bandScore,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (tags != null) 'tags': tags,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LogEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? examId,
    Value<String?>? variantId,
    Value<String>? moduleId,
    Value<String>? source,
    Value<int?>? rawScore,
    Value<double?>? bandScore,
    Value<DateTime>? date,
    Value<String>? notes,
    Value<String>? tags,
    Value<DateTime>? createdAt,
  }) {
    return LogEntriesCompanion(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      variantId: variantId ?? this.variantId,
      moduleId: moduleId ?? this.moduleId,
      source: source ?? this.source,
      rawScore: rawScore ?? this.rawScore,
      bandScore: bandScore ?? this.bandScore,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (examId.present) {
      map['exam_id'] = Variable<String>(examId.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (moduleId.present) {
      map['module_id'] = Variable<String>(moduleId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rawScore.present) {
      map['raw_score'] = Variable<int>(rawScore.value);
    }
    if (bandScore.present) {
      map['band_score'] = Variable<double>(bandScore.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('variantId: $variantId, ')
          ..write('moduleId: $moduleId, ')
          ..write('source: $source, ')
          ..write('rawScore: $rawScore, ')
          ..write('bandScore: $bandScore, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$LogDatabase extends GeneratedDatabase {
  _$LogDatabase(QueryExecutor e) : super(e);
  $LogDatabaseManager get managers => $LogDatabaseManager(this);
  late final $LogEntriesTable logEntries = $LogEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [logEntries];
}

typedef $$LogEntriesTableCreateCompanionBuilder =
    LogEntriesCompanion Function({
      Value<int> id,
      Value<String> examId,
      Value<String?> variantId,
      required String moduleId,
      Value<String> source,
      Value<int?> rawScore,
      Value<double?> bandScore,
      required DateTime date,
      Value<String> notes,
      Value<String> tags,
      Value<DateTime> createdAt,
    });
typedef $$LogEntriesTableUpdateCompanionBuilder =
    LogEntriesCompanion Function({
      Value<int> id,
      Value<String> examId,
      Value<String?> variantId,
      Value<String> moduleId,
      Value<String> source,
      Value<int?> rawScore,
      Value<double?> bandScore,
      Value<DateTime> date,
      Value<String> notes,
      Value<String> tags,
      Value<DateTime> createdAt,
    });

class $$LogEntriesTableFilterComposer
    extends Composer<_$LogDatabase, $LogEntriesTable> {
  $$LogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examId => $composableBuilder(
    column: $table.examId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variantId => $composableBuilder(
    column: $table.variantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rawScore => $composableBuilder(
    column: $table.rawScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bandScore => $composableBuilder(
    column: $table.bandScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LogEntriesTableOrderingComposer
    extends Composer<_$LogDatabase, $LogEntriesTable> {
  $$LogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examId => $composableBuilder(
    column: $table.examId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variantId => $composableBuilder(
    column: $table.variantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rawScore => $composableBuilder(
    column: $table.rawScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bandScore => $composableBuilder(
    column: $table.bandScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LogEntriesTableAnnotationComposer
    extends Composer<_$LogDatabase, $LogEntriesTable> {
  $$LogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get examId =>
      $composableBuilder(column: $table.examId, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get moduleId =>
      $composableBuilder(column: $table.moduleId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get rawScore =>
      $composableBuilder(column: $table.rawScore, builder: (column) => column);

  GeneratedColumn<double> get bandScore =>
      $composableBuilder(column: $table.bandScore, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LogEntriesTableTableManager
    extends
        RootTableManager<
          _$LogDatabase,
          $LogEntriesTable,
          LogEntry,
          $$LogEntriesTableFilterComposer,
          $$LogEntriesTableOrderingComposer,
          $$LogEntriesTableAnnotationComposer,
          $$LogEntriesTableCreateCompanionBuilder,
          $$LogEntriesTableUpdateCompanionBuilder,
          (LogEntry, BaseReferences<_$LogDatabase, $LogEntriesTable, LogEntry>),
          LogEntry,
          PrefetchHooks Function()
        > {
  $$LogEntriesTableTableManager(_$LogDatabase db, $LogEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LogEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> examId = const Value.absent(),
                Value<String?> variantId = const Value.absent(),
                Value<String> moduleId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int?> rawScore = const Value.absent(),
                Value<double?> bandScore = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LogEntriesCompanion(
                id: id,
                examId: examId,
                variantId: variantId,
                moduleId: moduleId,
                source: source,
                rawScore: rawScore,
                bandScore: bandScore,
                date: date,
                notes: notes,
                tags: tags,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> examId = const Value.absent(),
                Value<String?> variantId = const Value.absent(),
                required String moduleId,
                Value<String> source = const Value.absent(),
                Value<int?> rawScore = const Value.absent(),
                Value<double?> bandScore = const Value.absent(),
                required DateTime date,
                Value<String> notes = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LogEntriesCompanion.insert(
                id: id,
                examId: examId,
                variantId: variantId,
                moduleId: moduleId,
                source: source,
                rawScore: rawScore,
                bandScore: bandScore,
                date: date,
                notes: notes,
                tags: tags,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LogEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LogDatabase,
      $LogEntriesTable,
      LogEntry,
      $$LogEntriesTableFilterComposer,
      $$LogEntriesTableOrderingComposer,
      $$LogEntriesTableAnnotationComposer,
      $$LogEntriesTableCreateCompanionBuilder,
      $$LogEntriesTableUpdateCompanionBuilder,
      (LogEntry, BaseReferences<_$LogDatabase, $LogEntriesTable, LogEntry>),
      LogEntry,
      PrefetchHooks Function()
    >;

class $LogDatabaseManager {
  final _$LogDatabase _db;
  $LogDatabaseManager(this._db);
  $$LogEntriesTableTableManager get logEntries =>
      $$LogEntriesTableTableManager(_db, _db.logEntries);
}
