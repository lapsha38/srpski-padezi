import 'package:srpski_padezi/data/adjectives.dart';
import 'package:srpski_padezi/data/nouns.dart';
import 'package:srpski_padezi/models/models.dart';

/// Кусок формы: совпадает со словарной формой или изменился.
typedef FormSegment = ({String text, bool changed});

/// Пример к строке таблицы окончаний: словарная форма и форма падежа.
class FormSample {
  const new({required this.base, required this.form});

  /// Словарная форма: «grad» или «lep grad».
  final String base;
  final String form;

  /// Форма, разбитая для подсветки: у каждого слова отмечено то, что
  /// изменилось по сравнению со словарной формой, - окончание вместе
  /// с чередованием (majka → majci) и беглым «а» (student → studenata).
  List<FormSegment> get segments {
    final words = form.split(' ');
    final baseWords = base.split(' ');
    if (words.length != baseWords.length) return [(text: form, changed: false)];

    return [
      for (var i = 0; i < words.length; i++) ...[
        if (i > 0) (text: ' ', changed: false),
        ..._splitWord(baseWords[i], words[i]),
      ],
    ];
  }

  static List<FormSegment> _splitWord(String base, String word) {
    var common = 0;
    while (common < base.length &&
        common < word.length &&
        base[common] == word[common]) {
      common++;
    }
    return [
      if (common > 0) (text: word.substring(0, common), changed: false),
      if (common < word.length) (text: word.substring(common), changed: true),
    ];
  }
}

/// Формы слов строки в заданном падеже и числе. Слова без такой формы
/// (нет множественного числа) пропускаются.
List<FormSample> endingSamples(
  EndingRow row,
  GramCase gramCase,
  GramNumber number,
) {
  final adjective = row.adjective == null
      ? null
      : kAdjectives.firstWhere((a) => a.lemma == row.adjective);

  final samples = <FormSample>[];
  for (final lemma in row.lemmas) {
    final noun = kNounsByLemma[lemma]!;
    if (adjective == null) {
      final form = noun.form(gramCase, number);
      if (form != null) samples.add(FormSample(base: lemma, form: form));
    } else {
      final form = phraseForm(adjective, noun, gramCase, number);
      if (form != null) {
        samples.add(FormSample(base: '${adjective.lemma} $lemma', form: form));
      }
    }
  }
  return samples;
}
