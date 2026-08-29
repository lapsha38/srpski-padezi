import 'package:flutter/material.dart';
import 'package:srpski_padezi/logic/quiz_engine.dart';
import 'package:srpski_padezi/models/models.dart';
import 'package:srpski_padezi/screens/case_screen.dart';
import 'package:srpski_padezi/screens/quiz_screen.dart';
import 'package:srpski_padezi/services/progress_service.dart';
import 'package:srpski_padezi/theme.dart';

/// Итоги тренировки с разбором ошибок.
class ResultScreen extends StatelessWidget {
  const ResultScreen({required this.answers, required this.session, super.key});

  final List<AnswerRecord> answers;
  final QuizSession session;

  int get _correct => answers.where((a) => a.correct).length;
  int get _percent => (_correct * 100 / answers.length).round();
  bool get _passed => _percent >= ProgressService.passingScore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mistakes = answers.where((a) => !a.correct).toList();
    final gramCase = session.gramCase;
    final nextCase =
        gramCase != null && gramCase.index + 1 < GramCase.values.length
        ? GramCase.values[gramCase.index + 1]
        : null;
    final nextStep = session.next;

    return Scaffold(
      appBar: AppBar(title: const Text('Результат')),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('$_percent%', style: theme.textTheme.displaySmall),
                    const SizedBox(height: 4),
                    Text(
                      'Правильных ответов: $_correct из ${answers.length}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _passed
                          ? gramCase == null
                                ? 'Отличная работа!'
                                : 'Падеж ${gramCase.sr} пройден.'
                          : 'Для отметки о прохождении нужно '
                                '${ProgressService.passingScore}% - '
                                'попробуйте ещё раз.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Пока порог не взят, разумнее повторить ту же тренировку,
            // поэтому главной кнопкой «Дальше» становится только после
            // прохождения.
            if (nextStep != null && _passed) ...[
              FilledButton(
                onPressed: () => _startNext(context, nextStep),
                child: Text('Дальше: ${nextStep.label}'),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => _repeat(context, session),
                child: const Text('Пройти ещё раз'),
              ),
            ] else ...[
              FilledButton(
                onPressed: () => _repeat(context, session),
                child: const Text('Пройти ещё раз'),
              ),
              if (nextStep != null) ...[
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () => _startNext(context, nextStep),
                  child: Text('Дальше: ${nextStep.label}'),
                ),
              ],
            ],
            // Следующий падеж предлагается в конце цепочки: пока у урока
            // есть продолжение, уходить из него рано.
            if (nextCase != null && nextStep == null) ...[
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => CaseScreen(gramCase: nextCase),
                    ),
                  );
                },
                child: Text('Следующий падеж: ${nextCase.sr}'),
              ),
            ],
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('На главный экран'),
            ),
            const SizedBox(height: 24),
            if (mistakes.isNotEmpty) ...[
              Text('Разбор ошибок', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final m in mistakes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _MistakeCard(record: m),
                ),
            ] else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Ни одной ошибки - так держать!'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Запускает ту же тренировку заново - с новым набором вопросов.
void _repeat(BuildContext context, QuizSession session) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute<void>(builder: (_) => QuizScreen(session: session)),
  );
}

/// Переходит к следующей тренировке урока.
void _startNext(BuildContext context, NextStep step) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute<void>(builder: (_) => QuizScreen(session: step.build())),
  );
}

class _MistakeCard extends StatelessWidget {
  const _MistakeCard({required this.record});

  final AnswerRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = record.question;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q.isContextual
                  ? q.contextSr!.replaceAll('___', q.answer)
                  : q.summary ?? q.answer,
              style: theme.textTheme.titleMedium,
            ),
            if (q.tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(q.tags.join(' · '), style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.close, size: 18, color: theme.colorScheme.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Ваш ответ: ${record.given}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.check, size: 18, color: Colors.green.shade600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Правильно: ${q.answer}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            if (q.hint != null) ...[
              const SizedBox(height: 8),
              Text(q.hint!, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
