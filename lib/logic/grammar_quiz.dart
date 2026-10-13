import 'dart:math';

import 'package:srpski_padezi/data/choices.dart';
import 'package:srpski_padezi/data/comparison.dart';
import 'package:srpski_padezi/data/grammar_topics.dart';
import 'package:srpski_padezi/data/nouns.dart';
import 'package:srpski_padezi/data/prepositions.dart';
import 'package:srpski_padezi/data/pronouns.dart';
import 'package:srpski_padezi/data/verbs.dart';
import 'package:srpski_padezi/logic/quiz_engine.dart';
import 'package:srpski_padezi/models/models.dart';

/// Местоимение-подсказка для каждого лица.
const List<String> _personPronouns = ['ja', 'ti', 'on', 'mi', 'vi', 'oni'];

/// Русские подписи лиц.
const List<String> _personRu = ['я', 'ты', 'он / она', 'мы', 'вы', 'они'];

/// Предложение, в которое подставляется краткая форма местоимения.
class _PronounSlot {
  const new(this.template, this.ru, this.gramCase);

  final String template;
  final String ru;
  final GramCase gramCase;
}

const List<_PronounSlot> _pronounSlots = [
  _PronounSlot(
    'Vidim ___ svaki dan.',
    'Я вижу … каждый день.',
    GramCase.akuzativ,
  ),
  _PronounSlot(
    'Čekam ___ ispred škole.',
    'Я жду … перед школой.',
    GramCase.akuzativ,
  ),
  _PronounSlot(
    'Zovem ___ večeras.',
    'Я позвоню … сегодня вечером.',
    GramCase.akuzativ,
  ),
  _PronounSlot('Dajem ___ knjigu.', 'Я даю … книгу.', GramCase.dativ),
  _PronounSlot('Reci ___ istinu.', 'Скажи … правду.', GramCase.dativ),
  _PronounSlot(
    'Pomozi ___, molim te.',
    'Помоги …, пожалуйста.',
    GramCase.dativ,
  ),
];

/// Генератор заданий по грамматике вне падежей и числительных.
class GrammarQuizGenerator {
  new([Random? random]) : _random = random ?? Random();

  final Random _random;

  List<Question> generate(GrammarDrill drill, {int count = 12}) {
    final questions = switch (drill) {
      GrammarDrill.presentTense => _present(),
      GrammarDrill.pastTense => _past(),
      GrammarDrill.futureTense => _future(),
      GrammarDrill.imperative => _imperative(),
      GrammarDrill.negation => _fromChoices(kNegationTasks, drill),
      GrammarDrill.pronounShort => _pronouns(),
      GrammarDrill.wordOrder => _fromChoices(kWordOrderTasks, drill),
      GrammarDrill.daConstruction => _fromChoices(kDaConstructionTasks, drill),
      GrammarDrill.comparison => _comparison(),
      GrammarDrill.prepositionCase => _prepositions(),
      GrammarDrill.motionOrPlace => _motionOrPlace(),
    };
    return (questions..shuffle(_random)).take(count).toList();
  }

  /// Правило темы, к которой относится тренировка.
  RuleRef ruleFor(GrammarDrill drill) {
    final topic = kGrammarTopics.firstWhere((t) => t.drills.contains(drill));
    return RuleRef(
      title: topic.title,
      body: topic.sections.first.body,
      bullets: [for (final s in topic.sections) ...s.bullets],
    );
  }

  /// Дополняет набор вариантов до четырёх.
  List<String> _fill(Set<String> options, List<String> extra) {
    for (final candidate in extra) {
      if (options.length >= 4) break;
      options.add(candidate);
    }
    return options.toList()..shuffle(_random);
  }

  // ── Настоящее время ─────────────────────────────────────────────────────

  List<Question> _present() {
    final result = <Question>[];
    for (final verb in kVerbs) {
      for (final person in Person.values) {
        final answer = verb.presentFor(person);
        final options = <String>{
          answer,
          ...verb.present.toList()..shuffle(_random),
        };
        final extra =
            kVerbs
                .where((v) => v.conjugation == verb.conjugation && v != verb)
                .expand((v) => v.present)
                .toList()
              ..shuffle(_random);

        result.add(
          Question(
            prompt:
                'Поставьте глагол в форму «${_personPronouns[person.index]}» '
                '(${_personRu[person.index]}).',
            subject: '${verb.infinitive} (${verb.ru})',
            subtitle: verb.conjugation.title,
            answer: answer,
            options: _fill(options.take(4).toSet(), extra),
            tags: const ['Глагол', 'настоящее время'],
            hint:
                'Окончания ${verb.conjugation.title}: '
                '${verb.conjugation.endings.join(", ")}.'
                '${verb.note == null ? '' : ' ${verb.note}'}',
            summary:
                '${verb.infinitive} → $answer '
                '(${_personPronouns[person.index]})',
            rule: ruleFor(GrammarDrill.presentTense),
          ),
        );
      }
    }
    return result;
  }

