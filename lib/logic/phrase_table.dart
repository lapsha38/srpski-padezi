import 'dart:math';

import 'package:srpski_padezi/data/adjectives.dart';
import 'package:srpski_padezi/data/nouns.dart';
import 'package:srpski_padezi/logic/phrase_forms.dart';
import 'package:srpski_padezi/models/models.dart';

/// Одна строка таблицы: падеж, верная форма и варианты для выбора.
class PhraseTableRow {
  const PhraseTableRow({
    required this.gramCase,
    required this.answer,
    required this.options,
  });

  final GramCase gramCase;
  final String answer;
  final List<String> options;
}

/// Словосочетание, разложенное по всем семи падежам.
///
/// В отличие от обычной тренировки здесь всё задание про одну пару слов:
/// видно, как одно и то же словосочетание меняется от падежа к падежу.
class PhraseTable {
  const PhraseTable({
    required this.adjective,
    required this.noun,
    required this.number,
    required this.rows,
  });

  final Adjective adjective;
  final Noun noun;
  final GramNumber number;

  /// Семь строк в порядке [GramCase.values].
  final List<PhraseTableRow> rows;

  /// Заголовок задания: обе словарные формы через плюс.
  ///
  /// Готовое словосочетание тут показывать нельзя: в единственном числе
  /// оно совпало бы с ответом для номинатива. Словарная форма
  /// прилагательного - неопределённого вида (lep, а не lepi), поэтому
  /// заголовок не подсказывает ни одну строку таблицы.
  String get headword => '${adjective.lemma} + ${noun.lemma}';

  /// Перевод пары на русский.
  String get ru => '${adjective.ru} + ${noun.ru}';

  PhraseTableRow rowFor(GramCase gramCase) =>
      rows.firstWhere((r) => r.gramCase == gramCase);
}

/// Собирает таблицу для случайного словосочетания.
class PhraseTableGenerator {
  PhraseTableGenerator([Random? random]) : _random = random ?? Random();

  final Random _random;

  /// Ключ, под которым хранится лучший результат режима.
  static const String progressKey = 'phrase_table';

  PhraseTable build() {
    final noun = kNouns[_random.nextInt(kNouns.length)];
    final adjective =
        kCommonAdjectives[_random.nextInt(
          kCommonAdjectives.length,
        )];
    // Множественное число берём только у слов, которые его имеют.
    final number = noun.hasPlural && _random.nextBool()
        ? GramNumber.plural
        : GramNumber.singular;

    return PhraseTable(
      adjective: adjective,
      noun: noun,
      number: number,
      rows: [
        for (final gramCase in GramCase.values)
          _row(
            adjective: adjective,
            noun: noun,
            gramCase: gramCase,
            number: number,
          ),
      ],
    );
  }

  PhraseTableRow _row({
    required Adjective adjective,
    required Noun noun,
    required GramCase gramCase,
    required GramNumber number,
  }) {
    final answer = phraseForm(adjective, noun, gramCase, number)!;
    return PhraseTableRow(
      gramCase: gramCase,
      answer: answer,
      options: phraseOptions(
        adjective: adjective,
        noun: noun,
        gramCase: gramCase,
        number: number,
        answer: answer,
        random: _random,
      ),
    );
  }
}
