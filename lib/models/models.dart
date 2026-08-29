// Базовые модели предметной области: падежи, число, существительные,
// теоретические карточки и вопросы теста.

/// Падежи сербского языка в традиционном школьном порядке.
enum GramCase {
  nominativ,
  genitiv,
  dativ,
  akuzativ,
  vokativ,
  instrumental,
  lokativ,
}

extension GramCaseInfoX on GramCase {
  /// Сербское название падежа (латиница).
  String get sr => switch (this) {
    GramCase.nominativ => 'Nominativ',
    GramCase.genitiv => 'Genitiv',
    GramCase.dativ => 'Dativ',
    GramCase.akuzativ => 'Akuzativ',
    GramCase.vokativ => 'Vokativ',
    GramCase.instrumental => 'Instrumental',
    GramCase.lokativ => 'Lokativ',
  };

  /// Русское название падежа.
  String get ru => switch (this) {
    GramCase.nominativ => 'именительный',
    GramCase.genitiv => 'родительный',
    GramCase.dativ => 'дательный',
    GramCase.akuzativ => 'винительный',
    GramCase.vokativ => 'звательный',
    GramCase.instrumental => 'творительный',
    GramCase.lokativ => 'предложный (местный)',
  };

  /// Вопросы падежа на сербском.
  String get questions => switch (this) {
    GramCase.nominativ => 'ko? šta?',
    GramCase.genitiv => 'koga? čega?',
    GramCase.dativ => 'kome? čemu?',
    GramCase.akuzativ => 'koga? šta?',
    GramCase.vokativ => 'обращение: hej!',
    GramCase.instrumental => 's kim? čim?',
    GramCase.lokativ => 'o kome? o čemu? gde?',
  };

  /// Номер падежа в сербской нумерации (1-7).
  int get order => index + 1;
}

/// Грамматическое число.
enum GramNumber { singular, plural }

extension GramNumberX on GramNumber {
  String get ru => this == GramNumber.singular
      ? 'единственное число'
      : 'множественное число';
  String get ruShort => this == GramNumber.singular ? 'ед. ч.' : 'мн. ч.';
  String get sr => this == GramNumber.singular ? 'jednina' : 'množina';
}

/// Род существительного.
enum Gender { masculine, feminine, neuter }

extension GenderX on Gender {
  String get ru => switch (this) {
    Gender.masculine => 'мужской род',
    Gender.feminine => 'женский род',
    Gender.neuter => 'средний род',
  };
}

/// Тип склонения - используется в подсказках и в теории.
enum Declension {
  /// Мужской род на согласный: grad, student.
  masculine,

  /// Женский род на -a: žena, knjiga.
  feminineA,

  /// Женский род на согласный (i-склонение): noć, stvar.
  feminineI,

  /// Средний род на -o / -e: selo, more.
  neuter,
}

extension DeclensionX on Declension {
  String get ru => switch (this) {
    Declension.masculine => 'м. р. на согласный',
    Declension.feminineA => 'ж. р. на -a',
    Declension.feminineI => 'ж. р. на согласный (i-склонение)',
    Declension.neuter => 'ср. р. на -o / -e',
  };
}

/// Существительное со всеми падежными формами.
class Noun {
  const Noun({
    required this.lemma,
    required this.ru,
    required this.gender,
    required this.declension,
    required this.animate,
    required this.sg,
    this.pl,
    this.note,
    this.pluralGender,
  });

  /// Форма именительного падежа единственного числа.
  final String lemma;

  /// Перевод на русский.
  final String ru;
  final Gender gender;
  final Declension declension;

  /// Одушевлённость - важна для винительного падежа мужского рода.
  final bool animate;

  /// Семь форм единственного числа в порядке [GramCase.values].
  final List<String> sg;

  /// Семь форм множественного числа; null, если множественного нет.
  final List<String>? pl;

  /// Примечание об особенности слова (чередование, беглое «а» и т. п.).
  final String? note;

  /// Род множественного числа, если он отличается от рода единственного.
  ///
  /// Так согласуются oko - oči и uvo - uši (lepe oči, а не «lepa oči»), а
  /// также мужские слова на -a: во множественном числе определение при них
  /// женского рода (moje kolege, naše komšije).
  final Gender? pluralGender;

