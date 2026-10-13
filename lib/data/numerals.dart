import 'package:srpski_padezi/models/models.dart';

/// Количественное числительное и его порядковая пара.
class Numeral {
  const new(this.value, this.cardinal, this.ordinal, {this.collective});

  final int value;

  /// Количественное: pet.
  final String cardinal;

  /// Порядковое, форма мужского рода: peti.
  final String ordinal;

  /// Собирательное: petoro (есть не у всех чисел).
  final String? collective;
}

/// Числительные, которые приложение показывает и спрашивает.
const List<Numeral> kNumerals = [
  Numeral(1, 'jedan', 'prvi'),
  Numeral(2, 'dva', 'drugi', collective: 'dvoje'),
  Numeral(3, 'tri', 'treći', collective: 'troje'),
  Numeral(4, 'četiri', 'četvrti', collective: 'četvoro'),
  Numeral(5, 'pet', 'peti', collective: 'petoro'),
  Numeral(6, 'šest', 'šesti', collective: 'šestoro'),
  Numeral(7, 'sedam', 'sedmi', collective: 'sedmoro'),
  Numeral(8, 'osam', 'osmi', collective: 'osmoro'),
  Numeral(9, 'devet', 'deveti', collective: 'devetoro'),
  Numeral(10, 'deset', 'deseti', collective: 'desetoro'),
  Numeral(11, 'jedanaest', 'jedanaesti'),
  Numeral(12, 'dvanaest', 'dvanaesti'),
  Numeral(13, 'trinaest', 'trinaesti'),
  Numeral(14, 'četrnaest', 'četrnaesti'),
  Numeral(15, 'petnaest', 'petnaesti'),
  Numeral(16, 'šesnaest', 'šesnaesti'),
  Numeral(17, 'sedamnaest', 'sedamnaesti'),
  Numeral(18, 'osamnaest', 'osamnaesti'),
  Numeral(19, 'devetnaest', 'devetnaesti'),
  Numeral(20, 'dvadeset', 'dvadeseti'),
  Numeral(30, 'trideset', 'trideseti'),
  Numeral(40, 'četrdeset', 'četrdeseti'),
  Numeral(50, 'pedeset', 'pedeseti'),
  Numeral(60, 'šezdeset', 'šezdeseti'),
  Numeral(70, 'sedamdeset', 'sedamdeseti'),
  Numeral(80, 'osamdeset', 'osamdeseti'),
  Numeral(90, 'devedeset', 'devedeseti'),
  Numeral(100, 'sto', 'stoti'),
  Numeral(200, 'dvesta', 'dvestoti'),
  Numeral(300, 'trista', 'tristoti'),
  Numeral(1000, 'hiljadu', 'hiljaditi'),
];

const Map<int, String> _hundreds = {
  1: 'sto',
  2: 'dvesta',
  3: 'trista',
  4: 'četiristo',
  5: 'petsto',
  6: 'šeststo',
  7: 'sedamsto',
  8: 'osamsto',
  9: 'devetsto',
};

const Map<int, String> _units = {
  1: 'jedan',
  2: 'dva',
  3: 'tri',
  4: 'četiri',
  5: 'pet',
  6: 'šest',
  7: 'sedam',
  8: 'osam',
  9: 'devet',
};

const Map<int, String> _teens = {
  10: 'deset',
  11: 'jedanaest',
  12: 'dvanaest',
  13: 'trinaest',
  14: 'četrnaest',
  15: 'petnaest',
  16: 'šesnaest',
  17: 'sedamnaest',
  18: 'osamnaest',
  19: 'devetnaest',
};

const Map<int, String> _tens = {
  2: 'dvadeset',
  3: 'trideset',
  4: 'četrdeset',
  5: 'pedeset',
  6: 'šezdeset',
  7: 'sedamdeset',
  8: 'osamdeset',
  9: 'devedeset',
};

