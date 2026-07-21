import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/exam/exam_module.dart';
import '../../../core/exam/exam_registry.dart';
import '../data/log_database.dart';
import '../data/log_providers.dart';
import 'log_format.dart';

/// Add / edit a practice-log entry. Pass [existing] to edit.
class LogEntryEditor extends ConsumerStatefulWidget {
  const LogEntryEditor({super.key, this.existing});
  final LogEntry? existing;

  static Future<void> open(BuildContext context, {LogEntry? existing}) {
    return Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => LogEntryEditor(existing: existing),
    ));
  }

  @override
  ConsumerState<LogEntryEditor> createState() => _LogEntryEditorState();
}

class _LogEntryEditorState extends ConsumerState<LogEntryEditor> {
  final _formKey = GlobalKey<FormState>();
  late String _moduleId;
  String? _variantId;
  late TextEditingController _source;
  late TextEditingController _notes;
  late TextEditingController _tags;
  int? _rawScore;
  double? _bandScore;
  late DateTime _date;

  ExamModule get _exam => ref.read(selectedExamProvider);

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _moduleId = e?.moduleId ?? _exam.moduleOptions.first.id;
    _variantId = e?.variantId ?? _exam.variants.firstOrNull?.id;
    _source = TextEditingController(text: e?.source ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
    _tags = TextEditingController(text: e?.tags ?? '');
    _rawScore = e?.rawScore;
    _bandScore = e?.bandScore;
    _date = e?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _source.dispose();
    _notes.dispose();
    _tags.dispose();
    super.dispose();
  }

  bool get _isRawBased =>
      _exam.moduleOptions.firstWhere((m) => m.id == _moduleId,
          orElse: () => const ExamModuleOption(id: '', label: '')).isRawBased;

  List<double> get _bandSteps => _exam.scoreScale.steps;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rawScore == null && _bandScore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a raw score and/or a band.')),
      );
      return;
    }
    final db = ref.read(logDatabaseProvider);
    final companion = LogEntriesCompanion(
      examId: Value(_exam.id),
      variantId: Value(_variantId),
      moduleId: Value(_moduleId),
      source: Value(_source.text.trim()),
      rawScore: Value(_isRawBased ? _rawScore : null),
      bandScore: Value(_bandScore),
      date: Value(_date),
      notes: Value(_notes.text.trim()),
      tags: Value(_tags.text.trim()),
    );
    if (widget.existing == null) {
      await db.insertEntry(companion);
    } else {
      await db.updateEntry(widget.existing!.copyWith(
        variantId: Value(_variantId),
        moduleId: _moduleId,
        source: _source.text.trim(),
        rawScore: Value(_isRawBased ? _rawScore : null),
        bandScore: Value(_bandScore),
        date: _date,
        notes: _notes.text.trim(),
        tags: _tags.text.trim(),
      ));
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit entry' : 'New entry'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Label('Module'),
            Wrap(
              spacing: 8,
              children: _exam.moduleOptions.map((m) {
                return ChoiceChip(
                  label: Text(m.label),
                  selected: _moduleId == m.id,
                  onSelected: (_) => setState(() {
                    _moduleId = m.id;
                    if (!_isRawBased) _rawScore = null;
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (_exam.variants.isNotEmpty) ...[
              _Label('Exam type'),
              Wrap(
                spacing: 8,
                children: _exam.variants.map((v) {
                  return ChoiceChip(
                    label: Text(v.label),
                    selected: _variantId == v.id,
                    onSelected: (_) => setState(() => _variantId = v.id),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            _Label('Source / reference'),
            TextFormField(
              controller: _source,
              decoration: const InputDecoration(
                hintText: 'e.g. Cambridge IELTS 18, Test 2',
              ),
            ),
            const SizedBox(height: 16),
            if (_isRawBased) ...[
              _Label('Raw score (out of 40)'),
              _RawStepper(
                value: _rawScore ?? 30,
                enabled: true,
                onChanged: (v) => setState(() => _rawScore = v),
              ),
              const SizedBox(height: 16),
            ],
            _Label('Band achieved'),
            DropdownButtonFormField<double?>(
              initialValue: _bandScore,
              decoration: const InputDecoration(hintText: 'Select band'),
              items: [
                const DropdownMenuItem(value: null, child: Text('— none —')),
                for (final b in _bandSteps)
                  DropdownMenuItem(value: b, child: Text('Band ${LogFormat.band(b)}')),
              ],
              onChanged: (v) => setState(() => _bandScore = v),
            ),
            const SizedBox(height: 16),
            _Label('Date'),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(LogFormat.date(_date)),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2015),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 16),
            _Label('Notes'),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Optional notes'),
            ),
            const SizedBox(height: 16),
            _Label('Tags (comma-separated)'),
            TextFormField(
              controller: _tags,
              decoration: const InputDecoration(hintText: 'e.g. timed, mock'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(isEdit ? 'Save changes' : 'Add entry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(text,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}

class _RawStepper extends StatelessWidget {
  const _RawStepper({required this.value, required this.onChanged, this.enabled = true});
  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 40,
            divisions: 40,
            label: '$value',
            onChanged: enabled ? (v) => onChanged(v.round()) : null,
          ),
        ),
        SizedBox(
          width: 56,
          child: Text('$value/40',
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}
