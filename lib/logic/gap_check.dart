import 'package:srpski_padezi/data/nouns.dart';
import 'package:srpski_padezi/data/texts.dart';
import 'package:srpski_padezi/models/models.dart';

/// Чем оказался ответ в пропуске.
enum GapVerdict {
  correct,

  /// Форма верная, но набрана без диакритики (kuci вместо kući):
  /// засчитывается, но с замечанием.
  diacritics,

  /// Это форма того же слова, но другого падежа.
  wrongCase,

  /// Это форма другого числа.
  wrongNumber,

  /// Такой формы у слова нет: ошибка в окончании или в основе.
  wrongForm,

  empty,
}

/// Проверенный пропуск: что ввели, что нужно и в чём ошибка.
class GapResult {
  const new({
    required this.gap,
    required this.given,
    required this.expected,
    required this.verdict,
    required this.message,
  });

  final TextGap gap;
  final String given;
  final String expected;
  final GapVerdict verdict;

  /// Что не так с ответом; null, если ответ верный.
  final String? message;

  bool get isCorrect =>
      verdict == GapVerdict.correct || verdict == GapVerdict.diacritics;
}

/// Правильная форма для пропуска.
String gapAnswer(TextGap gap) =>
    kNounsByLemma[gap.lemma]!.form(gap.gramCase, gap.number)!;

/// Проверяет ответ и объясняет ошибку: по введённой форме видно, какой
/// падеж или какое число на самом деле выбраны.
GapResult checkGap(TextGap gap, String input) {
  final noun = kNounsByLemma[gap.lemma]!;
  final expected = gapAnswer(gap);
  final given = _normalize(input);

  GapResult result(GapVerdict verdict, [String? message]) => GapResult(
    gap: gap,
    given: input.trim(),
    expected: expected,
    verdict: verdict,
    message: message,
  );

  if (given.isEmpty) return result(GapVerdict.empty, 'Пропуск не заполнен.');
  if (given == expected) return result(GapVerdict.correct);

  final plain = _stripDiacritics(given);
  if (plain == _stripDiacritics(expected)) {
    return result(
      GapVerdict.diacritics,
      'Форма верная, но без диакритики: пишется $expected.',
    );
  }

  final needed = '${gap.gramCase.ru} падеж, ${gap.number.ru}';

  // Падежи, в которых у слова есть введённая форма, - отдельно по числам.
  List<GramCase> casesOf(GramNumber number) => [
    for (final c in GramCase.values)
      if (noun.form(c, number) case final form?)
        if (_stripDiacritics(form) == plain) c,
  ];

  final sameNumber = casesOf(gap.number);
  if (sameNumber.isNotEmpty) {
    return result(
      GapVerdict.wrongCase,
      'Это ${_casesRu(sameNumber)} (${gap.number.ruShort}), '
      'а здесь нужен $needed.',
    );
  }

  final other = gap.number == GramNumber.singular
      ? GramNumber.plural
      : GramNumber.singular;
  final otherNumber = casesOf(other);
  if (otherNumber.isNotEmpty) {
    return result(
      GapVerdict.wrongNumber,
      otherNumber.contains(gap.gramCase)
          ? 'Падеж верный, но это ${other.ru}, а нужно ${gap.number.ru}.'
          : 'Это ${_casesRu(otherNumber)}, ${other.ru}; нужен $needed.',
    );
  }

  return result(
    GapVerdict.wrongForm,
    'Такой формы у слова ${noun.lemma} нет. Нужен $needed: $expected.',
  );
}

/// «родительный падеж» или «родительный или дательный падеж».
String _casesRu(List<GramCase> cases) {
  final names = cases.map((c) => c.ru).toList();
  final joined = names.length == 1
      ? names.single
      : '${names.sublist(0, names.length - 1).join(', ')} '
            'или ${names.last}';
  return '$joined падеж';
}

String _normalize(String input) =>
    input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

/// Латиница без диакритики: так набирают на клавиатуре без сербской
/// раскладки (đ часто пишут как dj).
String _stripDiacritics(String s) => s
    .replaceAll('đ', 'dj')
    .replaceAll(RegExp('[čć]'), 'c')
    .replaceAll('š', 's')
    .replaceAll('ž', 'z');
