import 'dart:math';

import 'package:srpski_padezi/data/adjectives.dart';
import 'package:srpski_padezi/data/nouns.dart';
import 'package:srpski_padezi/data/sentences.dart';
import 'package:srpski_padezi/logic/phrase_forms.dart';
import 'package:srpski_padezi/models/models.dart';

/// Какое число тренируем.
enum NumberMode { singular, plural, mixed }

extension NumberModeX on NumberMode {
  String get ru => switch (this) {
    NumberMode.singular => 'единственное число',
    NumberMode.plural => 'множественное число',
    NumberMode.mixed => 'оба числа',
  };

  List<GramNumber> get numbers => switch (this) {
    NumberMode.singular => const [GramNumber.singular],
    NumberMode.plural => const [GramNumber.plural],
    NumberMode.mixed => const [GramNumber.singular, GramNumber.plural],
  };
}

/// Одна тренировка: заголовок, способ собрать вопросы и ключ прогресса.
///
/// Вопросы строятся функцией, а не списком, чтобы кнопка «Пройти ещё раз»
/// давала новый набор заданий.
class QuizSession {
  const QuizSession({
    required this.title,
    required this.build,
    this.progressKey,
    this.gramCase,
    this.next,
  });

  final String title;
  final List<Question> Function() build;

  /// Ключ, под которым сохраняется лучший результат; null - не сохранять.
  final String? progressKey;

  /// Падеж урока, если тренировка относится к одному падежу.
  final GramCase? gramCase;

  /// Что предложить после этой тренировки; null - если урок на ней кончается.
  final NextStep? next;
}

/// Следующий шаг урока. Тренировка задаётся функцией: иначе цепочка
/// построила бы сразу все свои продолжения.
class NextStep {
  const NextStep({required this.label, required this.build});

  final String label;
  final QuizSession Function() build;
}

/// Что тренируем: отдельное существительное или словосочетание
/// «прилагательное + существительное».
enum PracticeMode { nouns, phrases, mixed }

extension PracticeModeX on PracticeMode {
  String get ru => switch (this) {
    PracticeMode.nouns => 'существительные',
    PracticeMode.phrases => 'прилагательное + существительное',
    PracticeMode.mixed => 'слова и словосочетания',
  };
}

/// Настройки падежной тренировки.
class QuizConfig {
  const QuizConfig({
    required this.cases,
    required this.numberMode,
    this.practiceMode = PracticeMode.nouns,
    this.questionCount = 12,
  });

  final List<GramCase> cases;
  final NumberMode numberMode;
  final PracticeMode practiceMode;
  final int questionCount;
}

/// Генератор падежных вопросов: собирает задания из словаря и контекстных
/// предложений и подбирает к ним правдоподобные неверные варианты.
class QuizGenerator {
  QuizGenerator([Random? random]) : _random = random ?? Random();

  final Random _random;

  /// Строит список вопросов по настройкам тренировки.
  List<Question> generate(QuizConfig config) {
    final questions = <Question>[];
    final used = <String>{};

    final contextPool = <Question>[];
    final formPool = <Question>[];

    for (final gramCase in config.cases) {
      for (final number in config.numberMode.numbers) {
        // Контекстные задания.
        for (final task in sentencesFor(gramCase)) {
          if (task.number != number) continue;
          final noun = kNounsByLemma[task.lemma];
          if (noun == null) continue;
          final answer = noun.form(gramCase, number);
          if (answer == null) continue;
          contextPool.add(
            _buildQuestion(
              noun: noun,
              gramCase: gramCase,
              number: number,
              answer: answer,
              task: task,
            ),
          );
        }

        // Задания со словосочетанием «прилагательное + существительное».
        if (config.practiceMode != PracticeMode.nouns) {
          for (final task in sentencesFor(gramCase)) {
            if (task.number != number) continue;
            final noun = kNounsByLemma[task.lemma];
            if (noun == null) continue;
            if (noun.form(gramCase, number) == null) continue;
            contextPool.add(
              _buildPhraseQuestion(
                noun: noun,
                adjective:
                    kCommonAdjectives[_random.nextInt(
                      kCommonAdjectives.length,
                    )],
                gramCase: gramCase,
                number: number,
                task: task,
              ),
            );
          }
          for (final noun in kNouns) {
            if (noun.form(gramCase, number) == null) continue;
            formPool.add(
              _buildPhraseQuestion(
                noun: noun,
                adjective:
                    kCommonAdjectives[_random.nextInt(
                      kCommonAdjectives.length,
                    )],
                gramCase: gramCase,
                number: number,
              ),
            );
          }
        }

        // Задания «поставь слово в форму».
        if (config.practiceMode == PracticeMode.phrases) continue;
        for (final noun in kNouns) {
          final answer = noun.form(gramCase, number);
          if (answer == null) continue;
          // Номинатив единственного числа - это и есть словарная форма,
          // поэтому вместо «поставьте в номинатив» спрашиваем обратное:
          // от какой начальной формы образована показанная.
          if (gramCase == GramCase.nominativ && number == GramNumber.singular) {
            final question = _buildDictionaryFormQuestion(noun);
            if (question != null) formPool.add(question);
            continue;
          }
          formPool.add(
            _buildQuestion(
              noun: noun,
              gramCase: gramCase,
              number: number,
              answer: answer,
            ),
          );
        }
      }
    }

    contextPool.shuffle(_random);
    formPool.shuffle(_random);

    // Примерно 40 % заданий - с предложением, остальное - на форму слова.
    final wantedContext = min(
      contextPool.length,
      (config.questionCount * 0.4).round(),
    );

    void take(List<Question> pool, int limit) {
      var remaining = limit;
      for (final q in pool) {
        if (questions.length >= config.questionCount || remaining <= 0) return;
        if (!used.add('${q.summary}')) continue;
        questions.add(q);
        remaining--;
      }
    }

    take(contextPool, wantedContext);
    take(formPool, config.questionCount - questions.length);
    // Если словарь дал меньше вопросов, чем нужно, добираем оставшимся пулом.
    if (questions.length < config.questionCount) {
      take(contextPool, config.questionCount - questions.length);
    }

    questions.shuffle(_random);
    return questions;
  }

