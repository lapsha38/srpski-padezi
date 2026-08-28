import 'package:flutter/material.dart';
import 'package:srpski_padezi/data/grammar_topics.dart';
import 'package:srpski_padezi/logic/grammar_quiz.dart';
import 'package:srpski_padezi/screens/quiz_screen.dart';
import 'package:srpski_padezi/services/progress_service.dart';
import 'package:srpski_padezi/theme.dart';
import 'package:srpski_padezi/widgets/section_card.dart';

/// Теория одной грамматической темы и запуск её тренировок.
class TopicScreen extends StatelessWidget {
  const TopicScreen({required this.topic, super.key});

  final GrammarTopic topic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            for (final section in topic.sections)
              TopicSectionView(section: section),
            _Trainings(topic: topic),
          ],
        ),
      ),
    );
  }
}

class _Trainings extends StatelessWidget {
  const _Trainings({required this.topic});

  final GrammarTopic topic;

  @override
  Widget build(BuildContext context) {
    final progress = ProgressService.instance;
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) => SectionCard(
        title: 'Тренировка',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final drill in topic.drills) ...[
              Text(drill.title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(drill.description, style: theme.textTheme.bodySmall),
              if (progress.bestScore(drill.progressKey) > 0) ...[
                const SizedBox(height: 2),
                Text(
                  'Лучший результат: ${progress.bestScore(drill.progressKey)}%',
                  style: theme.textTheme.labelMedium,
                ),
              ],
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => QuizScreen(
                      session: GrammarQuizPresets.forDrill(drill),
                    ),
                  ),
                ),
                child: const Text('Начать'),
              ),
              if (drill != topic.drills.last) const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
