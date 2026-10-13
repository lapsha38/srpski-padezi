import 'package:flutter/material.dart';
import 'package:srpski_padezi/data/adjectives.dart';
import 'package:srpski_padezi/data/cases.dart';
import 'package:srpski_padezi/models/models.dart';
import 'package:srpski_padezi/widgets/section_card.dart';
import 'package:srpski_padezi/widgets/selectable_on_web.dart';

/// Показывает правило, по которому строится ответ, не прерывая тренировку.
Future<void> showRuleSheet(BuildContext context, RuleRef rule) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, controller) => SelectableOnWeb(
        child: _RuleContent(rule: rule, controller: controller),
      ),
    ),
  );
}

class _RuleContent extends StatelessWidget {
  const new({required this.rule, required this.controller});

  final RuleRef rule;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gramCase = rule.gramCase;
    final info = gramCase == null ? null : caseInfoFor(gramCase);

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Text(
          info != null
              ? '${info.gramCase.sr} - ${info.gramCase.ru} падеж'
              : rule.title ?? 'Правило',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (info != null) ...[
          Text(
            'Вопросы: ${info.gramCase.questions}',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(info.tagline, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          _Block(
            title: 'Когда употребляется',
            children: [for (final m in info.meanings) _Bullet(m)],
          ),
          if (info.prepositions.isNotEmpty)
            _Block(
              title: 'Предлоги',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in info.prepositions) Chip(label: Text(p)),
                  ],
                ),
              ],
            ),
          _Block(
            title: 'Окончания существительных',
            children: [
              EndingsTable(rows: info.endings, gramCase: info.gramCase),
            ],
          ),
          _Block(
            title: 'Окончания прилагательных',
            children: [
              EndingsTable(
                rows: adjectiveEndingRows(info.gramCase),
                gramCase: info.gramCase,
              ),
            ],
          ),
          _Block(
            title: 'Типичные ошибки',
            children: [for (final p in info.pitfalls) _Bullet(p)],
          ),
        ],
        if (rule.body != null) ...[
          Text(rule.body!, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
        ],
        if (rule.bullets.isNotEmpty)
          for (final b in rule.bullets) _Bullet(b),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const new({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
