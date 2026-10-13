import 'package:flutter/material.dart';
import 'package:srpski_padezi/data/cases.dart';
import 'package:srpski_padezi/data/texts.dart';
import 'package:srpski_padezi/logic/ending_samples.dart';
import 'package:srpski_padezi/logic/gap_check.dart';
import 'package:srpski_padezi/models/models.dart';
import 'package:srpski_padezi/services/progress_service.dart';
import 'package:srpski_padezi/theme.dart';
import 'package:srpski_padezi/widgets/rule_sheet.dart';

/// Ключ, под которым хранится лучший результат текста.
String gapTextProgressKey(GapText text) => 'text_${text.id}';

/// Список текстов с пропусками.
class GapTextListScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = ProgressService.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Текст с пропусками')),
      body: AnimatedBuilder(
        animation: progress,
        builder: (context, _) => ContentWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Text(
                'Вставьте слова в нужном падеже. В скобках - словарная форма '
                'и число, которое нужно поставить. Падеж определите сами '
                'по смыслу и предлогам.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              for (final text in kGapTexts)
                Card(
                  child: ListTile(
                    title: Text(text.title),
                    subtitle: Text(
                      '${text.titleRu} · ${text.gaps.length} пропусков\n'
                      '${_casesOf(text)}',
                    ),
                    isThreeLine: true,
                    trailing: _BestScore(
                      progress.bestScore(gapTextProgressKey(text)),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => GapTextScreen(text: text),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Падежи текста в порядке изучения: видно, что уже по силам.
  static String _casesOf(GapText text) {
    final cases = {for (final gap in text.gaps) gap.gramCase};
    return [
      for (final c in kCaseLearningOrder)
        if (cases.contains(c)) c.sr,
    ].join(', ');
  }
}

class _BestScore extends StatelessWidget {
  const new(this.score);

  final int score;

  @override
  Widget build(BuildContext context) {
    if (score == 0) return const Icon(Icons.chevron_right);
    final passed = score >= ProgressService.passingScore;
    return Text(
      '$score%',
      style: Theme.of(context).textTheme.labelLarge
          ?.copyWith(color: passed ? Colors.green.shade600 : null),
    );
  }
}

/// Один текст: поля в пропусках, проверка и разбор ошибок.
class GapTextScreen extends StatefulWidget {
  const new({required this.text, super.key});

  final GapText text;

  @override
  State<GapTextScreen> createState() => _GapTextScreenState();
}

class _GapTextScreenState extends State<GapTextScreen> {
  late final List<TextEditingController> _controllers = [
    for (final _ in widget.text.gaps) TextEditingController(),
  ];
  late final List<FocusNode> _focusNodes = [
    for (final _ in widget.text.gaps) FocusNode(),
  ];

  /// Поле, в которое вставляются буквы с диакритикой.
  int _active = 0;

  /// Результаты проверки; null - текст ещё не проверен.
  List<GapResult>? _results;

  @override
  void initState() {
    super.initState();
    for (final (i, node) in _focusNodes.indexed) {
      node.addListener(() {
        if (node.hasFocus) _active = i;
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _insert(String letter) {
    final controller = _controllers[_active];
    final value = controller.value;
    final selection = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);
    controller.value = value.replaced(selection, letter);
    _focusNodes[_active].requestFocus();
  }

  Future<void> _check() async {
    FocusScope.of(context).unfocus();
    final results = [
      for (final (i, gap) in widget.text.gaps.indexed)
        checkGap(gap, _controllers[i].text),
    ];
    setState(() => _results = results);

    final correct = results.where((r) => r.isCorrect).length;
    final progress = ProgressService.instance;
    await progress.recordAnswers(total: results.length, correct: correct);
    await progress.recordResult(
      gapTextProgressKey(widget.text),
      (correct * 100 / results.length).round(),
    );
  }

  void _retry() {
    setState(() {
      _results = null;
      for (final c in _controllers) {
        c.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = widget.text;
    final results = _results;

    return Scaffold(
      appBar: AppBar(title: Text(text.title)),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(text.titleRu, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _GapTextBody(
                  text: text,
                  controllers: _controllers,
                  focusNodes: _focusNodes,
                  results: results,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (results == null) ...[
              _DiacriticsBar(onLetter: _insert),
              const SizedBox(height: 12),
              FilledButton(onPressed: _check, child: const Text('Проверить')),
            ] else ...[
              _Summary(results: results, onRetry: _retry),
              const SizedBox(height: 12),
              _Translation(text: text.translation),
              for (final (i, r) in results.indexed)
                if (!r.isCorrect || r.message != null)
                  _MistakeCard(number: i + 1, result: r),
            ],
          ],
        ),
      ),
    );
  }
}

/// Текст с полями ввода в пропусках, а после проверки - с ответами.
class _GapTextBody extends StatelessWidget {
  const new({
    required this.text,
    required this.controllers,
    required this.focusNodes,
    required this.results,
  });

  final GapText text;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final List<GapResult>? results;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pieces = text.pieces;
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Text.rich(
      TextSpan(
        style: theme.textTheme.bodyLarge?.copyWith(height: 2.2),
        children: [
          for (final (i, gap) in text.gaps.indexed) ...[
            TextSpan(text: pieces[i]),
            if (results case final results?)
              ..._answerSpans(context, i + 1, results[i])
            else
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: _GapField(
                  controller: controllers[i],
                  focusNode: focusNodes[i],
                  last: i == text.gaps.length - 1,
                ),
              ),
            TextSpan(
              text: ' (${gap.lemma}, ${gap.number.ruShort})',
              style: muted,
            ),
          ],
          TextSpan(text: pieces.last),
        ],
      ),
    );
  }

  /// Ответ после проверки: верный - зелёным, неверный - зачёркнут, рядом
  /// правильная форма и номер разбора.
  List<InlineSpan> _answerSpans(
    BuildContext context,
    int number,
    GapResult result,
  ) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final green = dark ? Colors.green.shade400 : Colors.green.shade700;
    final bold = TextStyle(fontWeight: FontWeight.w700, color: green);

    if (result.isCorrect) {
      return [TextSpan(text: result.expected, style: bold)];
    }
    return [
      if (result.given.isNotEmpty) ...[
        TextSpan(
          text: result.given,
          style: TextStyle(
            color: theme.colorScheme.error,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        const TextSpan(text: ' '),
      ],
      TextSpan(text: result.expected, style: bold),
      TextSpan(
        text: ' [$number]',
        style: TextStyle(
          color: theme.colorScheme.error,
          fontSize: theme.textTheme.labelSmall?.fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    ];
  }
}

class _GapField extends StatelessWidget {
  const new({
    required this.controller,
    required this.focusNode,
    required this.last,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool last;

  @override
  Widget build(BuildContext context) {
    // Ширина одна на все пропуски: длина поля не должна подсказывать ответ.
    return SizedBox(
      width: 120,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autocorrect: false,
        enableSuggestions: false,
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

/// Буквы с диакритикой: на многих клавиатурах их нет.
class _DiacriticsBar extends StatelessWidget {
  const new({required this.onLetter});

  final ValueChanged<String> onLetter;

  static const List<String> _letters = ['č', 'ć', 'đ', 'š', 'ž'];

  @override
  Widget build(BuildContext context) {
    // Нажатие на кнопку не считается касанием вне поля, а сами кнопки
    // не забирают фокус: буква уходит туда, где стоит курсор.
    return TextFieldTapRegion(
      child: ExcludeFocus(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final letter in _letters)
              OutlinedButton(
                onPressed: () => onLetter(letter),
                child: Text(letter),
              ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const new({required this.results, required this.onRetry});

  final List<GapResult> results;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final correct = results.where((r) => r.isCorrect).length;
    final percent = (correct * 100 / results.length).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Верно $correct из ${results.length} ($percent%)',
              style: theme.textTheme.titleMedium,
            ),
            if (correct < results.length) ...[
              const SizedBox(height: 4),
              Text(
                'Ниже - разбор каждой ошибки по номерам в тексте.',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Ещё раз'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('К списку текстов'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Translation extends StatelessWidget {
  const new({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: const Text('Перевод'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [Text(text, style: Theme.of(context).textTheme.bodyMedium)],
      ),
    );
  }
}

/// Разбор одного пропуска: что ввели, что нужно, в чём ошибка и почему
/// здесь этот падеж.
class _MistakeCard extends StatelessWidget {
  const new({required this.number, required this.result});

  final int number;
  final GapResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gap = result.gap;
    final error = !result.isCorrect;
    final accent = error ? theme.colorScheme.error : Colors.orange.shade700;

    // Нужная форма с подсветкой того, чем она отличается от введённой.
    final expected = FormSample(
      base: result.given.toLowerCase(),
      form: result.expected,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  error ? Icons.cancel : Icons.info_outline,
                  color: accent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${error ? '[$number] ' : ''}${gap.lemma}, '
                    '${gap.number.ruShort} → ${gap.gramCase.sr}',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                style: theme.textTheme.bodyLarge,
                children: [
                  if (result.given.isNotEmpty) ...[
                    TextSpan(
                      text: result.given,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const TextSpan(text: '  →  '),
                  ],
                  for (final segment in expected.segments)
                    TextSpan(
                      text: segment.text,
                      style: segment.changed && result.given.isNotEmpty
                          ? TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            )
                          : const TextStyle(fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
            if (result.message case final message?) ...[
              const SizedBox(height: 6),
              Text(message, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 4),
            Text(gap.hint, style: theme.textTheme.bodySmall),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () =>
                    showRuleSheet(context, RuleRef(gramCase: gap.gramCase)),
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
