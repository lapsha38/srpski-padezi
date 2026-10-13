import 'dart:math';

import 'package:srpski_padezi/data/adjectives.dart';
import 'package:srpski_padezi/data/cases.dart';
import 'package:srpski_padezi/data/nouns.dart';
import 'package:srpski_padezi/logic/phrase_forms.dart';
import 'package:srpski_padezi/models/models.dart';

/// Одна строка таблицы: падеж, верная форма и варианты для выбора -
/// отдельно для прилагательного и для существительного.
class PhraseTableRow {
  const new({
    required this.gramCase,
    required this.answer,
    required this.parts,
  });

  final GramCase gramCase;
  final String answer;
  final List<AnswerPart> parts;
}

/// Словосочетание, разложенное по всем семи падежам: видно всё склонение
/// целиком, а не по одному вопросу.
class PhraseTable {
  const new({
    required this.adjective,
    required this.noun,
    required this.number,
    required this.rows,
  });

  final Adjective adjective;
  final Noun noun;
  final GramNumber number;

  /// Семь строк в порядке [kCaseLearningOrder].
  final List<PhraseTableRow> rows;

  /// Обе словарные формы через плюс: готовое словосочетание совпало бы
  /// с ответом для номинатива.
  String get headword => '${adjective.lemma} + ${noun.lemma}';

  /// Перевод пары на русский.
  String get ru => '${adjective.ru} + ${noun.ru}';

  PhraseTableRow rowFor(GramCase gramCase) =>
      rows.firstWhere((r) => r.gramCase == gramCase);
}

/// Собирает таблицу для случайного словосочетания.
class PhraseTableGenerator {
  new([Random? random]) : _random = random ?? Random();

  final Random _random;

  /// Ключ, под которым хранится лучший результат режима.
  static const String progressKey = 'phrase_table';

  PhraseTable build() {
    final noun = kNouns[_random.nextInt(kNouns.length)];
    final adjective =
        kCommonAdjectives[_random.nextInt(kCommonAdjectives.length)];
    // Множественное число берём только у слов, которые его имеют.
    final number = noun.hasPlural && _random.nextBool()
        ? GramNumber.plural
        : GramNumber.singular;

    return PhraseTable(
      adjective: adjective,
      noun: noun,
      number: number,
      rows: [
        for (final gramCase in kCaseLearningOrder)
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
    return PhraseTableRow(
      gramCase: gramCase,
      answer: phraseForm(adjective, noun, gramCase, number)!,
      parts: phraseParts(
        adjective: adjective,
        noun: noun,
        gramCase: gramCase,
        number: number,
        random: _random,
      ),
    );
  }
}
