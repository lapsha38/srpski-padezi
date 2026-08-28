import 'dart:math';

import 'package:srpski_padezi/data/nouns.dart';
import 'package:srpski_padezi/data/numerals.dart';
import 'package:srpski_padezi/logic/quiz_engine.dart';
import 'package:srpski_padezi/models/models.dart';

/// Тип тренировки по числительным.
enum NumeralQuizKind {
  /// Как называется число: 17 → sedamnaest.
  words,

  /// Числительное плюс существительное: 5 + grad → pet gradova.
  agreement,

  /// Порядковые числительные: 5 → peti.
  ordinal,
}

extension NumeralQuizKindX on NumeralQuizKind {
  String get title => switch (this) {
    NumeralQuizKind.words => 'Числа словами',
    NumeralQuizKind.agreement => 'Числительное + существительное',
    NumeralQuizKind.ordinal => 'Порядковые числительные',
  };

  String get description => switch (this) {
    NumeralQuizKind.words =>
      'Узнавать числа от 1 до 1000 в обе стороны: цифра ↔ слово.',
    NumeralQuizKind.agreement =>
      'Самое важное: какой падеж существительного нужен после числа.',
    NumeralQuizKind.ordinal =>
      'Первый, второй, третий… и как не спутать их с количественными.',
  };

  String get progressKey => 'numerals_$name';
}

/// Числа, на которых тренируем согласование: важны все три случая
/// (…1, …2-4, 5 и больше), включая ловушку 11-14.
const List<int> _agreementNumbers = [
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  15,
  20,
  21,
  22,
  23,
  24,
  25,
  31,
  42,
  100,
  101,
  102,
  105,
];

/// Генератор заданий по числительным.
class NumeralQuizGenerator {
  NumeralQuizGenerator([Random? random]) : _random = random ?? Random();

  final Random _random;

  List<Question> generate(NumeralQuizKind kind, {int count = 12}) {
    final questions = switch (kind) {
      NumeralQuizKind.words => _wordQuestions(),
      NumeralQuizKind.agreement => _agreementQuestions(),
      NumeralQuizKind.ordinal => _ordinalQuestions(),
    };
    return (questions..shuffle(_random)).take(count).toList();
  }

  /// Правило, которое можно открыть прямо во время тренировки.
  RuleRef ruleFor(NumeralQuizKind kind) {
    final sections = switch (kind) {
      NumeralQuizKind.words => [kNumeralTopics.last],
      NumeralQuizKind.agreement => [kNumeralTopics[0], kNumeralTopics[1]],
      NumeralQuizKind.ordinal => [kNumeralTopics[2]],
    };
    return RuleRef(
      title: sections.first.title,
      body: sections.first.body,
      bullets: [for (final s in sections) ...s.bullets],
    );
  }

  // ── Числа словами ───────────────────────────────────────────────────────

  List<Question> _wordQuestions() {
    final result = <Question>[];
    for (final numeral in kNumerals) {
      final distractors = _otherCardinals(numeral);
      // Половина заданий «цифра → слово», половина - наоборот.
      result.add(
        Question(
          prompt: 'Как это число называется по-сербски?',
          subject: '${numeral.value}',
          answer: numeral.cardinal,
          options: _shuffled([numeral.cardinal, ...distractors.take(3)]),
          tags: const ['Числительные', 'количественные'],
          hint: 'Запись словами: ${spellNumber(numeral.value)}.',
          summary: '${numeral.value} → ${numeral.cardinal}',
          rule: ruleFor(NumeralQuizKind.words),
        ),
      );
      final numberOptions = <String>{'${numeral.value}'};
      for (final word in distractors) {
        if (numberOptions.length >= 4) break;
        numberOptions.add(
          '${kNumerals.firstWhere((n) => n.cardinal == word).value}',
        );
      }
      result.add(
        Question(
          prompt: 'Какое это число?',
          subject: numeral.cardinal,
          answer: '${numeral.value}',
          options: numberOptions.toList()..shuffle(_random),
          tags: const ['Числительные', 'количественные'],
          summary: '${numeral.cardinal} → ${numeral.value}',
          rule: ruleFor(NumeralQuizKind.words),
        ),
      );
    }
    return result;
  }

  /// Похожие числительные: сначала однокоренные (7 - 17 - 70), потом любые.
  List<String> _otherCardinals(Numeral numeral) {
    bool similar(Numeral other) {
      if (other.value == numeral.value) return false;
      final a = numeral.value;
      final b = other.value;
      return a % 10 == b % 10 || a % 10 == b ~/ 10 || b % 10 == a ~/ 10;
    }

    final close = kNumerals.where(similar).map((n) => n.cardinal).toList()
      ..shuffle(_random);
    final rest =
        kNumerals
            .where(
              (n) => n.value != numeral.value && !close.contains(n.cardinal),
            )
            .map((n) => n.cardinal)
            .toList()
          ..shuffle(_random);
    return [...close, ...rest];
  }

  // ── Числительное плюс существительное ───────────────────────────────────

