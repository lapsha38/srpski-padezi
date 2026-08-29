import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:srpski_padezi/data/adjectives.dart';
import 'package:srpski_padezi/data/cases.dart';
import 'package:srpski_padezi/data/nouns.dart';
import 'package:srpski_padezi/data/numerals.dart';
import 'package:srpski_padezi/logic/numeral_quiz.dart';
import 'package:srpski_padezi/logic/phrase_table.dart';
import 'package:srpski_padezi/logic/quiz_engine.dart';
import 'package:srpski_padezi/models/models.dart';

/// Слова текста в нижнем регистре: латиница с диакритикой и кириллица.
List<String> _words(String text) => text
    .toLowerCase()
    .split(RegExp('[^a-zа-яё0-9čćđšž]+'))
    .where((w) => w.isNotEmpty)
    .toList();

/// Проверяет, что ответ не написан в самой формулировке задания.
///
/// Такое случается там, где форма падежа совпадает со словарной: тогда
/// слово называется только переводом.
void expectAnswerHidden(Question q) {
  final text = _words('${q.prompt} ${q.subject ?? ''} ${q.contextSr ?? ''}');
  final answer = _words(q.answer);
  for (var i = 0; i + answer.length <= text.length; i++) {
    final matches = List.generate(
      answer.length,
      (j) => text[i + j] == answer[j],
    ).every((m) => m);
    expect(
      matches,
      isFalse,
      reason: 'ответ «${q.answer}» виден в задании: ${text.join(' ')}',
    );
  }
}

/// Общая проверка любого набора вопросов.
void expectWellFormed(List<Question> questions, {required String reason}) {
  expect(questions, isNotEmpty, reason: reason);
  for (final q in questions) {
    expect(q.options.length, 4, reason: '$reason: ${q.summary}');
    expect(q.options.toSet().length, 4, reason: '$reason: ${q.summary}');
    expect(q.options, contains(q.answer), reason: '$reason: ${q.summary}');
    expect(q.prompt, isNotEmpty, reason: reason);
    // К любому заданию должно прилагаться правило: его можно открыть
    // прямо во время тренировки.
    expect(q.rule, isNotNull, reason: '$reason: ${q.summary}');
    expectAnswerHidden(q);
  }
}

