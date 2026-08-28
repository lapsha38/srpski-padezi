import 'package:srpski_padezi/data/nouns.dart';
import 'package:srpski_padezi/models/models.dart';

/// Прилагательное задаётся основой: все формы определённого вида
/// образуются от неё регулярно, поэтому таблицу можно не хранить.
class Adjective {
  const Adjective(this.lemma, this.ru, this.stem, {this.note});

  /// Словарная форма (мужской род, неопределённый вид): lep, dobar.
  final String lemma;

  /// Перевод на русский.
  final String ru;

  /// Основа, к которой присоединяются окончания: lep, dobr, mal.
  final String stem;

  /// Примечание об особенности основы (беглое «а» и т. п.).
  final String? note;
}

/// Прилагательные с твёрдой основой - самый частотный и регулярный тип.
const List<Adjective> kAdjectives = [
  Adjective('lep', 'красивый', 'lep'),
  Adjective('nov', 'новый', 'nov'),
  Adjective('star', 'старый', 'star'),
  Adjective('velik', 'большой', 'velik'),
  Adjective('mali', 'маленький', 'mal'),
  Adjective(
    'dobar',
    'хороший',
    'dobr',
    note: 'Беглое «а» пропадает: dobar → dobri, dobrog.',
  ),
  Adjective('mlad', 'молодой', 'mlad'),
  Adjective('visok', 'высокий', 'visok'),
  Adjective(
    'hladan',
    'холодный',
    'hladn',
    note: 'Беглое «а» пропадает: hladan → hladni, hladnog.',
  ),
  Adjective(
    'topao',
    'тёплый',
    'topl',
    note: 'Основа topl-: topao → topli, toplog.',
  ),
  Adjective('zanimljiv', 'интересный', 'zanimljiv'),
  Adjective(
    'pametan',
    'умный',
    'pametn',
    note: 'Беглое «а» пропадает: pametan → pametni.',
  ),
  Adjective('srpski', 'сербский', 'srpsk'),
  Adjective('crven', 'красный', 'crven'),
  Adjective('beo', 'белый', 'bel', note: 'Основа bel-: beo → beli, belog.'),
  Adjective('crn', 'чёрный', 'crn'),
  Adjective(
    'težak',
    'трудный, тяжёлый',
    'tešk',
    note: 'Основа tešk-: težak → teški, teškog.',
  ),
  Adjective('lak', 'лёгкий', 'lak'),
  Adjective('dug', 'длинный', 'dug'),
  Adjective(
    'kratak',
    'короткий',
    'kratk',
    note: 'Беглое «а» пропадает: kratak → kratki.',
  ),
  Adjective('jak', 'сильный', 'jak'),
  Adjective('brz', 'быстрый', 'brz'),
  Adjective(
    'vredan',
    'усердный',
    'vredn',
    note: 'Беглое «а» пропадает: vredan -> vredni.',
  ),
  Adjective('gladan', 'голодный', 'gladn'),
  Adjective('žedan', 'жаждущий', 'žedn'),
  Adjective('umoran', 'усталый', 'umorn'),
  Adjective('srećan', 'счастливый', 'srećn'),
  Adjective('tužan', 'грустный', 'tužn'),
  Adjective('važan', 'важный', 'važn'),
  Adjective('prazan', 'пустой', 'prazn'),
  Adjective('pun', 'полный', 'pun'),
  Adjective('čist', 'чистый', 'čist'),
  Adjective('prljav', 'грязный', 'prljav'),
  Adjective('bogat', 'богатый', 'bogat'),
  Adjective('poznat', 'известный', 'poznat'),
  Adjective(
    'veseo',
    'весёлый',
    'vesel',
    note: 'Основа vesel-: veseo -> veseli, veselog.',
  ),
  Adjective('ljubazan', 'любезный', 'ljubazn'),
  Adjective('opasan', 'опасный', 'opasn'),
  Adjective('slobodan', 'свободный', 'slobodn'),
  Adjective('zauzet', 'занятый', 'zauzet'),
  Adjective('glavni', 'главный', 'glavn'),
  Adjective('tih', 'тихий', 'tih'),
  Adjective('glasan', 'громкий', 'glasn'),
  Adjective(
    'sladak',
    'сладкий',
    'slatk',
    note: 'Основа slatk-: sladak -> slatki, slatkog.',
  ),
  Adjective('zdrav', 'здоровый', 'zdrav'),
  Adjective('bolestan', 'больной', 'bolesn'),
];