/// Записывает число словами по-сербски (от 1 до 1000).
String spellNumber(int n) {
  if (n == 1000) return 'hiljadu';
  final parts = <String>[];
  final hundreds = n ~/ 100;
  final rest = n % 100;
  if (hundreds > 0) parts.add(_hundreds[hundreds]!);
  if (rest >= 10 && rest <= 19) {
    parts.add(_teens[rest]!);
  } else {
    final tens = rest ~/ 10;
    final units = rest % 10;
    if (tens > 0) parts.add(_tens[tens]!);
    if (units > 0) parts.add(_units[units]!);
  }
  return parts.join(' ');
}

/// Какую форму существительного требует числительное.
enum NumeralAgreement {
  /// jedan grad - именительный падеж единственного числа.
  nominativeSingular,

  /// dva grada - родительный падеж единственного числа (остаток двойственного).
  genitiveSingular,

  /// pet gradova - родительный падеж множественного числа.
  genitivePlural,
}

extension NumeralAgreementX on NumeralAgreement {
  GramCase get gramCase => this == NumeralAgreement.nominativeSingular
      ? GramCase.nominativ
      : GramCase.genitiv;

  GramNumber get number => this == NumeralAgreement.genitivePlural
      ? GramNumber.plural
      : GramNumber.singular;

  String get ru => switch (this) {
    NumeralAgreement.nominativeSingular =>
      'именительный падеж единственного числа',
    NumeralAgreement.genitiveSingular =>
      'родительный падеж единственного числа',
    NumeralAgreement.genitivePlural => 'родительный падеж множественного числа',
  };
}

/// Определяет форму существительного после числительного.
///
/// Решает последняя цифра числа, но 11-14 всегда требуют родительного
/// падежа множественного числа.
NumeralAgreement agreementFor(int n) {
  final lastTwo = n % 100;
  if (lastTwo >= 11 && lastTwo <= 14) return NumeralAgreement.genitivePlural;
  final last = n % 10;
  if (last == 1) return NumeralAgreement.nominativeSingular;
  if (last >= 2 && last <= 4) return NumeralAgreement.genitiveSingular;
  return NumeralAgreement.genitivePlural;
}

/// Форма числительного 1 или 2 в зависимости от рода существительного.
///
/// Только эти два числительных меняются по родам; начиная с пяти форма
/// одна для всех родов.
String? genderedNumeralForm(int n, Gender gender) {
  final last = n % 10;
  final lastTwo = n % 100;
  if (lastTwo >= 11 && lastTwo <= 14) return null;
  if (last == 1) {
    return switch (gender) {
      Gender.masculine => 'jedan',
      Gender.feminine => 'jedna',
      Gender.neuter => 'jedno',
    };
  }
  if (last == 2) {
    return gender == Gender.feminine ? 'dve' : 'dva';
  }
  return null;
}

