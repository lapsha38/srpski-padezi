import 'package:flutter/material.dart';
import 'package:srpski_padezi/logic/phrase_table.dart';
import 'package:srpski_padezi/models/models.dart';
import 'package:srpski_padezi/services/progress_service.dart';
import 'package:srpski_padezi/theme.dart';
import 'package:srpski_padezi/widgets/rule_sheet.dart';
import 'package:srpski_padezi/widgets/tag_chip.dart';

/// Режим «таблица склонения»: одно словосочетание во всех семи падежах.
///
/// Обычная тренировка показывает разные слова, поэтому склонение целиком
/// в ней не видно. Здесь пара слов одна, а заполнить нужно всю таблицу -
/// так становится видно, что прилагательное и существительное меняют
/// окончания по-разному.
class PhraseTableScreen extends StatefulWidget {
  const PhraseTableScreen({this.generator, super.key});

  /// Источник словосочетаний; по умолчанию - со случайным зерном.
  /// Задаётся в тестах, чтобы проверять вёрстку на конкретных парах слов.
  final PhraseTableGenerator? generator;

  @override
  State<PhraseTableScreen> createState() => _PhraseTableScreenState();
}

class _PhraseTableScreenState extends State<PhraseTableScreen> {
  late final PhraseTableGenerator _generator =
      widget.generator ?? PhraseTableGenerator();
  late PhraseTable _table;

  /// Выбранный вариант по каждому падежу.
  final Map<GramCase, String> _given = {};

  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _table = _generator.build();
  }

  bool get _complete => _given.length == _table.rows.length;

  int get _correctCount =>
      _table.rows.where((r) => _given[r.gramCase] == r.answer).length;

  void _restart() {
    setState(() {
      _table = _generator.build();
      _given.clear();
      _saved = false;
    });
  }

  Future<void> _choose(PhraseTableRow row) async {
    if (_given.containsKey(row.gramCase)) return;

    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      // Вариантов четыре, и формы бывают длинные: лист должен уметь
      // вырасти выше половины экрана.
      isScrollControlled: true,
      builder: (context) => _OptionsSheet(row: row),
    );
    if (choice == null || !mounted) return;

    setState(() => _given[row.gramCase] = choice);
    if (_complete) await _save();
  }

  Future<void> _save() async {
    if (_saved) return;
    _saved = true;

    final total = _table.rows.length;
    final correct = _correctCount;
    final progress = ProgressService.instance;
    await progress.recordAnswers(total: total, correct: correct);
    await progress.recordResult(
      PhraseTableGenerator.progressKey,
      (correct * 100 / total).round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Таблица склонения'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: _given.length / _table.rows.length,
            minHeight: 4,
          ),
        ),
      ),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _PhraseCard(table: _table),
            const SizedBox(height: 12),
            Text(
              'Заполнено ${_given.length} из ${_table.rows.length}',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final row in _table.rows) ...[
                    _CaseRow(
                      row: row,
                      given: _given[row.gramCase],
                      onTap: () => _choose(row),
                    ),
                    if (row != _table.rows.last) const Divider(height: 1),
                  ],
                ],
              ),
            ),
            if (_complete) ...[
              const SizedBox(height: 16),
              _SummaryCard(
                correct: _correctCount,
                total: _table.rows.length,
                onRestart: _restart,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Шапка: какое словосочетание склоняем.
class _PhraseCard extends StatelessWidget {
  const _PhraseCard({required this.table});

  final PhraseTable table;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final noun = table.noun;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(table.headword, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(table.ru, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                NumberChip(table.number, label: table.number.ru),
                Chip(
                  label: Text(noun.gender.ru),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  label: Text(noun.declension.ru),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Строка таблицы: падеж слева, форма справа.
///
/// Строка собрана из Row, а не из ListTile: формы бывают длинные
/// («jednostavnim mogućnostima»), и им нужно переноситься, а не обрезаться.
class _CaseRow extends StatelessWidget {
  const _CaseRow({required this.row, required this.given, required this.onTap});

  final PhraseTableRow row;
  final String? given;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final answered = given != null;
    final correct = given == row.answer;
    // В тёмной теме тёмно-зелёный на тёмном фоне почти не читается.
    final dark = theme.brightness == Brightness.dark;
    final markColor = correct
        ? (dark ? Colors.green.shade400 : Colors.green.shade700)
        : theme.colorScheme.error;

    return InkWell(
      onTap: answered ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              child: Text(
                '${row.gramCase.order}',
                style: theme.textTheme.labelLarge,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row.gramCase.sr, style: theme.textTheme.titleSmall),
                  Text(row.gramCase.ru, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 5,
              child: !answered
                  ? Text(
                      'выбрать',
                      textAlign: TextAlign.end,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                given!,
                                textAlign: TextAlign.end,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: markColor,
                                  decoration: correct
                                      ? null
                                      : TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              correct ? Icons.check_circle : Icons.cancel,
                              size: 18,
                              color: markColor,
                            ),
                          ],
                        ),
                        if (!correct)
                          Text(
                            row.answer,
                            textAlign: TextAlign.end,
                            style: theme.textTheme.bodyMedium,
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

/// Выбор формы для одного падежа.
class _OptionsSheet extends StatelessWidget {
  const _OptionsSheet({required this.row});

  final PhraseTableRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${row.gramCase.sr} - ${row.gramCase.ru}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 2),
            Text(row.gramCase.questions, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            for (final option in row.options)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, option),
                    child: Text(option, textAlign: TextAlign.center),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () =>
                    showRuleSheet(context, RuleRef(gramCase: row.gramCase)),
                icon: const Icon(Icons.menu_book_outlined),
                label: const Text('Правило'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Итог таблицы.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.correct,
    required this.total,
    required this.onRestart,
  });

  final int correct;
  final int total;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (correct * 100 / total).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Таблица заполнена: $correct из $total ($percent%)',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Другое словосочетание'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('На главный'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