/// Прилагательные, которые сочетаются почти с любым существительным.
///
/// Из них строятся словосочетания в тренировке: со случайным прилагательным
/// пары получались бы вроде «богатое письмо».
const List<String> _commonLemmas = [
  'lep',
  'nov',
  'star',
  'velik',
  'mali',
  'dobar',
  'zanimljiv',
  'srpski',
  'poznat',
  'važan',
  'glavni',
  'čist',
  'skup',
  'lak',
  'težak',
  'dug',
  'kratak',
  'tih',
  'prazan',
  'pun',
];

/// Прилагательные для тренировки словосочетаний.
final List<Adjective> kCommonAdjectives = kAdjectives
    .where((a) => _commonLemmas.contains(a.lemma))
    .toList();

/// Окончания прилагательного определённого вида.
///
/// Порядок внутри списка - как в [GramCase.values].
const Map<Gender, List<String>> _singularEndings = {
  Gender.masculine: ['i', 'og', 'om', 'i', 'i', 'im', 'om'],
  Gender.feminine: ['a', 'e', 'oj', 'u', 'a', 'om', 'oj'],
  Gender.neuter: ['o', 'og', 'om', 'o', 'o', 'im', 'om'],
};

const Map<Gender, List<String>> _pluralEndings = {
  Gender.masculine: ['i', 'ih', 'im', 'e', 'i', 'im', 'im'],
  Gender.feminine: ['e', 'ih', 'im', 'e', 'e', 'im', 'im'],
  Gender.neuter: ['a', 'ih', 'im', 'a', 'a', 'im', 'im'],
};

/// Окончание прилагательного для заданной формы.
///
/// У одушевлённых слов мужского рода винительный падеж единственного числа
/// совпадает с родительным - ровно как у существительного.
String adjectiveEnding({
  required Gender gender,
  required GramCase gramCase,
  required GramNumber number,
  bool animate = false,
}) {
  if (number == GramNumber.singular &&
      gender == Gender.masculine &&
      gramCase == GramCase.akuzativ &&
      animate) {
    return 'og';
  }
  final table = number == GramNumber.singular
      ? _singularEndings
      : _pluralEndings;
  return table[gender]![gramCase.index];
}

/// Форма прилагательного, согласованная с существительным.
String adjectiveForm(
  Adjective adjective, {
  required Gender gender,
  required GramCase gramCase,
  required GramNumber number,
  bool animate = false,
}) =>
    adjective.stem +
    adjectiveEnding(
      gender: gender,
      gramCase: gramCase,
      number: number,
      animate: animate,
    );

/// Строки таблицы окончаний прилагательного для одного падежа -
/// используются в правиле, которое можно открыть прямо в тренировке.
List<EndingRow> adjectiveEndingRows(GramCase gramCase) {
  String ending(Gender gender, GramNumber number) =>
      '-'
      '${adjectiveEnding(gender: gender, gramCase: gramCase, number: number)}';

  String sg(Gender g) => ending(g, GramNumber.singular);
  String pl(Gender g) => ending(g, GramNumber.plural);

  final animateNote = gramCase == GramCase.akuzativ
      ? ' (у одушевлённых -og: vidim lepog konja)'
      : '';

  /// Пример «прилагательное + существительное» в этой же форме.
  String example(String lemma, Gender gender, GramNumber number) {
    final noun = kNounsByLemma[lemma]!;
    final adjective = adjectiveForm(
      kAdjectives.first,
      gender: gender,
      gramCase: gramCase,
      number: number,
    );
    return '$adjective ${noun.form(gramCase, number)}';
  }

  return [
    EndingRow(
      'м. р.',
      '${sg(Gender.masculine)}$animateNote',
      pl(Gender.masculine),
      example:
          '${example('grad', Gender.masculine, GramNumber.singular)} / '
          '${example('grad', Gender.masculine, GramNumber.plural)}',
    ),
    EndingRow(
      'ж. р.',
      sg(Gender.feminine),
      pl(Gender.feminine),
      example:
          '${example('žena', Gender.feminine, GramNumber.singular)} / '
          '${example('žena', Gender.feminine, GramNumber.plural)}',
    ),
    EndingRow(
      'ср. р.',
      sg(Gender.neuter),
      pl(Gender.neuter),
      example:
          '${example('selo', Gender.neuter, GramNumber.singular)} / '
          '${example('selo', Gender.neuter, GramNumber.plural)}',
    ),
  ];
}