/// Теория по числительным.
const List<TopicSection> kNumeralTopics = [
  TopicSection(
    title: 'Главное правило: падеж после числительного',
    body:
        'В сербском языке числительное управляет существительным так же, как в '
        'русском, и правило зависит от последней цифры числа. Именно это '
        'правило '
        'связывает тему числительных с падежами: без родительного падежа '
        'посчитать по-сербски не получится.',
    bullets: [
      '…1 (кроме 11) → именительный падеж единственного числа: jedan grad, '
          'dvadeset jedan grad.',
      '…2, 3, 4 (кроме 12, 13, 14) → родительный падеж единственного числа: '
          'dva grada, tri žene, dvadeset četiri sela.',
      '5 и больше, а также 11-14 → родительный падеж множественного числа: '
          'pet gradova, jedanaest žena, sto gradova.',
      'Глагол согласуется по-разному: Dva studenta su došla, но '
          'Pet studenata je došlo.',
    ],
    examples: [
      Example(
        'jedan grad, dva grada, pet gradova',
        'один город, два города, пять городов',
      ),
      Example(
        'jedna knjiga, dve knjige, pet knjiga',
        'одна книга, две книги, пять книг',
      ),
      Example(
        'jedno selo, dva sela, pet sela',
        'одно село, два села, пять сёл',
      ),
    ],
  ),
  TopicSection(
    title: 'Числительные 1 и 2 меняются по родам',
    body:
        'Только jedan и dva согласуются с существительным в роде. Начиная с '
        'трёх '
        'форма числительного одна для всех родов. Слово jedan склоняется как '
        'прилагательное: jednog grada, jednoj ženi.',
    bullets: [
      'jedan grad - jedna knjiga - jedno selo.',
      'dva grada - dve knjige - dva sela (средний род идёт с формой dva).',
      'То же у слова «оба»: oba grada - obe knjige - oba sela.',
      'Начиная с трёх род не важен: tri grada, tri knjige, tri sela.',
    ],
    examples: [
      Example(
        'Imam jednu sestru i dva brata.',
        'У меня одна сестра и два брата.',
      ),
      Example('Kupila sam dve knjige.', 'Я купила две книги.'),
    ],
  ),
  TopicSection(
    title: 'Порядковые числительные',
    body:
        'Порядковые числительные (prvi, drugi, treći) - это фактически '
        'прилагательные: они склоняются по падежам, родам и числам. В датах '
        'они стоят в родительном падеже: prvog maja - первого мая.',
    bullets: [
      'prvi - prva - prvo, drugi - druga - drugo, treći - treća - treće.',
      'Начиная с четырёх образуются регулярно: četvrti, peti, šesti, sedmi…',
      'У составных чисел меняется только последнее слово: dvadeset prvi.',
      'В датах и с предлогами - обычные окончания прилагательных: '
          'u petom razredu, dvadeset prvog juna.',
    ],
    examples: [
      Example(
        'Ovo je moj prvi dan u Beogradu.',
        'Это мой первый день в Белграде.',
      ),
      Example('Živim na trećem spratu.', 'Я живу на третьем этаже.'),
      Example('Rođen sam petog marta.', 'Я родился пятого марта.'),
    ],
  ),
  TopicSection(
    title: 'Собирательные числительные',
    body:
        'Собирательные числительные (dvoje, troje, četvoro) используют для '
        'смешанных групп людей и для детей - примерно как русское '
        '«двое, трое». '
        'Для группы только из мужчин есть особые формы на -ica: dvojica, '
        'trojica. После собирательных числительных существительное стоит в '
        'родительном падеже множественного числа.',
    bullets: [
      'dvoje dece, troje ljudi - смешанная группа или дети.',
      'dvojica muškaraca, trojica prijatelja - только мужчины.',
      'dve žene, tri žene - только женщины (обычное числительное).',
      'После собирательных - родительный падеж множественного числа.',
    ],
    examples: [
      Example('U sobi je troje dece.', 'В комнате трое детей.'),
      Example('Došla su dvojica prijatelja.', 'Пришли двое друзей.'),
    ],
  ),
  TopicSection(
    title: 'Как считать до тысячи',
    body:
        'Числа от 11 до 19 образуются с помощью -naest, десятки - с помощью '
        '-deset, сотни пишутся слитно: dvesta, trista, četiristo. Составные '
        'числа читаются слева направо без союзов: sto dvadeset pet.',
    bullets: [
      '11-19: jedanaest, dvanaest, trinaest, četrnaest, petnaest, šesnaest, '
          'sedamnaest, osamnaest, devetnaest.',
      'Десятки: dvadeset, trideset, četrdeset, pedeset, šezdeset, sedamdeset, '
          'osamdeset, devedeset.',
      'Сотни: sto, dvesta, trista, četiristo, petsto, šeststo, sedamsto, '
          'osamsto, devetsto.',
      'Тысяча - hiljadu (форма hiljada употребляется как существительное).',
    ],
    examples: [
      Example('sto dvadeset pet', 'сто двадцать пять'),
      Example('Imam dvadeset pet godina.', 'Мне двадцать пять лет.'),
      Example('Koliko je sati? - Pet sati.', 'Который час? - Пять часов.'),
    ],
  ),
];