  // ── Прошедшее время ─────────────────────────────────────────────────────

  List<Question> _past() {
    final result = <Question>[];
    for (final verb in kVerbs) {
      for (final subject in kSubjects) {
        final aux = kPerfectAux[subject.person.index];
        final participle = verb.participleFor(subject);
        final answer = '$aux $participle';

        final options = <String>{answer};
        // Другой вспомогательный глагол при верном причастии.
        for (final other in kPerfectAux.toList()..shuffle(_random)) {
          if (options.length >= 2) break;
          if (other != aux) options.add('$other $participle');
        }
        // Верный вспомогательный, но причастие другого рода или числа.
        final wrongParticiples =
            verb.participle.where((p) => p != participle).toList()
              ..shuffle(_random);
        for (final p in wrongParticiples) {
          if (options.length >= 4) break;
          options.add('$aux $p');
        }

        result.add(
          Question(
            prompt:
                'Поставьте глагол в прошедшее время для «${subject.pronoun}» '
                '(${subject.ru}).',
            subject: '${verb.infinitive} (${verb.ru})',
            subtitle: 'подлежащее: ${subject.pronoun} - ${subject.ru}',
            answer: answer,
            options: _fill(
              options,
              wrongParticiples.map((p) => '$aux $p').toList(),
            ),
            tags: const ['Глагол', 'прошедшее время'],
            hint:
                'Причастие согласуется с подлежащим в роде и числе, '
                'вспомогательный глагол - по лицу: $answer.',
            summary: '${verb.infinitive} → $answer (${subject.pronoun})',
            rule: ruleFor(GrammarDrill.pastTense),
          ),
        );
      }
    }
    return result;
  }

  // ── Будущее время ───────────────────────────────────────────────────────

  List<Question> _future() {
    final result = <Question>[];

    String formFor(Verb verb, Person person) => verb.contractsFuture
        ? verb.contractedFuture(person)
        : '${kFutureAux[person.index]} ${verb.infinitive}';

    for (final verb in kVerbs) {
      for (final person in Person.values) {
        final answer = formFor(verb, person);
        final options = <String>{answer};
        final others =
            Person.values
                .where((p) => p != person)
                .map((p) => formFor(verb, p))
                .toList()
              ..shuffle(_random);

        result.add(
          Question(
            prompt:
                'Поставьте глагол в будущее время для '
                '«${_personPronouns[person.index]}» '
                '(${_personRu[person.index]}).',
            subject: '${verb.infinitive} (${verb.ru})',
            subtitle: verb.contractsFuture
                ? 'глагол на -ti: форма сливается'
                : 'глагол на -ći: форма не сливается',
            answer: answer,
            options: _fill(options, others),
            tags: const ['Глагол', 'будущее время'],
            hint: verb.contractsFuture
                ? 'Глаголы на -ti сливаются с ću: $answer. Раздельный вариант '
                      '«${kFutureAux[person.index]} ${verb.infinitive}» тоже '
                      'верен.'
                : 'Глаголы на -ći не сливаются: $answer.',
            summary: '${verb.infinitive} → $answer',
            rule: ruleFor(GrammarDrill.futureTense),
          ),
        );
      }
    }
    return result;
  }

  // ── Повелительное наклонение ────────────────────────────────────────────

  List<Question> _imperative() {
    const targets = ['ti (ты)', 'mi (мы)', 'vi (вы)'];
    final result = <Question>[];

    for (final verb in kVerbs) {
      final forms = verb.imperative;
      if (forms == null) continue;
      for (var i = 0; i < forms.length; i++) {
        final answer = forms[i];
        final options = <String>{answer, ...forms};
        final extra = [
          ...verb.present,
          ...kVerbs
              .where((v) => v.imperative != null && v != verb)
              .expand((v) => v.imperative!),
        ]..shuffle(_random);

        result.add(
          Question(
            prompt: 'Как звучит повелительное наклонение для «${targets[i]}»?',
            subject: '${verb.infinitive} (${verb.ru})',
            answer: answer,
            options: _fill(options.take(4).toSet(), extra),
            tags: const ['Глагол', 'повелительное наклонение'],
            hint:
                'Формы: ${forms.join(" - ")}. Запрет строится через nemoj: '
                'nemoj da ${verb.presentFor(Person.secondSg)}.',
            summary: '${verb.infinitive} → $answer',
            rule: ruleFor(GrammarDrill.imperative),
          ),
        );
      }
    }
    return result;
  }