  Question _buildQuestion({
    required Noun noun,
    required GramCase gramCase,
    required GramNumber number,
    required String answer,
    SentenceTask? task,
  }) {
    // Если форма совпала со словарной, лемму показывать нельзя - это и был
    // бы ответ; слово называется только переводом.
    final answerIsLemma = answer == noun.lemma;

    return Question(
      prompt: switch ((task, answerIsLemma)) {
        (null, false) =>
          'Поставьте слово в ${gramCase.ru} падеж, ${number.ruShort}',
        (null, true) =>
          'Выберите ${gramCase.ru} падеж, ${number.ruShort}, '
              'у слова со значением «${noun.ru}»',
        (_, false) =>
          'Поставьте слово «${noun.lemma}» (${noun.ru}) в нужную форму.',
        (_, true) => 'Вставьте слово со значением «${noun.ru}» в нужной форме.',
      },
      answer: answer,
      options: _buildOptions(noun, number, answer),
      subject: task != null
          ? null
          : answerIsLemma
          ? '«${noun.ru}»'
          : '${noun.lemma} (${noun.ru})',
      subtitle: task == null
          ? '${noun.gender.ru}, ${noun.declension.ru}'
          : null,
      contextSr: task?.template,
      contextRu: task?.translation,
      tags: ['${gramCase.sr} - ${gramCase.ru}', number.ruShort],
      hint: task?.hint ?? noun.note,
      summary:
          '${noun.lemma} → $answer '
          '(${gramCase.sr}, ${number.ruShort})',
      rule: RuleRef(gramCase: gramCase),
    );
  }

  /// Обратное задание: показана косвенная форма, нужно назвать словарную.
  ///
  /// Так номинатив единственного числа тренирует узнавание слова, а не
  /// переписывание словарной формы.
  Question? _buildDictionaryFormQuestion(Noun noun) {
    final candidates = <({String form, GramCase gramCase, GramNumber number})>[
      for (final number in GramNumber.values)
        for (final gramCase in GramCase.values)
          if (noun.form(gramCase, number) case final form?)
            if (form != noun.lemma)
              (form: form, gramCase: gramCase, number: number),
    ];
    if (candidates.isEmpty) return null;

    final shown = candidates[_random.nextInt(candidates.length)];
    final options = <String>{noun.lemma};
    final others = <String>[
      ...noun.forms(GramNumber.singular),
      ...noun.forms(GramNumber.plural),
    ].where((f) => f != shown.form).toList()..shuffle(_random);
    for (final form in others) {
      if (options.length >= 4) break;
      options.add(form);
    }
    if (options.length < 4) return null;

    return Question(
      prompt:
          'Какая у этого слова начальная форма: именительный падеж, '
          'единственное число?',
      answer: noun.lemma,
      options: options.toList()..shuffle(_random),
      subject: shown.form,
      subtitle: '${noun.ru}, ${noun.gender.ru}',
      tags: ['${GramCase.nominativ.sr} - ${GramCase.nominativ.ru}', 'ед. ч.'],
      hint:
          '${shown.form} - это ${shown.gramCase.ru} падеж, '
          '${shown.number.ruShort}; словарная форма - ${noun.lemma}.',
      summary: '${shown.form} -> ${noun.lemma}',
      rule: const RuleRef(gramCase: GramCase.nominativ),
    );
  }

