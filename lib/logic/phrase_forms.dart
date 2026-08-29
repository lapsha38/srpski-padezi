import 'dart:math';

import 'package:srpski_padezi/data/adjectives.dart';
import 'package:srpski_padezi/models/models.dart';

/// Четыре варианта ответа: верный плюс три по порядку реальных ошибок -
/// другой падеж, рассогласованная пара, другое число.
List<String> phraseOptions({
  required Adjective adjective,
  required Noun noun,
  required GramCase gramCase,
  required GramNumber number,
  required String answer,
  required Random random,
}) {
  final other = number == GramNumber.singular
      ? GramNumber.plural
      : GramNumber.singular;

  final candidates = <String>[];
  for (final c in GramCase.values) {
    if (c == gramCase) continue;
    final same = phraseForm(adjective, noun, c, number);
    if (same != null) candidates.add(same);
    final wrongAdjective = adjectiveForm(
      adjective,
      gender: noun.genderIn(number),
      gramCase: c,
      number: number,
      animate: noun.animate,
    );
    candidates.add('$wrongAdjective ${noun.form(gramCase, number)}');
  }
  if (noun.hasPlural) {
    for (final c in GramCase.values) {
      final otherNumber = phraseForm(adjective, noun, c, other);
      if (otherNumber != null) candidates.add(otherNumber);
    }
  }

  final options = <String>{answer};
  candidates.shuffle(random);
  for (final candidate in candidates) {
    if (options.length >= 4) break;
    options.add(candidate);
  }
  return options.toList()..shuffle(random);
}
