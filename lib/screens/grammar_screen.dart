import 'package:flutter/material.dart';
import 'package:srpski_padezi/data/grammar_topics.dart';
import 'package:srpski_padezi/screens/topic_screen.dart';
import 'package:srpski_padezi/services/progress_service.dart';
import 'package:srpski_padezi/theme.dart';

/// Список грамматических тем вне падежей и числительных.
class GrammarScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = ProgressService.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Грамматика')),
      body: AnimatedBuilder(
        animation: progress,
        builder: (context, _) => ContentWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Темы можно проходить в любом порядке. В каждой сначала '
                    'идёт правило, потом тренировка на те же формы - '
                    'и во время тренировки правило всегда под рукой.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (final topic in kGrammarTopics)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _TopicTile(topic: topic),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const new({required this.topic});

  final GrammarTopic topic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = ProgressService.instance;
    final best = topic.drills
        .map((d) => progress.bestScore(d.progressKey))
        .fold(0, (a, b) => a > b ? a : b);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => TopicScreen(topic: topic)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(topic.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(topic.subtitle, style: theme.textTheme.bodySmall),
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
