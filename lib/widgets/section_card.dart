import 'package:flutter/material.dart';
import 'package:srpski_padezi/data/nouns.dart';
import 'package:srpski_padezi/logic/ending_samples.dart';
import 'package:srpski_padezi/models/models.dart';

/// Карточка-раздел с заголовком и произвольным содержимым.
class SectionCard extends StatelessWidget {
  const new({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Маркированный список правил.
class BulletList extends StatelessWidget {
  const new({required this.items, super.key});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Список примеров «сербская фраза - перевод».
class ExampleList extends StatelessWidget {
  const new({required this.examples, super.key});

  final List<Example> examples;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final e in examples)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.sr,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(e.ru, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
      ],
    );
  }
}

/// Таблица форм: тип, единственное число, множественное число.
class FormsTable extends StatelessWidget {
  const new({
    required this.rows,
    super.key,
    this.singularLabel = 'Ед. ч.',
    this.pluralLabel = 'Мн. ч.',
  });

  final List<EndingRow> rows;
  final String singularLabel;
  final String pluralLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        headingRowHeight: 40,
        dataRowMinHeight: 44,
        // Примеры в первой колонке переносятся: высота строки не фиксирована.
        dataRowMaxHeight: double.infinity,
        columns: [
          DataColumn(label: Text('Тип', style: labelStyle)),
          DataColumn(label: Text(singularLabel, style: labelStyle)),
          DataColumn(label: Text(pluralLabel, style: labelStyle)),
        ],
        rows: [
          for (final row in rows)
            DataRow(
              cells: [
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(row.group, style: theme.textTheme.bodyMedium),
                        if (row.example != null)
                          Text(
                            row.example!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                DataCell(Text(row.singular)),
                DataCell(Text(row.plural)),
              ],
            ),
        ],
      ),
    );
  }
}

/// Окончания падежа по родам: у каждого рода - единственное и
/// множественное число рядом, под окончанием - формы слов из словаря
/// с подсвеченной изменившейся частью.
class EndingsTable extends StatelessWidget {
  const new({required this.rows, required this.gramCase, super.key});

  final List<EndingRow> rows;
  final GramCase gramCase;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final row in rows) ...[
          if (row != rows.first) const Divider(height: 24),
          _EndingBlock(row: row, gramCase: gramCase),
        ],
      ],
    );
  }
}

/// Один род: заголовок со словами-примерами и две колонки форм.
class _EndingBlock extends StatelessWidget {
  const new({required this.row, required this.gramCase});

  final EndingRow row;
  final GramCase gramCase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final words = [
      for (final lemma in row.lemmas)
        if (row.adjective == null)
          '$lemma - ${kNounsByLemma[lemma]!.ru}'
        else
          '${row.adjective} $lemma',
    ];

    Widget column(String ending, GramNumber number) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Подпись в каждом блоке: общая шапка у нижних родов уже далеко.
          Text(
            number.ru,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            ending,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          for (final sample in endingSamples(row, gramCase, number))
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: _SampleText(sample: sample),
            ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(row.group, style: theme.textTheme.titleSmall),
        if (words.isNotEmpty)
          Text(words.join(', '), style: theme.textTheme.bodySmall),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            column(row.singular, GramNumber.singular),
            const SizedBox(width: 16),
            column(row.plural, GramNumber.plural),
          ],
        ),
      ],
    );
  }
}

/// Форма слова: изменившаяся часть выделена цветом и жирным.
class _SampleText extends StatelessWidget {
  const new({required this.sample});

  final FormSample sample;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.textTheme.bodyLarge;

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          for (final segment in sample.segments)
            TextSpan(
              text: segment.text,
              style: segment.changed
                  ? TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}

/// Раздел теории целиком: текст, правила, таблица и примеры.
class TopicSectionView extends StatelessWidget {
  const new({required this.section, super.key});

  final TopicSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      title: section.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.body, style: theme.textTheme.bodyMedium),
          if (section.bullets.isNotEmpty) ...[
            const SizedBox(height: 12),
            BulletList(items: section.bullets),
          ],
          if (section.table.isNotEmpty) ...[
            const SizedBox(height: 8),
            FormsTable(rows: section.table),
          ],
          if (section.examples.isNotEmpty) ...[
            const SizedBox(height: 12),
            ExampleList(examples: section.examples),
          ],
        ],
      ),
    );
  }
}
