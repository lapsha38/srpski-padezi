import 'package:flutter/material.dart';
import 'package:srpski_padezi/data/cases.dart';
import 'package:srpski_padezi/data/grammar_topics.dart';
import 'package:srpski_padezi/data/texts.dart';
import 'package:srpski_padezi/logic/numeral_quiz.dart';
import 'package:srpski_padezi/logic/phrase_table.dart';
import 'package:srpski_padezi/logic/quiz_engine.dart';
import 'package:srpski_padezi/models/models.dart';
import 'package:srpski_padezi/screens/case_screen.dart';
import 'package:srpski_padezi/screens/gap_text_screen.dart';
import 'package:srpski_padezi/screens/grammar_screen.dart';
import 'package:srpski_padezi/screens/numerals_screen.dart';
import 'package:srpski_padezi/screens/phrase_table_screen.dart';
import 'package:srpski_padezi/screens/quiz_screen.dart';
import 'package:srpski_padezi/services/progress_service.dart';
import 'package:srpski_padezi/services/theme_service.dart';
import 'package:srpski_padezi/theme.dart';

/// Главный экран: путь обучения по семи падежам.
class HomeScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = ProgressService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Srpski Padeži'),
        actions: [
          const _ThemeButton(),
          IconButton(
            tooltip: 'Сбросить прогресс',
            icon: const Icon(Icons.restart_alt),
            onPressed: () => _confirmReset(context),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: progress,
        builder: (context, _) {
          return ContentWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _ProgressCard(progress: progress),
                const SizedBox(height: 16),
                Text('Падежи', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final gramCase in kCaseLearningOrder) ...[
                  _CaseTile(
                    info: caseInfoFor(gramCase),
                    passed: progress.isPassed(gramCase),
                    bestScore: progress.caseScore(gramCase),
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),
                const _MixedTrainingCard(),
                const SizedBox(height: 16),
                Text(
                  'Дополнительные темы',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const _GapTextsCard(),
                const SizedBox(height: 8),
                const _PhrasesCard(),
                const SizedBox(height: 8),
                const _PhraseTableCard(),
                const SizedBox(height: 8),
                const _NumeralsCard(),
                const SizedBox(height: 8),
                const _GrammarCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сбросить прогресс?'),
        content: const Text(
          'Результаты всех тренировок будут удалены, откроется только первый '
          'падеж.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ProgressService.instance.reset();
    }
  }
}

/// Карточка с общим прогрессом курса.
class _ProgressCard extends StatelessWidget {
  const new({required this.progress});

  final ProgressService progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accuracy = progress.totalAnswers == 0
        ? null
        : (progress.totalCorrect * 100 / progress.totalAnswers).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              progress.isCourseComplete
                  ? 'Курс пройден полностью'
                  : 'Сейчас изучаем: ${progress.currentCase.sr} '
                        '(${progress.currentCase.ru})',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.courseProgress,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(
                    'Пройдено: ${progress.passedCount} из '
                    '${GramCase.values.length}',
                  ),
                ),
                Chip(
                  avatar: const Icon(Icons.quiz_outlined, size: 18),
                  label: Text('Ответов: ${progress.totalAnswers}'),
                ),
                if (accuracy != null)
                  Chip(
                    avatar: const Icon(Icons.percent, size: 18),
                    label: Text('Точность: $accuracy%'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Плитка одного падежа в списке.
class _CaseTile extends StatelessWidget {
  const new({
    required this.info,
    required this.passed,
    required this.bestScore,
  });

  final CaseInfo info;
  final bool passed;
  final int bestScore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gramCase = info.gramCase;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => CaseScreen(gramCase: gramCase),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                child: passed
                    ? const Icon(Icons.check)
                    : Text('${caseLearningStep(gramCase)}'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${gramCase.sr} - ${gramCase.ru}',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(info.tagline, style: theme.textTheme.bodySmall),
                    if (bestScore > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Лучший результат: $bestScore%',
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Карточка смешанной тренировки по всем изученным падежам.
class _MixedTrainingCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Смешанная тренировка', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Все падежи вперемешку, единственное и множественное число.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _start(context),
              icon: const Icon(Icons.shuffle),
              label: const Text('Начать'),
            ),
          ],
        ),
      ),
    );
  }

  void _start(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => QuizScreen(session: QuizPresets.mixed(GramCase.values)),
      ),
    );
  }
}

/// Карточка раздела «Числительные».
class _NumeralsCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = ProgressService.instance;
    final passed = NumeralQuizKind.values
        .where((k) => progress.isPassedKey(k.progressKey))
        .length;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const NumeralsScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(radius: 20, child: Icon(Icons.pin_outlined)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Числительные', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Счёт до тысячи, порядковые и собирательные числительные '
                      'и падеж существительного после числа.',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (passed > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Пройдено тренировок: $passed из '
                        '${NumeralQuizKind.values.length}',
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Карточка раздела «Грамматика».
class _GrammarCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = ProgressService.instance;
    final drills = [for (final topic in kGrammarTopics) ...topic.drills];
    final passed = drills
        .where((d) => progress.isPassedKey(d.progressKey))
        .length;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const GrammarScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                child: Icon(Icons.auto_stories_outlined),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Грамматика', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Времена глагола, повелительное наклонение, отрицание, '
                      'местоимения, порядок энклитик и степени сравнения.',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (passed > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Пройдено тренировок: $passed из ${drills.length}',
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Карточка режима «текст с пропусками».
class _GapTextsCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = ProgressService.instance;
    final done = kGapTexts
        .where((t) => progress.isPassedKey(gapTextProgressKey(t)))
        .length;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const GapTextListScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                child: Icon(Icons.edit_note_outlined),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Текст с пропусками',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Связный текст: впишите слова в нужном падеже. '
                      'После проверки - разбор каждой ошибки.',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (done > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Пройдено текстов: $done из ${kGapTexts.length}',
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Карточка тренировки словосочетаний.
///
/// Тренируются падежи, которые уже открыты: так словосочетания не забегают
/// вперёд программы.
class _PhrasesCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = ProgressService.instance;
    final best = progress.bestScore('phrases_mixed');

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) =>
                QuizScreen(session: QuizPresets.phrases(GramCase.values)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                child: Icon(Icons.join_inner_outlined),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Прилагательное + существительное',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Согласование в одной форме: lepog grada, lepim ženama. '
                      'Все падежи вперемешку.',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (best > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Лучший результат: $best%',
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Карточка режима «таблица склонения».
class _PhraseTableCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final best = ProgressService.instance.bestScore(
      PhraseTableGenerator.progressKey,
    );

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const PhraseTableScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                child: Icon(Icons.table_rows_outlined),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Таблица склонения',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Случайное словосочетание и все семь падежей сразу: '
                      'форму для каждой строки выбираешь из вариантов.',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (best > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Лучший результат: $best%',
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Кнопка переключения светлой и тёмной темы.
class _ThemeButton extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    // Яркость берётся у темы, а не у выбранного режима: пока режим
    // системный, кнопка должна предлагать то, чего сейчас нет на экране.
    final dark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      tooltip: dark ? 'Светлая тема' : 'Тёмная тема',
      icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      onPressed: () =>
          ThemeService.instance.toggle(Theme.of(context).brightness),
    );
  }
}