  List<Question> _agreementQuestions() {
    final result = <Question>[];
    final nouns = kNouns.where((n) => n.hasPlural).toList();

    for (final number in _agreementNumbers) {
      for (final noun in nouns) {
        final agreement = agreementFor(number);
        final nounForm = noun.form(agreement.gramCase, agreement.number);
        if (nounForm == null) continue;

        final numeralWord = _spellFor(number, noun.gender);
        final answer = '$numeralWord $nounForm';

        final options = <String>{answer};
        // Неверная родовая форма числительного - ошибка только у 1 и 2.
        final wrongNumeral = _wrongGenderForm(number, noun.gender);
        if (wrongNumeral != null) options.add('$wrongNumeral $nounForm');
        // Неверные падежные формы существительного.
        for (final form in _wrongNounForms(noun, agreement)) {
          if (options.length >= 4) break;
          options.add('$numeralWord $form');
        }
        if (options.length < 4) continue;

        result.add(
          Question(
            prompt: 'Как правильно сказать?',
            subject: '$number × ${noun.lemma} (${noun.ru})',
            subtitle: noun.gender.ru,
            answer: answer,
            options: options.toList()..shuffle(_random),
            tags: const ['Числительные', 'согласование'],
            hint:
                'После числа $number существительное стоит '
                'в ${agreement.ru}.',
            summary: '$number + ${noun.lemma} → $answer',
            rule: ruleFor(NumeralQuizKind.agreement),
          ),
        );
      }
    }
    return result;
  }

  /// Записывает число словами с учётом рода существительного.
  String _spellFor(int number, Gender gender) {
    final gendered = genderedNumeralForm(number, gender);
    final spelled = spellNumber(number);
    if (gendered == null) return spelled;
    final parts = spelled.split(' ');
    parts[parts.length - 1] = gendered;
    return parts.join(' ');
  }

  /// Родовая форма числительного, которая здесь была бы ошибкой.
  String? _wrongGenderForm(int number, Gender gender) {
    final correct = genderedNumeralForm(number, gender);
    if (correct == null) return null;
    final wrongGender = gender == Gender.feminine
        ? Gender.masculine
        : Gender.feminine;
    final wrong = genderedNumeralForm(number, wrongGender);
    if (wrong == null || wrong == correct) return null;
    final parts = spellNumber(number).split(' ');
    parts[parts.length - 1] = wrong;
    return parts.join(' ');
  }

  /// Формы существительного, которые не подходят под это числительное.
  List<String> _wrongNounForms(Noun noun, NumeralAgreement agreement) {
    final correct = noun.form(agreement.gramCase, agreement.number);
    // Сначала формы, которые действительно путают с нужной, затем - любые
    // остальные формы этого же слова, чтобы вариантов всегда хватило.
    final ordered = <String?>[
      noun.form(GramCase.genitiv, GramNumber.plural),
      noun.form(GramCase.genitiv, GramNumber.singular),
      noun.form(GramCase.nominativ, GramNumber.singular),
      noun.form(GramCase.nominativ, GramNumber.plural),
      noun.form(GramCase.akuzativ, GramNumber.plural),
      noun.form(GramCase.instrumental, GramNumber.plural),
      ...noun.forms(GramNumber.singular),
      ...noun.forms(GramNumber.plural),
    ];
    final result = <String>{};
    for (final c in ordered) {
      if (c != null && c != correct) result.add(c);
    }
    return result.toList();
  }

  // ── Порядковые числительные ─────────────────────────────────────────────

  List<Question> _ordinalQuestions() {
    final result = <Question>[];
    for (final numeral in kNumerals) {
      final others =
          kNumerals
              .where((n) => n.value != numeral.value)
              .map((n) => n.ordinal)
              .toList()
            ..shuffle(_random);
      final options = <String>{
        numeral.ordinal,
        // Типичная ошибка - количественное вместо порядкового.
        if (numeral.cardinal != numeral.ordinal) numeral.cardinal,
      };
      for (final other in others) {
        if (options.length >= 4) break;
        options.add(other);
      }

      result.add(
        Question(
          prompt: 'Какое порядковое числительное соответствует числу?',
          subject: '${numeral.value}-й',
          answer: numeral.ordinal,
          options: options.toList()..shuffle(_random),
          tags: const ['Числительные', 'порядковые'],
          hint:
              'Порядковые склоняются как прилагательные: '
              '${numeral.ordinal} - ${_feminine(numeral.ordinal)}.',
          summary: '${numeral.value}-й → ${numeral.ordinal}',
          rule: ruleFor(NumeralQuizKind.ordinal),
        ),
      );
    }
    return result;
  }

  /// Форма женского рода порядкового числительного для подсказки.
  String _feminine(String ordinal) =>
      '${ordinal.substring(0, ordinal.length - 1)}a';

  List<String> _shuffled(List<String> options) {
    final unique = options.toSet().toList();
    // На всякий случай добираем варианты, если что-то совпало.
    for (final numeral in kNumerals) {
      if (unique.length >= 4) break;
      if (!unique.contains(numeral.cardinal)) unique.add(numeral.cardinal);
    }
    return unique.take(4).toList()..shuffle(_random);
  }
}

/// Готовые тренировки по числительным.
class NumeralQuizPresets {
  static QuizSession forKind(NumeralQuizKind kind, {int count = 12}) =>
      QuizSession(
        title: kind.title,
        progressKey: kind.progressKey,
        build: () => NumeralQuizGenerator().generate(kind, count: count),
      );
}
