import 'package:flutter/material.dart';
import 'package:srpski_padezi/data/cases.dart';
import 'package:srpski_padezi/data/nouns.dart';
import 'package:srpski_padezi/logic/quiz_engine.dart';
import 'package:srpski_padezi/models/models.dart';
import 'package:srpski_padezi/screens/quiz_screen.dart';
import 'package:srpski_padezi/services/progress_service.dart';
import 'package:srpski_padezi/theme.dart';
import 'package:srpski_padezi/widgets/section_card.dart';

/// Экран теории по одному падежу и запуск тренировок.
class CaseScreen extends StatelessWidget {
  const CaseScreen({required this.gramCase, super.key});

  final GramCase gramCase;

  @override
  Widget build(BuildContext context) {
    final info = caseInfoFor(gramCase);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('${gramCase.order}. ${gramCase.sr}')),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            SectionCard(
              title: '${gramCase.sr} - ${gramCase.ru} падеж',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Вопросы: ${gramCase.questions}',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(info.summary, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            SectionCard(
              title: 'Когда употребляется',
              child: BulletList(items: info.meanings),
            ),
            if (info.prepositions.isNotEmpty)
              SectionCard(
                title: 'Предлоги',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in info.prepositions) Chip(label: Text(p)),
                  ],
                ),
              ),
            SectionCard(
              title: 'Окончания',
              child: FormsTable(rows: info.endings),
            ),
            SectionCard(
              title: 'Примеры склонения',
              child: _DeclensionSamples(gramCase: gramCase),
            ),
            SectionCard(
              title: 'Примеры',
              child: ExampleList(examples: info.examples),
            ),
            SectionCard(
              title: 'Сравнение с русским',
              child: Text(info.russianNote, style: theme.textTheme.bodyMedium),
            ),
            SectionCard(
              title: 'Типичные ошибки',
              child: BulletList(items: info.pitfalls),
            ),
            const SizedBox(height: 8),
            _TrainingButtons(gramCase: gramCase),
          ],
        ),
      ),
    );
  }
}

/// Кнопки запуска тренировок и напоминание о пороге прохождения.
class _TrainingButtons extends StatelessWidget {
  const _TrainingButtons({required this.gramCase});

  final GramCase gramCase;

  @override
  Widget build(BuildContext context) {
    final progress = ProgressService.instance;

    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final best = progress.caseScore(gramCase);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Тренировка',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  best > 0
                      ? 'Лучший результат: $best%. Падеж считается '
                            'пройденным начиная с '
                            '${ProgressService.passingScore}%.'
                      : 'В каждой тренировке 12 вопросов. Падеж считается '
                            'пройденным начиная с '
                            '${ProgressService.passingScore}%.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => _start(context, NumberMode.singular),
                  child: const Text('Единственное число'),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () => _start(context, NumberMode.plural),
                  child: const Text('Множественное число'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _start(context, NumberMode.mixed),
                  child: const Text('Оба числа вперемешку'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Словосочетания',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Прилагательное и существительное меняются вместе - '
                  'это и нужно довести до автоматизма.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _start(
                    context,
                    NumberMode.mixed,
                    practice: PracticeMode.phrases,
                  ),
                  child: const Text('Прилагательное + существительное'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _start(
    BuildContext context,
    NumberMode mode, {
    PracticeMode practice = PracticeMode.nouns,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => QuizScreen(
          session: QuizPresets.forCase(gramCase, mode, practice: practice),
        ),
      ),
    );
  }
}

/// Показывает форму падежа у нескольких слов разных склонений.
class _DeclensionSamples extends StatelessWidget {
  const _DeclensionSamples({required this.gramCase});

  final GramCase gramCase;

  static const List<String> _lemmas = [
    'grad',
    'student',
    'žena',
    'noć',
    'selo',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final lemma in _lemmas)
          Builder(
            builder: (context) {
              final noun = kNounsByLemma[lemma]!;
              final sg = noun.form(gramCase, GramNumber.singular) ?? '-';
              final pl = noun.form(gramCase, GramNumber.plural) ?? '-';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        '${noun.lemma} (${noun.ru})',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '$sg  /  $pl',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 4),
        Text(
          'Слева - единственное число, справа - множественное.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
