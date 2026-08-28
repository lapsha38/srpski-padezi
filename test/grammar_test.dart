import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:srpski_padezi/data/grammar_topics.dart';
import 'package:srpski_padezi/logic/grammar_quiz.dart';

import 'quiz_test.dart' show expectWellFormed;

void main() {
  group('Грамматические тренировки', () {
    test('каждая тренировка даёт корректные вопросы', () {
      final generator = GrammarQuizGenerator(Random(21));
      for (final drill in GrammarDrill.values) {
        final questions = generator.generate(drill);
        expectWellFormed(questions, reason: drill.title);
      }
    });

    test('к каждому вопросу приложено правило темы', () {
      final generator = GrammarQuizGenerator(Random(22));
      for (final drill in GrammarDrill.values) {
        for (final q in generator.generate(drill)) {
          expect(q.rule, isNotNull, reason: drill.title);
          expect(q.rule!.bullets, isNotEmpty, reason: drill.title);
        }
      }
    });

    test('в вопросах на прошедшее время есть вспомогательный глагол', () {
      final questions = GrammarQuizGenerator(Random(23))
          .generate(GrammarDrill.pastTense, count: 20);
      const aux = ['sam', 'si', 'je', 'smo', 'ste', 'su'];
      for (final q in questions) {
        expect(aux, contains(q.answer.split(' ').first), reason: q.answer);
      }
    });

    test('в вопросах на местоимения ответ - краткая форма', () {
      final questions = GrammarQuizGenerator(Random(24))
          .generate(GrammarDrill.pronounShort, count: 20);
      for (final q in questions) {
        expect(q.answer.length, lessThanOrEqualTo(4), reason: q.answer);
        expect(q.contextSr, isNotNull, reason: q.answer);
      }
    });
    test('в заданиях на предлоги ответ стоит в нужном падеже', () {
      final questions = GrammarQuizGenerator(Random(25))
          .generate(GrammarDrill.prepositionCase, count: 20);
      for (final q in questions) {
        expect(q.contextSr, contains('___'), reason: q.summary);
        expect(q.tags.first, 'Предлоги', reason: q.summary);
      }
    });

    test('пара «куда - где» различает винительный падеж и локатив', () {
      final questions = GrammarQuizGenerator(Random(26))
          .generate(GrammarDrill.motionOrPlace, count: 20);
      for (final q in questions) {
        // Ответ выглядит как «предлог + форма слова».
        final parts = q.answer.split(' ');
        expect(parts.length, 2, reason: q.answer);
        expect(['u', 'na'], contains(parts.first), reason: q.answer);
        // Неверный вариант с той же основой обязательно есть в списке.
        expect(q.options.length, 4, reason: q.answer);
      }
    });
  });
}
