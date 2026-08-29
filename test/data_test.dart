import 'package:flutter_test/flutter_test.dart';
import 'package:srpski_padezi/data/adjectives.dart';
import 'package:srpski_padezi/data/cases.dart';
import 'package:srpski_padezi/data/choices.dart';
import 'package:srpski_padezi/data/comparison.dart';
import 'package:srpski_padezi/data/grammar_topics.dart';
import 'package:srpski_padezi/data/nouns.dart';
import 'package:srpski_padezi/data/pronouns.dart';
import 'package:srpski_padezi/data/sentences.dart';
import 'package:srpski_padezi/data/verbs.dart';
import 'package:srpski_padezi/models/models.dart';

void main() {
  group('Словарь существительных', () {
    test('у каждого слова по семь форм в каждом числе', () {
      for (final noun in kNouns) {
        expect(noun.sg.length, 7, reason: noun.lemma);
        expect(noun.sg.every((f) => f.isNotEmpty), isTrue, reason: noun.lemma);
        if (noun.pl != null) {
          expect(noun.pl!.length, 7, reason: noun.lemma);
          expect(
            noun.pl!.every((f) => f.isNotEmpty),
            isTrue,
            reason: noun.lemma,
          );
        }
      }
    });

    test('именительный падеж единственного числа совпадает с леммой', () {
      for (final noun in kNouns) {
        expect(noun.form(GramCase.nominativ, GramNumber.singular), noun.lemma);
      }
    });

    test('леммы не повторяются', () {
      expect(kNounsByLemma.length, kNouns.length);
    });

    test('датив и локатив совпадают во всех формах', () {
      for (final noun in kNouns) {
        for (final number in GramNumber.values) {
          expect(
            noun.form(GramCase.lokativ, number),
            noun.form(GramCase.dativ, number),
            reason: '${noun.lemma} (${number.ruShort})',
          );
        }
      }
    });

    test('во множественном числе датив, локатив и инструментал совпадают', () {
      for (final noun in kNouns.where((n) => n.hasPlural)) {
        expect(
          noun.form(GramCase.instrumental, GramNumber.plural),
          noun.form(GramCase.dativ, GramNumber.plural),
          reason: noun.lemma,
        );
      }
    });
  });

  group('Теория падежей', () {
    test('карточка есть для каждого падежа', () {
      expect(kCaseInfos.length, GramCase.values.length);
      for (final c in GramCase.values) {
        expect(caseInfoFor(c).gramCase, c);
      }
    });

    test('маршрут обучения содержит все падежи по одному разу', () {
      expect(kCaseLearningOrder.toSet(), GramCase.values.toSet());
      expect(kCaseLearningOrder.first, GramCase.nominativ);
      expect(kCaseLearningOrder.last, GramCase.vokativ);
      expect(
        kCaseLearningOrder.indexOf(GramCase.dativ),
        kCaseLearningOrder.indexOf(GramCase.lokativ) + 1,
        reason: 'датив идёт сразу за локативом: формы у них общие',
      );
      expect(nextCaseInLearningOrder(GramCase.vokativ), isNull);
      expect(nextCaseInLearningOrder(GramCase.nominativ), GramCase.akuzativ);
      expect(caseLearningStep(GramCase.nominativ), 1);
    });

    test('в таблице склонения локатив стоит сразу за дативом', () {
      expect(kCaseTableOrder.toSet(), GramCase.values.toSet());
      expect(
        kCaseTableOrder.indexOf(GramCase.lokativ),
        kCaseTableOrder.indexOf(GramCase.dativ) + 1,
      );
    });

    test('в каждой карточке есть окончания, примеры и разбор ошибок', () {
      for (final info in kCaseInfos) {
        expect(info.endings, isNotEmpty, reason: info.gramCase.sr);
        expect(info.examples, isNotEmpty, reason: info.gramCase.sr);
        expect(info.pitfalls, isNotEmpty, reason: info.gramCase.sr);
      }
    });
  });

  group('Предложения', () {
    test('все слова из предложений есть в словаре и имеют нужную форму', () {
      for (final task in kSentences) {
        final noun = kNounsByLemma[task.lemma];
        expect(noun, isNotNull, reason: task.lemma);
        expect(
          noun!.form(task.gramCase, task.number),
          isNotNull,
          reason: '${task.lemma} / ${task.gramCase.sr}',
        );
      }
    });

    test('в каждом шаблоне есть ровно один пропуск', () {
      for (final task in kSentences) {
        expect(
          '___'.allMatches(task.template).length,
          1,
          reason: task.template,
        );
      }
    });

    test('для каждого падежа есть задания', () {
      for (final c in GramCase.values) {
        expect(sentencesFor(c), isNotEmpty, reason: c.sr);
      }
    });

    // Пул предложений - самое узкое место тренажёра: если на падеж и число
    // приходится всего пара фраз, они заучиваются вместо правила.
    test('на каждый падеж и число приходится хотя бы 20 предложений', () {
      for (final c in GramCase.values) {
        for (final number in GramNumber.values) {
          final tasks = sentencesFor(
            c,
          ).where((t) => t.number == number).toList();
          expect(
            tasks.length,
            greaterThanOrEqualTo(20),
            reason: '${c.sr}, ${number.ruShort}',
          );
        }
      }
    });

    test('предложение не начинается с пропуска', () {
      for (final task in kSentences) {
        expect(
          task.template.startsWith('___'),
          isFalse,
          reason: '${task.template} - форма встала бы со строчной буквы',
        );
      }
    });

    test('задания не повторяются', () {
      final seen = <String>{};
      for (final task in kSentences) {
        expect(
          seen.add(
            '${task.lemma}|${task.gramCase}|${task.number}|'
            '${task.template}',
          ),
          isTrue,
          reason: task.template,
        );
      }
    });
  });

  group('Словарь прилагательных', () {
    test('прилагательные для словосочетаний есть в словаре', () {
      expect(kCommonAdjectives, hasLength(greaterThanOrEqualTo(20)));
      for (final adjective in kCommonAdjectives) {
        expect(kAdjectives, contains(adjective), reason: adjective.lemma);
      }
    });

    test('леммы не повторяются', () {
      final lemmas = kAdjectives.map((a) => a.lemma).toList();
      expect(lemmas.toSet().length, lemmas.length);
    });

    test('основа не оканчивается на мягкий согласный', () {
      // Окончания в [adjectiveForm] - только твёрдого вида (-og, -om),
      // поэтому мягкая основа (svež → svežeg) дала бы неверную форму.
      const soft = ['ž', 'š', 'č', 'ć', 'đ', 'j', 'lj', 'nj'];
      for (final adjective in kAdjectives) {
        expect(
          soft.any(adjective.stem.endsWith),
          isFalse,
          reason: adjective.lemma,
        );
      }
    });
  });

  group('Глаголы', () {
    test('у каждого глагола шесть форм настоящего времени', () {
      for (final verb in kVerbs) {
        expect(verb.present.length, 6, reason: verb.infinitive);
        expect(verb.participle.length, 6, reason: verb.infinitive);
        expect(verb.imperative?.length ?? 3, 3, reason: verb.infinitive);
      }
    });

    test('причастие согласуется с подлежащим', () {
      final raditi = kVerbs.firstWhere((v) => v.infinitive == 'raditi');
      final on = kSubjects.firstWhere((s) => s.pronoun == 'on');
      final ona = kSubjects.firstWhere((s) => s.pronoun == 'ona');
      final one = kSubjects.firstWhere((s) => s.pronoun == 'one');
      expect(raditi.participleFor(on), 'radio');
      expect(raditi.participleFor(ona), 'radila');
      expect(raditi.participleFor(one), 'radile');
    });

    test('будущее время сливается только у глаголов на -ti', () {
      final raditi = kVerbs.firstWhere((v) => v.infinitive == 'raditi');
      final ici = kVerbs.firstWhere((v) => v.infinitive == 'ići');
      expect(raditi.contractsFuture, isTrue);
      expect(raditi.contractedFuture(Person.firstSg), 'radiću');
      expect(ici.contractsFuture, isFalse);
    });
  });

  group('Местоимения', () {
    test('у каждого местоимения есть краткие формы трёх падежей', () {
      for (final p in kPronouns) {
        expect(p.shortForm(GramCase.genitiv), isNotNull, reason: p.nominative);
        expect(p.shortForm(GramCase.dativ), isNotNull, reason: p.nominative);
        expect(p.shortForm(GramCase.akuzativ), isNotNull, reason: p.nominative);
        expect(p.shortForm(GramCase.nominativ), isNull, reason: p.nominative);
      }
    });
  });

  group('Задания на выбор предложения', () {
    test('у каждого задания есть три неверных варианта', () {
      final all = [
        ...kWordOrderTasks,
        ...kDaConstructionTasks,
        ...kNegationTasks,
      ];
      for (final task in all) {
        expect(task.wrong.length, greaterThanOrEqualTo(3), reason: task.ru);
        expect(task.wrong, isNot(contains(task.correct)), reason: task.ru);
        expect(task.wrong.toSet().length, task.wrong.length, reason: task.ru);
        expect(task.explanation, isNotEmpty, reason: task.ru);
      }
    });
  });

  group('Грамматические темы', () {
    test('каждая тема содержит теорию и хотя бы одну тренировку', () {
      for (final topic in kGrammarTopics) {
        expect(topic.sections, isNotEmpty, reason: topic.title);
        expect(topic.drills, isNotEmpty, reason: topic.title);
      }
    });

    test('каждая тренировка привязана ровно к одной теме', () {
      for (final drill in GrammarDrill.values) {
        final topics = kGrammarTopics
            .where((t) => t.drills.contains(drill))
            .toList();
        expect(topics.length, 1, reason: drill.title);
      }
    });
  });

  group('Степени сравнения', () {
    test('превосходная степень образуется от сравнительной', () {
      for (final entry in kComparisons) {
        expect(
          entry.superlative,
          'naj${entry.comparative}',
          reason: entry.positive,
        );
      }
    });
  });
}