  /// Вопрос на словосочетание «прилагательное + существительное».
  ///
  /// Согласование - главное, что нужно довести до автоматизма: окончания
  /// прилагательного и существительного в одной форме выглядят по-разному.
  Question _buildPhraseQuestion({
    required Noun noun,
    required Adjective adjective,
    required GramCase gramCase,
    required GramNumber number,
    SentenceTask? task,
  }) {
    // Словарная подача пары - в номинативе единственного числа.
    final dictionaryPair = phraseForm(
      adjective,
      noun,
      GramCase.nominativ,
      GramNumber.singular,
    )!;
    final answer = phraseForm(adjective, noun, gramCase, number)!;
    final options = phraseOptions(
      adjective: adjective,
      noun: noun,
      gramCase: gramCase,
      number: number,
      answer: answer,
      random: _random,
    );

    final adjEnding = adjectiveEnding(
      gender: noun.genderIn(number),
      gramCase: gramCase,
      number: number,
      animate: noun.animate,
    );

    return Question(
      prompt: switch ((task, answer == dictionaryPair)) {
        (null, false) =>
          'Поставьте словосочетание в ${gramCase.ru} падеж, '
              '${number.ruShort}',
        (null, true) =>
          'Выберите ${gramCase.ru} падеж, ${number.ruShort}, '
              'для «${adjective.ru} + ${noun.ru}»',
        (_, false) =>
          'Вставьте «$dictionaryPair» '
              '(${adjective.ru} + ${noun.ru}) в нужной форме.',
        (_, true) => 'Вставьте «${adjective.ru} + ${noun.ru}» в нужной форме.',
      },
      answer: answer,
      options: options,
      subject: task != null
          ? null
          : answer == dictionaryPair
          ? '«${adjective.ru} + ${noun.ru}»'
          : dictionaryPair,
      subtitle: task == null
          ? '${adjective.ru} + ${noun.ru}, ${noun.gender.ru}'
          : null,
      contextSr: task?.template,
      contextRu: task?.translation,
      tags: [
        '${gramCase.sr} - ${gramCase.ru}',
        number.ruShort,
        'прилагательное + существительное',
      ],
      hint:
          'Прилагательное берёт окончание -$adjEnding '
          '(${noun.genderIn(number).ru}, ${number.ruShort}), '
          'существительное - своё: $answer.',
      summary:
          '${adjective.lemma} ${noun.lemma} → $answer '
          '(${gramCase.sr}, ${number.ruShort})',
      rule: RuleRef(gramCase: gramCase),
    );
  }

  /// Четыре варианта: правильный плюс три правдоподобных.
  ///
  /// Сначала берутся другие падежные формы того же слова в том же числе -
  /// именно их и путают на практике; затем формы другого числа; в последнюю
  /// очередь - искусственные формы с чужими окончаниями.
  List<String> _buildOptions(Noun noun, GramNumber number, String answer) {
    final options = <String>{answer};
    final other = number == GramNumber.singular
        ? GramNumber.plural
        : GramNumber.singular;

    void addFrom(Iterable<String> source) {
      final candidates = source.where((f) => !options.contains(f)).toList()
        ..shuffle(_random);
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

    return options.toList()..shuffle(_random);
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
}

/// Готовые тренировки по падежам.
class QuizPresets {
  /// Тренировка по одному падежу.
  ///
  /// Звенья цепочки: единственное число - множественное - оба вперемешку.
  static QuizSession forCase(
    GramCase c,
    NumberMode mode, {
    PracticeMode practice = PracticeMode.nouns,
  }) {
    final nextMode = switch (mode) {
      NumberMode.singular => NumberMode.plural,
      NumberMode.plural => NumberMode.mixed,
      NumberMode.mixed => null,
    };

    return QuizSession(
      title: '${c.sr} - ${mode.ru}',
      gramCase: c,
      progressKey: 'case_${c.index}',
      build: () => QuizGenerator().generate(
        QuizConfig(cases: [c], numberMode: mode, practiceMode: practice),
      ),
      next: nextMode == null
          ? null
          : NextStep(
              label: nextMode == NumberMode.plural
                  ? 'множественное число'
                  : 'оба числа вперемешку',
              build: () => forCase(c, nextMode, practice: practice),
            ),
    );
  }

  /// Тренировка словосочетаний «прилагательное + существительное».
  static QuizSession phrases(List<GramCase> cases, {int count = 12}) =>
      QuizSession(
        title: 'Прилагательное + существительное',
        progressKey: 'phrases_mixed',
        build: () => QuizGenerator().generate(
          QuizConfig(
            cases: cases,
            numberMode: NumberMode.mixed,
            practiceMode: PracticeMode.phrases,
            questionCount: count,
          ),
        ),
      );

  /// Смешанная тренировка по нескольким падежам.
  static QuizSession mixed(
    List<GramCase> cases, {
    int count = 12,
    PracticeMode practice = PracticeMode.mixed,
  }) => QuizSession(
    title: 'Смешанная тренировка',
    build: () => QuizGenerator().generate(
      QuizConfig(
        cases: cases,
        numberMode: NumberMode.mixed,
        practiceMode: practice,
        questionCount: count,
      ),
    ),
  );
}
