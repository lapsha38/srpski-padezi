import 'package:flutter/material.dart';
import 'package:srpski_padezi/data/numerals.dart';
import 'package:srpski_padezi/logic/numeral_quiz.dart';
import 'package:srpski_padezi/screens/quiz_screen.dart';
import 'package:srpski_padezi/services/progress_service.dart';
import 'package:srpski_padezi/theme.dart';
import 'package:srpski_padezi/widgets/section_card.dart';

/// Раздел «Числительные»: теория и три тренировки.
class NumeralsScreen extends StatelessWidget {
  const NumeralsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Числительные')),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            SectionCard(
              title: 'Зачем этот раздел',
              child: Text(
                'Числительные в сербском языке неотделимы от падежей: после '
                'jedan существительное стоит в именительном падеже, после dva, '
                'tri, četiri - в родительном единственного числа, а после pet '
                'и дальше - в родительном множественного. Здесь собраны сами '
                'числа, правила согласования и тренировки на них.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SectionCard(
              title: 'Таблица числительных',
              child: _NumeralsTable(),
            ),
            for (final topic in kNumeralTopics)
              TopicSectionView(section: topic),
            const _NumeralTrainings(),
          ],
        ),
      ),
    );
  }
}

/// Таблица «число - количественное - порядковое - собирательное».
class _NumeralsTable extends StatelessWidget {
  const _NumeralsTable();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        headingRowHeight: 40,
        dataRowMinHeight: 38,
        dataRowMaxHeight: 46,
        columns: [
          DataColumn(label: Text('№', style: labelStyle)),
          DataColumn(label: Text('Количественное', style: labelStyle)),
          DataColumn(label: Text('Порядковое', style: labelStyle)),
          DataColumn(label: Text('Собирательное', style: labelStyle)),
        ],
        rows: [
          for (final n in kNumerals)
            DataRow(
              cells: [
                DataCell(Text('${n.value}')),
                DataCell(Text(n.cardinal)),
                DataCell(Text(n.ordinal)),
                DataCell(Text(n.collective ?? '-')),
              ],
            ),
        ],
      ),
    );
  }
}

/// Кнопки запуска тренировок по числительным.
class _NumeralTrainings extends StatelessWidget {
  const _NumeralTrainings();

  @override
  Widget build(BuildContext context) {
    final progress = ProgressService.instance;
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) => SectionCard(
        title: 'Тренировки',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final kind in NumeralQuizKind.values) ...[
              Text(kind.title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(kind.description, style: theme.textTheme.bodySmall),
              if (progress.bestScore(kind.progressKey) > 0) ...[
                const SizedBox(height: 2),
                Text(
                  'Лучший результат: ${progress.bestScore(kind.progressKey)}%',
                  style: theme.textTheme.labelMedium,
                ),
              ],
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => QuizScreen(
                      session: NumeralQuizPresets.forKind(kind),
                    ),
                  ),
                ),
                child: const Text('Начать'),
              ),
              if (kind != NumeralQuizKind.values.last)
                const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