void main() {
  group('Падежные вопросы', () {
    test('варианты корректны для всех падежей и чисел', () {
      final generator = QuizGenerator(Random(42));
      for (final c in GramCase.values) {
        for (final mode in NumberMode.values) {
          expectWellFormed(
            generator.generate(QuizConfig(cases: [c], numberMode: mode)),
            reason: '${c.sr} / ${mode.ru}',
          );
        }
      }
    });

    test('словосочетания тоже дают корректные варианты', () {
      final generator = QuizGenerator(Random(4));
      for (final c in GramCase.values) {
        expectWellFormed(
          generator.generate(
            QuizConfig(
              cases: [c],
              numberMode: NumberMode.mixed,
              practiceMode: PracticeMode.phrases,
            ),
          ),
          reason: 'словосочетания: ${c.sr}',
        );
      }
    });

    test('к каждому вопросу приложено правило падежа', () {
      final questions = QuizGenerator(Random(9)).generate(
        const QuizConfig(cases: GramCase.values, numberMode: NumberMode.mixed),
      );
      for (final q in questions) {
        expect(q.rule?.gramCase, isNotNull, reason: q.summary);
      }
    });

    test('в номинативе единственного числа задание перевёрнуто', () {
      // Ставить слово в словарную форму бессмысленно, поэтому вне контекста
      // показывается косвенная форма, а ответом служит сама лемма.
      final questions = QuizGenerator(Random(3)).generate(
        const QuizConfig(
          cases: [GramCase.nominativ],
          numberMode: NumberMode.singular,
        ),
      );
      expect(questions.length, 12);
      for (final q in questions.where((q) => !q.isContextual)) {
        expect(kNounsByLemma.containsKey(q.answer), isTrue, reason: q.summary);
        expect(q.subject, isNot(q.answer), reason: q.summary);
      }
    });

    test('во всех режимах тренировка состоит из двенадцати вопросов', () {
      final generator = QuizGenerator(Random(13));
      for (final c in GramCase.values) {
        for (final mode in NumberMode.values) {
          expect(
            generator.generate(QuizConfig(cases: [c], numberMode: mode)).length,
            12,
            reason: '${c.sr} / ${mode.ru}',
          );
        }
      }
      expect(
        generator
            .generate(
              const QuizConfig(
                cases: GramCase.values,
                numberMode: NumberMode.mixed,
              ),
            )
            .length,
        12,
      );
    });
  });

  group('Прилагательные', () {
    test('формы согласуются с существительным', () {
      final lep = kAdjectives.firstWhere((a) => a.lemma == 'lep');
      String phrase(
        Gender g,
        GramCase c,
        GramNumber n, {
        bool animate = false,
      }) => adjectiveForm(
        lep,
        gender: g,
        gramCase: c,
        number: n,
        animate: animate,
      );

      expect(
        phrase(Gender.masculine, GramCase.nominativ, GramNumber.singular),
        'lepi',
      );
      expect(
        phrase(Gender.masculine, GramCase.genitiv, GramNumber.singular),
        'lepog',
      );
      expect(
        phrase(Gender.feminine, GramCase.dativ, GramNumber.singular),
        'lepoj',
      );
      expect(
        phrase(Gender.feminine, GramCase.akuzativ, GramNumber.singular),
        'lepu',
      );
      expect(
        phrase(Gender.neuter, GramCase.instrumental, GramNumber.singular),
        'lepim',
      );
      expect(
        phrase(Gender.masculine, GramCase.genitiv, GramNumber.plural),
        'lepih',
      );
    });

    test('у одушевлённых винительный падеж совпадает с родительным', () {
      final lep = kAdjectives.first;
      expect(
        adjectiveForm(
          lep,
          gender: Gender.masculine,
          gramCase: GramCase.akuzativ,
          number: GramNumber.singular,
          animate: true,
        ),
        'lepog',
      );
    });
  });

  group('Числительные', () {
    test('число словами записывается верно', () {
      expect(spellNumber(1), 'jedan');
      expect(spellNumber(15), 'petnaest');
      expect(spellNumber(21), 'dvadeset jedan');
      expect(spellNumber(42), 'četrdeset dva');
      expect(spellNumber(100), 'sto');
      expect(spellNumber(125), 'sto dvadeset pet');
      expect(spellNumber(1000), 'hiljadu');
    });

    test('падеж после числительного определяется по последней цифре', () {
      expect(agreementFor(1), NumeralAgreement.nominativeSingular);
      expect(agreementFor(21), NumeralAgreement.nominativeSingular);
      expect(agreementFor(2), NumeralAgreement.genitiveSingular);
      expect(agreementFor(24), NumeralAgreement.genitiveSingular);
      expect(agreementFor(5), NumeralAgreement.genitivePlural);
      expect(agreementFor(11), NumeralAgreement.genitivePlural);
      expect(agreementFor(14), NumeralAgreement.genitivePlural);
      expect(agreementFor(100), NumeralAgreement.genitivePlural);
    });

    test('род учитывается только у единицы и двойки', () {
      expect(genderedNumeralForm(1, Gender.feminine), 'jedna');
      expect(genderedNumeralForm(2, Gender.feminine), 'dve');
      expect(genderedNumeralForm(2, Gender.neuter), 'dva');
      expect(genderedNumeralForm(22, Gender.feminine), 'dve');
      expect(genderedNumeralForm(12, Gender.feminine), isNull);
      expect(genderedNumeralForm(5, Gender.feminine), isNull);
    });

    test('генератор даёт корректные варианты', () {
      final generator = NumeralQuizGenerator(Random(11));
      for (final kind in NumeralQuizKind.values) {
        final questions = generator.generate(kind);
        expect(questions.length, 12, reason: kind.title);
        expectWellFormed(questions, reason: kind.title);
      }
    });

    test('согласование в заданиях соответствует правилу', () {
      final grad = kNounsByLemma['grad']!;
      final knjiga = kNounsByLemma['knjiga']!;
      expect(grad.form(GramCase.genitiv, GramNumber.singular), 'grada');
      expect(grad.form(GramCase.genitiv, GramNumber.plural), 'gradova');
      expect(knjiga.form(GramCase.genitiv, GramNumber.plural), 'knjiga');

      final questions = NumeralQuizGenerator(Random(5))
          .generate(NumeralQuizKind.agreement);
      for (final q in questions) {
        expect(
          q.answer.split(' ').length,
          greaterThanOrEqualTo(2),
          reason: q.answer,
        );
      }
    });
  });

  group('Порядок тренировок урока', () {
    test('единственное число ведёт к множественному, затем к смешанному', () {
      final singular = QuizPresets.forCase(
        GramCase.genitiv,
        NumberMode.singular,
      );
      expect(singular.next?.label, 'множественное число');

      final plural = singular.next!.build();
      expect(plural.title, contains('множественное'));
      expect(plural.gramCase, GramCase.genitiv);
      expect(plural.next?.label, 'оба числа вперемешку');

      final mixed = plural.next!.build();
      expect(mixed.title, contains('оба числа'));
      expect(mixed.next, isNull, reason: 'цепочка кончается смешанным');
    });

    test('цепочка сохраняет падеж и вид тренировки', () {
      for (final c in GramCase.values) {
        var session = QuizPresets.forCase(c, NumberMode.singular);
        var steps = 1;
        while (session.next != null) {
          session = session.next!.build();
          steps++;
          expect(session.gramCase, c);
          expect(session.progressKey, 'case_${c.index}');
          expect(session.build(), hasLength(12));
        }
        expect(steps, 3, reason: c.sr);
      }
    });

    test('у тренировки словосочетаний продолжения нет', () {
      final phrases = QuizPresets.forCase(
        GramCase.dativ,
        NumberMode.mixed,
        practice: PracticeMode.phrases,
      );
      expect(phrases.next, isNull);
      expect(QuizPresets.mixed(GramCase.values).next, isNull);
      expect(QuizPresets.phrases(GramCase.values).next, isNull);
    });
  });

  group('Таблица склонения', () {
    test('в таблице семь падежей с корректными вариантами', () {
      for (var seed = 0; seed < 200; seed++) {
        final table = PhraseTableGenerator(Random(seed)).build();
        expect(table.rows.length, GramCase.values.length);
        for (var i = 0; i < table.rows.length; i++) {
          final row = table.rows[i];
          expect(row.gramCase, kCaseTableOrder[i]);
          expect(row.options.length, 4, reason: row.answer);
          expect(row.options.toSet().length, 4, reason: row.answer);
          expect(row.options, contains(row.answer));
        }
      }
    });

    test('все строки описывают одно словосочетание', () {
      final table = PhraseTableGenerator(Random(7)).build();
      for (final row in table.rows) {
        final expected = phraseForm(
          table.adjective,
          table.noun,
          row.gramCase,
          table.number,
        );
        expect(row.answer, expected, reason: row.gramCase.sr);
      }
    });

    test('множественное число берётся только у слов, которые его имеют', () {
      for (var seed = 0; seed < 300; seed++) {
        final table = PhraseTableGenerator(Random(seed)).build();
        if (table.number == GramNumber.plural) {
          expect(table.noun.hasPlural, isTrue, reason: table.noun.lemma);
        }
      }
    });

    test('заголовок не подсказывает ни одну строку таблицы', () {
      for (var seed = 0; seed < 200; seed++) {
        final table = PhraseTableGenerator(Random(seed)).build();
        for (final row in table.rows) {
          expect(
            table.headword.contains(row.answer),
            isFalse,
            reason: '${table.headword} -> ${row.answer}',
          );
        }
      }
    });

    test('прилагательное согласовано с существительным', () {
      // Множественное число слова oko - женского рода: lepe oči.
      final oko = kNounsByLemma['oko']!;
      expect(
        phraseForm(
          kCommonAdjectives.first,
          oko,
          GramCase.nominativ,
          GramNumber.plural,
        ),
        '${kCommonAdjectives.first.stem}e oči',
      );
    });
  });
}
