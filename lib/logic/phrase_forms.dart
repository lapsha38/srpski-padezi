import 'dart:math';

import 'package:srpski_padezi/data/adjectives.dart';
import 'package:srpski_padezi/data/nouns.dart';
import 'package:srpski_padezi/models/models.dart';

/// Словосочетание выбирается по частям: сначала прилагательное, потом
/// существительное. Так тренируются окончания обоих слов, а не узнавание
/// готовой пары.
List<AnswerPart> phraseParts({
  required Adjective adjective,
  required Noun noun,
  required GramCase gramCase,
  required GramNumber number,
  required Random random,
}) {
  final nounAnswer = noun.form(gramCase, number)!;
  return [
    AnswerPart(
      label: 'Прилагательное',
      answer: _adjectiveIn(adjective, noun, gramCase, number),
      options: adjectiveOptions(
        adjective: adjective,
        noun: noun,
        gramCase: gramCase,
        number: number,
        random: random,
      ),
    ),
    AnswerPart(
      label: 'Существительное',
      answer: nounAnswer,
      options: nounOptions(noun, number, nounAnswer, random),
    ),
  ];
}

String _adjectiveIn(
  Adjective adjective,
  Noun noun,
  GramCase gramCase,
  GramNumber number, {
  Gender? gender,
}) => adjectiveForm(
  adjective,
  gender: gender ?? noun.genderIn(number),
  gramCase: gramCase,
  number: number,
  animate: noun.animate,
);

/// Четыре формы прилагательного: верная плюс формы других падежей того же
/// рода и числа - их и путают; затем другое число и другой род.
List<String> adjectiveOptions({
  required Adjective adjective,
  required Noun noun,
  required GramCase gramCase,
  required GramNumber number,
  required Random random,
}) {
  final other = number == GramNumber.singular
      ? GramNumber.plural
      : GramNumber.singular;
  final options = <String>{_adjectiveIn(adjective, noun, gramCase, number)};

  void addFrom(Iterable<String> source) {
    final candidates = source.where((f) => !options.contains(f)).toList()
      ..shuffle(random);
    for (final c in candidates) {
      if (options.length >= 4) return;
      options.add(c);
    }
  }

  addFrom([
    for (final c in GramCase.values) _adjectiveIn(adjective, noun, c, number),
  ]);
  addFrom([
    for (final c in GramCase.values)
      _adjectiveIn(adjective, noun, c, other, gender: noun.genderIn(number)),
  ]);
  addFrom([
    for (final g in Gender.values)
      for (final c in GramCase.values)
        _adjectiveIn(adjective, noun, c, number, gender: g),
  ]);

  return options.toList()..shuffle(random);
}

/// Четыре формы существительного: правильная плюс три правдоподобных.
///
/// Сначала берутся другие падежные формы того же слова в том же числе -
/// именно их и путают на практике; затем формы другого числа; в последнюю
/// очередь - искусственные формы с чужими окончаниями.
List<String> nounOptions(
  Noun noun,
  GramNumber number,
  String answer,
  Random random,
) {
  final options = <String>{answer};
  final other = number == GramNumber.singular
      ? GramNumber.plural
      : GramNumber.singular;

  void addFrom(Iterable<String> source) {
    final candidates = source.where((f) => !options.contains(f)).toList()
      ..shuffle(random);
    for (final c in candidates) {
      if (options.length >= 4) return;
      options.add(c);
    }
  }

  addFrom(noun.forms(number));
  if (options.length < 4) addFrom(noun.forms(other));
  if (options.length < 4) addFrom(_syntheticForms(noun));
  if (options.length < 4) {
    // Крайний случай: формы других слов того же склонения.
    addFrom(
      kNouns
          .where((n) => n.declension == noun.declension && n != noun)
          .expand((n) => n.forms(number)),
    );
  }

  return options.toList()..shuffle(random);
}

/// Искусственные формы: основа слова с чужими окончаниями.
///
/// Такие варианты имитируют типичную ошибку - окончание из другого
/// склонения, - поэтому выглядят правдоподобно.
List<String> _syntheticForms(Noun noun) {
  final stem = switch (noun.declension) {
    Declension.feminineA ||
    Declension.neuter => noun.lemma.substring(0, noun.lemma.length - 1),
    _ => noun.lemma,
  };
  const endings = [
    'a',
    'e',
    'i',
    'u',
    'o',
    'om',
    'em',
    'ima',
    'ama',
    'ovi',
    'ove',
    'ova',
  ];
  final real = {...noun.sg, ...?noun.pl};
  return [
    for (final e in endings)
      if (!real.contains('$stem$e')) '$stem$e',
  ];
}