  // ── Краткие формы местоимений ───────────────────────────────────────────

  List<Question> _pronouns() {
    final result = <Question>[];

    for (final slot in _pronounSlots) {
      for (final pronoun in kPronouns) {
        final answer = pronoun.shortForm(slot.gramCase);
        if (answer == null) continue;

        final options = <String>{answer};
        final others =
            kPronouns
                .map((p) => p.shortForm(slot.gramCase))
                .whereType<String>()
                .toList()
              ..shuffle(_random);
        final full = pronoun.fullForm(slot.gramCase);

        result.add(
          Question(
            // У местоимения ti краткая форма дательного падежа совпадает
            // с именительным: там местоимение называется только переводом,
            // иначе ответ был бы написан прямо в задании.
            prompt: answer == pronoun.nominative
                ? 'Вставьте краткую форму местоимения со значением '
                      '«${pronoun.ru}».'
                : 'Вставьте краткую форму местоимения '
                      '«${pronoun.nominative}» (${pronoun.ru}).',
            contextSr: slot.template,
            contextRu: slot.ru,
            answer: answer,
            options: _fill(options, [?full, ...others]),
            tags: [
              'Местоимения',
              if (slot.gramCase == GramCase.dativ)
                'дательный'
              else
                'винительный',
            ],
            hint:
                'Краткая форма - $answer, полная - $full. Полную ставят '
                'после предлога и при логическом ударении.',
            summary: '${pronoun.nominative} → $answer',
            rule: ruleFor(GrammarDrill.pronounShort),
          ),
        );
      }
    }
    return result;
  }

  // ── Степени сравнения ───────────────────────────────────────────────────

  List<Question> _comparison() {
    final result = <Question>[];

    for (final entry in kComparisons) {
      final otherComparatives =
          kComparisons
              .where((e) => e != entry)
              .map((e) => e.comparative)
              .toList()
            ..shuffle(_random);
      final otherSuperlatives =
          kComparisons
              .where((e) => e != entry)
              .map((e) => e.superlative)
              .toList()
            ..shuffle(_random);

      result.addAll([
        Question(
          prompt: 'Образуйте сравнительную степень.',
          subject: '${entry.positive} (${entry.ru})',
          answer: entry.comparative,
          options: _fill({
            entry.comparative,
            entry.superlative,
            // Правдоподобная ошибка - механическое присоединение -iji.
            if ('${entry.positive}iji' != entry.comparative)
              '${entry.positive}iji',
          }, otherComparatives),
          tags: const ['Прилагательные', 'сравнительная степень'],
          hint: entry.irregular
              ? 'Неправильная форма, её нужно запомнить: '
                    '${entry.positive} → ${entry.comparative}.'
              : entry.note ??
                    'Сравнительная степень: ${entry.positive} → '
                        '${entry.comparative}, превосходная - '
                        '${entry.superlative}.',
          summary: '${entry.positive} → ${entry.comparative}',
          rule: ruleFor(GrammarDrill.comparison),
        ),
        Question(
          prompt: 'Образуйте превосходную степень.',
          subject: '${entry.positive} (${entry.ru})',
          answer: entry.superlative,
          options: _fill({
            entry.superlative,
            entry.comparative,
          }, otherSuperlatives),
          tags: const ['Прилагательные', 'превосходная степень'],
          hint:
              'Превосходная степень - это naj- плюс сравнительная: '
              '${entry.comparative} → ${entry.superlative}.',
          summary: '${entry.positive} → ${entry.superlative}',
          rule: ruleFor(GrammarDrill.comparison),
        ),
      ]);
    }
    return result;
  }

  // ── Предлог и падеж ─────────────────────────────────────────────────────