  bool get hasPlural => pl != null;

  /// Род, с которым согласуется прилагательное в заданном числе.
  Gender genderIn(GramNumber n) =>
      n == GramNumber.plural ? (pluralGender ?? gender) : gender;

  /// Форма слова в заданном падеже и числе; null, если формы нет.
  String? form(GramCase c, GramNumber n) {
    final table = n == GramNumber.singular ? sg : pl;
    return table?[c.index];
  }

  /// Все формы заданного числа.
  List<String> forms(GramNumber n) =>
      (n == GramNumber.singular ? sg : pl) ?? const [];
}

/// Строка таблицы окончаний в теории.
class EndingRow {
  const EndingRow(this.group, this.singular, this.plural, {this.example});
  final String group;
  final String singular;
  final String plural;
  final String? example;
}

/// Пример «сербская фраза - перевод».
class Example {
  const Example(this.sr, this.ru);
  final String sr;
  final String ru;
}

/// Теоретическая карточка одного падежа.
class CaseInfo {
  const CaseInfo({
    required this.gramCase,
    required this.tagline,
    required this.summary,
    required this.meanings,
    required this.prepositions,
    required this.endings,
    required this.examples,
    required this.russianNote,
    required this.pitfalls,
  });

  final GramCase gramCase;

  /// Короткая характеристика падежа для карточки на главном экране.
  final String tagline;

  /// Развёрнутое объяснение.
  final String summary;

  /// Основные значения (за что отвечает падеж).
  final List<String> meanings;

  /// Предлоги, которые требуют этого падежа.
  final List<String> prepositions;

  final List<EndingRow> endings;
  final List<Example> examples;

  /// Сопоставление с русским языком.
  final String russianNote;

  /// Типичные ошибки русскоязычных.
  final List<String> pitfalls;
}

/// Раздел теории: заголовок, объяснение, пункты, примеры и таблица.
class TopicSection {
  const TopicSection({
    required this.title,
    required this.body,
    this.bullets = const [],
    this.examples = const [],
    this.table = const [],
  });

  final String title;
  final String body;
  final List<String> bullets;
  final List<Example> examples;

  /// Таблица форм: группа, единственное число, множественное число.
  final List<EndingRow> table;
}

/// Ссылка на правило, которое можно открыть прямо во время тренировки.
class RuleRef {
  const RuleRef({
    this.gramCase,
    this.title,
    this.body,
    this.bullets = const [],
  });

  /// Падеж, правило которого нужно показать целиком.
  final GramCase? gramCase;

  /// Заголовок правила, если оно не привязано к падежу.
  final String? title;

  /// Текст правила.
  final String? body;

  /// Дополнительные пункты правила.
  final List<String> bullets;
}

/// Один вопрос теста.
///
/// Модель намеренно не привязана к падежам: так один и тот же экран
/// тренировки обслуживает и падежи, и числительные.
class Question {
  const Question({
    required this.prompt,
    required this.answer,
    required this.options,
    this.subject,
    this.subtitle,
    this.contextSr,
    this.contextRu,
    this.tags = const [],
    this.hint,
    this.summary,
    this.rule,
  });

  /// Формулировка задания на русском.
  final String prompt;

  /// Правильный ответ.
  final String answer;

  /// Четыре варианта ответа, включая правильный.
  final List<String> options;

  /// Крупная строка над заданием: слово или число, о котором идёт речь.
  final String? subject;

  /// Уточнение под заданием: род, тип склонения и т. п.
  final String? subtitle;

  /// Предложение с пропуском `___` (для контекстных заданий).
  final String? contextSr;

  /// Перевод предложения.
  final String? contextRu;

  /// Метки-чипы: падеж, число, тема.
  final List<String> tags;

  /// Пояснение, которое показывается после ответа.
  final String? hint;

  /// Короткая сводка «было → стало» для разбора ошибок.
  final String? summary;

  /// Правило, по которому строится ответ: его можно открыть в тренировке.
  final RuleRef? rule;

  bool get isContextual => contextSr != null;
}

/// Результат ответа на один вопрос - нужен для разбора ошибок.
class AnswerRecord {
  const AnswerRecord({
    required this.question,
    required this.given,
    required this.correct,
  });

  final Question question;
  final String given;
  final bool correct;
}
