import 'package:flutter/material.dart';
import 'package:srpski_padezi/logic/quiz_engine.dart';
import 'package:srpski_padezi/models/models.dart';
import 'package:srpski_padezi/screens/result_screen.dart';
import 'package:srpski_padezi/services/progress_service.dart';
import 'package:srpski_padezi/theme.dart';
import 'package:srpski_padezi/widgets/rule_sheet.dart';
import 'package:srpski_padezi/widgets/tag_chip.dart';

/// Экран тренировки: вопрос и четыре варианта ответа.
class QuizScreen extends StatefulWidget {
  const new({required this.session, super.key});

  final QuizSession session;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<Question> _questions;
  final List<AnswerRecord> _answers = [];

  int _index = 0;
  String? _selected;

  /// Выбор в каждой части составного ответа, пока выбраны не все.
  final Map<int, String> _partChoices = {};

  @override
  void initState() {
    super.initState();
    _questions = widget.session.build();
  }

  Question get _question => _questions[_index];
  bool get _answered => _selected != null;

  void _select(String option) {
    if (_answered) return;
    setState(() => _selected = option);
    _answers.add(
      AnswerRecord(
        question: _question,
        given: option,
        correct: option == _question.answer,
      ),
    );
  }

  /// Ответ засчитывается, когда выбраны все части; до этого выбор
  /// в части можно поменять.
  void _selectPart(int part, String option) {
    if (_answered) return;
    setState(() => _partChoices[part] = option);
    final parts = _question.parts;
    if (_partChoices.length < parts.length) return;
    _select(
      joinParts([for (var i = 0; i < parts.length; i++) _partChoices[i]!]),
    );
  }

  Future<void> _next() async {
    if (_index + 1 < _questions.length) {
      setState(() {
        _index++;
        _selected = null;
        _partChoices.clear();
      });
      return;
    }

    final correct = _answers.where((a) => a.correct).length;
    final percent = (correct * 100 / _answers.length).round();
    final progress = ProgressService.instance;

    await progress.recordAnswers(total: _answers.length, correct: correct);
    final key = widget.session.progressKey;
    if (key != null) {
      await progress.recordResult(key, percent);
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            ResultScreen(answers: _answers, session: widget.session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.session.title)),
        body: const Center(child: Text('Для этой тренировки нет заданий.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_index + (_answered ? 1 : 0)) / _questions.length,
            minHeight: 4,
          ),
        ),
      ),
      body: ContentWidth(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                children: [
                  Text(
                    'Вопрос ${_index + 1} из ${_questions.length}',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 12),
                  _QuestionCard(question: _question, revealed: _answered),
                  if (_question.rule != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () =>
                            showRuleSheet(context, _question.rule!),
                        icon: const Icon(Icons.menu_book_outlined),
                        label: const Text('Правило'),
                      ),
                    ),
                  const SizedBox(height: 8),
                  for (final (i, part) in _question.parts.indexed) ...[
                    Text(part.label, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    _OptionGrid(
                      children: [
                        for (final option in part.options)
                          _OptionButton(
                            label: option,
                            state: _partStateFor(i, part, option),
                            onTap: () => _selectPart(i, option),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  for (final option in _question.options)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _OptionButton(
                        label: option,
                        state: _stateFor(option),
                        onTap: () => _select(option),
                      ),
                    ),
                  if (_answered) ...[
                    const SizedBox(height: 4),
                    _FeedbackCard(
                      question: _question,
                      correct: _selected == _question.answer,
                    ),
                  ],
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _answered ? _next : null,
                    child: Text(
                      _index + 1 < _questions.length
                          ? 'Дальше'
                          : 'Показать результат',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _OptionState _stateFor(String option) {
    if (!_answered) return _OptionState.idle;
    if (option == _question.answer) return _OptionState.correct;
    if (option == _selected) return _OptionState.wrong;
    return _OptionState.idle;
  }

  _OptionState _partStateFor(int i, AnswerPart part, String option) {
    final chosen = _partChoices[i] == option;
    if (!_answered) return chosen ? _OptionState.chosen : _OptionState.idle;
    if (option == part.answer) return _OptionState.correct;
    if (chosen) return _OptionState.wrong;
    return _OptionState.idle;
  }
}

/// Варианты одной части ответа в две колонки: формы короткие, а частей
/// несколько - в столбик задание не помещается на экран.
class _OptionGrid extends StatelessWidget {
  const new({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(child: children[i]),
                const SizedBox(width: 10),
                Expanded(
                  child: i + 1 < children.length
                      ? children[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Формулировка задания: предложение с пропуском или прямое указание темы.
class _QuestionCard extends StatelessWidget {
  const new({required this.question, required this.revealed});

  final Question question;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (question.tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final tag in question.tags) TagChip(tag)],
              ),
              const SizedBox(height: 12),
            ],
            if (question.isContextual) ...[
              Text(
                revealed
                    ? question.contextSr!.replaceAll('___', question.answer)
                    : question.contextSr!.replaceAll('___', '______'),
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              if (question.contextRu != null)
                Text(question.contextRu!, style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
              Text(question.prompt, style: theme.textTheme.bodyMedium),
            ] else ...[
              if (question.subject != null) ...[
                Text(question.subject!, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
              ],
              Text(question.prompt, style: theme.textTheme.bodyMedium),
              if (question.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(question.subtitle!, style: theme.textTheme.bodySmall),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

enum _OptionState { idle, chosen, correct, wrong }

/// Кнопка варианта ответа с подсветкой после ответа.
class _OptionButton extends StatelessWidget {
  const new({required this.label, required this.state, required this.onTap});

  final String label;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (
      Color? background,
      Color? foreground,
      IconData? icon,
    ) = switch (state) {
      _OptionState.idle || _OptionState.chosen => (null, null, null),
      _OptionState.correct => (
        Colors.green.shade600,
        Colors.white,
        Icons.check_circle,
      ),
      _OptionState.wrong => (scheme.error, scheme.onError, Icons.cancel),
    };

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: Text(label, textAlign: TextAlign.center)),
        if (icon != null) ...[const SizedBox(width: 8), Icon(icon, size: 20)],
      ],
    );

    if (state == _OptionState.idle) {
      return OutlinedButton(onPressed: onTap, child: child);
    }
    if (state == _OptionState.chosen) {
      return FilledButton.tonal(onPressed: onTap, child: child);
    }
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
      ),
      onPressed: onTap,
      child: child,
    );
  }
}

/// Пояснение после ответа.
class _FeedbackCard extends StatelessWidget {
  const new({required this.question, required this.correct});

  final Question question;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  correct ? Icons.check_circle : Icons.info_outline,
                  color: correct
                      ? Colors.green.shade600
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    correct ? 'Верно!' : 'Правильный ответ: ${question.answer}',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (question.summary != null) ...[
              const SizedBox(height: 8),
              Text(question.summary!, style: theme.textTheme.bodyMedium),
            ],
            if (question.hint != null) ...[
              const SizedBox(height: 6),
              Text(question.hint!, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