  List<Question> _prepositions() {
    final result = <Question>[];

    for (final entry in kPrepositions) {
      final noun = kNounsByLemma[entry.lemma];
      if (noun == null) continue;
      final answer = noun.form(entry.gramCase, GramNumber.singular);
      if (answer == null) continue;

      // Сначала другие формы того же слова: именно их и путают на практике.
      final options = <String>{answer};
      final ownForms = <String>[
        ...noun.forms(GramNumber.singular),
        ...noun.forms(GramNumber.plural),
      ]..shuffle(_random);
      for (final form in ownForms) {
        if (options.length >= 4) break;
        options.add(form);
      }
      // У слов вроде ljubav собственных форм меньше четырёх - тогда
      // добираем формами слова того же склонения.
      final others =
          kNouns
              .where((n) => n.declension == noun.declension && n != noun)
              .expand((n) => n.forms(GramNumber.singular))
              .toList()
            ..shuffle(_random);

      result.add(
        Question(
          prompt:
              'Поставьте слово в падеж, которого требует предлог '
              '«${entry.preposition}» (${entry.ru}).',
          contextSr: '${entry.preposition} ___',
          contextRu: '${entry.ru} ${noun.ru}',
          answer: answer,
          options: _fill(options, others),
          tags: ['Предлоги', entry.gramCase.ru],
          hint:
              'Предлог ${entry.preposition} требует '
              '${entry.gramCase.ru} падежа: '
              '${entry.preposition} $answer.',
          summary:
              '${entry.preposition} + ${noun.lemma} -> '
              '${entry.preposition} $answer',
          rule: ruleFor(GrammarDrill.prepositionCase),
        ),
      );
    }
    return result;
  }

  // ── Куда или где ────────────────────────────────────────────────────────

  List<Question> _motionOrPlace() {
    final result = <Question>[];

    for (final pair in kPlacePairs) {
      final noun = kNounsByLemma[pair.lemma];
      if (noun == null) continue;
      final accusative = noun.form(GramCase.akuzativ, GramNumber.singular);
      final locative = noun.form(GramCase.lokativ, GramNumber.singular);
      final genitive = noun.form(GramCase.genitiv, GramNumber.singular);
      final instrumental = noun.form(
        GramCase.instrumental,
        GramNumber.singular,
      );
      if (accusative == null || locative == null) continue;

      String phrase(String form) => '${pair.preposition} $form';

      // Запасные варианты: те же слова, но в чужих падежах.
      final extra = <String>[
        if (genitive != null) phrase(genitive),
        if (instrumental != null) phrase(instrumental),
      ];

      result.addAll([
        Question(
          prompt: 'Есть движение, значит нужен винительный падеж.',
          subject: pair.ruMotion,
          answer: phrase(accusative),
          options: _fill({phrase(accusative), phrase(locative)}, extra),
          tags: const ['Предлоги', 'куда'],
          hint:
              'Движение отвечает на вопрос «куда?», поэтому '
              '${pair.preposition} + винительный: ${phrase(accusative)}.',
          summary: '${pair.ruMotion} -> ${phrase(accusative)}',
          rule: ruleFor(GrammarDrill.motionOrPlace),
        ),
        Question(
          prompt: 'Движения нет, значит нужен локатив.',
          subject: pair.ruPlace,
          answer: phrase(locative),
          options: _fill({phrase(locative), phrase(accusative)}, extra),
          tags: const ['Предлоги', 'где'],
          hint:
              'Место отвечает на вопрос «где?», поэтому '
              '${pair.preposition} + локатив: ${phrase(locative)}.',
          summary: '${pair.ruPlace} -> ${phrase(locative)}',
          rule: ruleFor(GrammarDrill.motionOrPlace),
        ),
      ]);
    }
    return result;
  }

  // ── Задания «выберите правильное предложение» ───────────────────────────

  List<Question> _fromChoices(List<ChoiceTask> tasks, GrammarDrill drill) {
    return [
      for (final task in tasks)
        Question(
          prompt: 'Как правильно сказать это по-сербски?',
          subject: task.ru,
          answer: task.correct,
          options: _fill({task.correct, ...task.wrong}, task.wrong),
          tags: [drill.title],
          hint: task.explanation,
          summary: task.correct,
          rule: ruleFor(drill),
        ),
    ];
  }
}

/// Готовые тренировки по грамматике.
class GrammarQuizPresets {
  static QuizSession forDrill(GrammarDrill drill, {int count = 12}) =>
      QuizSession(
        title: drill.title,
        progressKey: drill.progressKey,
        build: () => GrammarQuizGenerator().generate(drill, count: count),
      );
}
