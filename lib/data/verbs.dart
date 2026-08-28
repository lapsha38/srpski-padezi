import 'package:srpski_padezi/models/models.dart';

/// Тип спряжения в настоящем времени: по окончанию первого лица.
enum Conjugation { am, im, em }

extension ConjugationX on Conjugation {
  String get title => switch (this) {
    Conjugation.am => 'спряжение на -am',
    Conjugation.im => 'спряжение на -im',
    Conjugation.em => 'спряжение на -em',
  };

  /// Окончания настоящего времени по лицам.
  List<String> get endings => switch (this) {
    Conjugation.am => ['-am', '-aš', '-a', '-amo', '-ate', '-aju'],
    Conjugation.im => ['-im', '-iš', '-i', '-imo', '-ite', '-e'],
    Conjugation.em => ['-em', '-eš', '-e', '-emo', '-ete', '-u'],
  };
}

/// Лицо и число подлежащего.
enum Person { firstSg, secondSg, thirdSg, firstPl, secondPl, thirdPl }

/// Подлежащее задания: местоимение, его род и лицо.
///
/// Род нужен для прошедшего времени: причастие согласуется с подлежащим
/// (on je radio - ona je radila).
class Subject {
  const Subject(this.pronoun, this.ru, this.person, this.gender);

  final String pronoun;
  final String ru;
  final Person person;
  final Gender gender;

  bool get isPlural => person.index >= 3;
}

const List<Subject> kSubjects = [
  Subject('ja', 'я (муж.)', Person.firstSg, Gender.masculine),
  Subject('ja', 'я (жен.)', Person.firstSg, Gender.feminine),
  Subject('ti', 'ты (муж.)', Person.secondSg, Gender.masculine),
  Subject('ti', 'ты (жен.)', Person.secondSg, Gender.feminine),
  Subject('on', 'он', Person.thirdSg, Gender.masculine),
  Subject('ona', 'она', Person.thirdSg, Gender.feminine),
  Subject('ono', 'оно', Person.thirdSg, Gender.neuter),
  Subject('mi', 'мы (муж.)', Person.firstPl, Gender.masculine),
  Subject('mi', 'мы (жен.)', Person.firstPl, Gender.feminine),
  Subject('vi', 'вы (муж.)', Person.secondPl, Gender.masculine),
  Subject('vi', 'вы (жен.)', Person.secondPl, Gender.feminine),
  Subject('oni', 'они (муж.)', Person.thirdPl, Gender.masculine),
  Subject('one', 'они (жен.)', Person.thirdPl, Gender.feminine),
];

/// Краткие формы вспомогательного глагола biti - перфект.
const List<String> kPerfectAux = ['sam', 'si', 'je', 'smo', 'ste', 'su'];

/// Отрицательные формы biti.
const List<String> kNegatedBiti = [
  'nisam',
  'nisi',
  'nije',
  'nismo',
  'niste',
  'nisu',
];

/// Полные формы biti - употребляются под ударением и в ответах.
const List<String> kFullBiti = [
  'jesam',
  'jesi',
  'jeste',
  'jesmo',
  'jeste',
  'jesu',
];

/// Краткие формы hteti - будущее время.
const List<String> kFutureAux = ['ću', 'ćeš', 'će', 'ćemo', 'ćete', 'će'];

/// Отрицательные формы hteti.
const List<String> kNegatedFuture = [
  'neću',
  'nećeš',
  'neće',
  'nećemo',
  'nećete',
  'neće',
];

/// Отрицательные формы imati.
const List<String> kNegatedImati = [
  'nemam',
  'nemaš',
  'nema',
  'nemamo',
  'nemate',
  'nemaju',
];

/// Глагол со всеми формами, которые нужны приложению.
class Verb {
  const Verb({
    required this.infinitive,
    required this.ru,
    required this.conjugation,
    required this.present,
    required this.participle,
    this.imperative,
    this.perfective = false,
    this.futureStem,
    this.note,
  });

  final String infinitive;
  final String ru;
  final Conjugation conjugation;

  /// Шесть форм настоящего времени в порядке [Person.values].
  final List<String> present;

  /// Причастие прошедшего времени: [муж., жен., ср., мн. муж., мн. жен.,
  /// мн. ср.].
  final List<String> participle;

  /// Повелительное наклонение: [ты, мы, вы]; null - если не образуется.
  final List<String>? imperative;

  /// Совершенный вид.
  final bool perfective;

  /// Основа слитного будущего времени, если она не выводится из инфинитива
  /// отбрасыванием -ti (jesti → ješću).
  final String? futureStem;

  final String? note;

  String presentFor(Person p) => present[p.index];

  /// Причастие, согласованное с подлежащим.
  String participleFor(Subject s) {
    final offset = s.isPlural ? 3 : 0;
    return participle[offset + s.gender.index];
  }

  /// Будущее время стягивается только у глаголов на -ti: radiću, но ja ću ići.
  bool get contractsFuture => infinitive.endsWith('ti');

  /// Стяжённая форма будущего времени: raditi + ću → radiću.
  String contractedFuture(Person p) {
    final stem = futureStem ?? infinitive.substring(0, infinitive.length - 2);
    return '$stem${kFutureAux[p.index]}';
  }
}

/// Словарь глаголов.
const List<Verb> kVerbs = [
  Verb(
    infinitive: 'raditi',
    ru: 'работать, делать',
    conjugation: Conjugation.im,
    present: ['radim', 'radiš', 'radi', 'radimo', 'radite', 'rade'],
    participle: ['radio', 'radila', 'radilo', 'radili', 'radile', 'radila'],
    imperative: ['radi', 'radimo', 'radite'],
  ),
  Verb(
    infinitive: 'govoriti',
    ru: 'говорить',
    conjugation: Conjugation.im,
    present: [
      'govorim',
      'govoriš',
      'govori',
      'govorimo',
      'govorite',
      'govore',
    ],
    participle: [
      'govorio',
      'govorila',
      'govorilo',
      'govorili',
      'govorile',
      'govorila',
    ],
    imperative: ['govori', 'govorimo', 'govorite'],
  ),
  Verb(
    infinitive: 'učiti',
    ru: 'учить',
    conjugation: Conjugation.im,
    present: ['učim', 'učiš', 'uči', 'učimo', 'učite', 'uče'],
    participle: ['učio', 'učila', 'učilo', 'učili', 'učile', 'učila'],
    imperative: ['uči', 'učimo', 'učite'],
  ),
  Verb(
    infinitive: 'živeti',
    ru: 'жить',
    conjugation: Conjugation.im,
    present: ['živim', 'živiš', 'živi', 'živimo', 'živite', 'žive'],
    participle: ['živeo', 'živela', 'živelo', 'živeli', 'živele', 'živela'],
    imperative: ['živi', 'živimo', 'živite'],
  ),
  Verb(
    infinitive: 'videti',
    ru: 'видеть',
    conjugation: Conjugation.im,
    present: ['vidim', 'vidiš', 'vidi', 'vidimo', 'vidite', 'vide'],
    participle: ['video', 'videla', 'videlo', 'videli', 'videle', 'videla'],
    imperative: ['vidi', 'vidimo', 'vidite'],
  ),
  Verb(
    infinitive: 'voleti',
    ru: 'любить',
    conjugation: Conjugation.im,
    present: ['volim', 'voliš', 'voli', 'volimo', 'volite', 'vole'],
    participle: ['voleo', 'volela', 'volelo', 'voleli', 'volele', 'volela'],
    imperative: ['voli', 'volimo', 'volite'],
  ),
  Verb(
    infinitive: 'kupiti',
    ru: 'купить',
    conjugation: Conjugation.im,
    perfective: true,
    present: ['kupim', 'kupiš', 'kupi', 'kupimo', 'kupite', 'kupe'],
    participle: ['kupio', 'kupila', 'kupilo', 'kupili', 'kupile', 'kupila'],
    imperative: ['kupi', 'kupimo', 'kupite'],
  ),
  Verb(
    infinitive: 'gledati',
    ru: 'смотреть',
    conjugation: Conjugation.am,
    present: [
      'gledam',
      'gledaš',
      'gleda',
      'gledamo',
      'gledate',
      'gledaju',
    ],
    participle: [
      'gledao',
      'gledala',
      'gledalo',
      'gledali',
      'gledale',
      'gledala',
    ],
    imperative: ['gledaj', 'gledajmo', 'gledajte'],
  ),
  Verb(
    infinitive: 'čitati',
    ru: 'читать',
    conjugation: Conjugation.am,
    present: ['čitam', 'čitaš', 'čita', 'čitamo', 'čitate', 'čitaju'],
    participle: [
      'čitao',
      'čitala',
      'čitalo',
      'čitali',
      'čitale',
      'čitala',
    ],
    imperative: ['čitaj', 'čitajmo', 'čitajte'],
  ),
  Verb(
    infinitive: 'slušati',
    ru: 'слушать',
    conjugation: Conjugation.am,
    present: [
      'slušam',
      'slušaš',
      'sluša',
      'slušamo',
      'slušate',
      'slušaju',
    ],
    participle: [
      'slušao',
      'slušala',
      'slušalo',
      'slušali',
      'slušale',
      'slušala',
    ],
    imperative: ['slušaj', 'slušajmo', 'slušajte'],
  ),
  Verb(
    infinitive: 'pitati',
    ru: 'спрашивать',
    conjugation: Conjugation.am,
    present: ['pitam', 'pitaš', 'pita', 'pitamo', 'pitate', 'pitaju'],
    participle: [
      'pitao',
      'pitala',
      'pitalo',
      'pitali',
      'pitale',
      'pitala',
    ],
    imperative: ['pitaj', 'pitajmo', 'pitajte'],
  ),
  Verb(
    infinitive: 'spavati',
    ru: 'спать',
    conjugation: Conjugation.am,
    present: [
      'spavam',
      'spavaš',
      'spava',
      'spavamo',
      'spavate',
      'spavaju',
    ],
    participle: [
      'spavao',
      'spavala',
      'spavalo',
      'spavali',
      'spavale',
      'spavala',
    ],
    imperative: ['spavaj', 'spavajmo', 'spavajte'],
  ),
  Verb(
    infinitive: 'znati',
    ru: 'знать',
    conjugation: Conjugation.am,
    present: ['znam', 'znaš', 'zna', 'znamo', 'znate', 'znaju'],
    participle: ['znao', 'znala', 'znalo', 'znali', 'znale', 'znala'],
    imperative: ['znaj', 'znajmo', 'znajte'],
  ),
  Verb(
    infinitive: 'imati',
    ru: 'иметь',
    conjugation: Conjugation.am,
    present: ['imam', 'imaš', 'ima', 'imamo', 'imate', 'imaju'],
    participle: ['imao', 'imala', 'imalo', 'imali', 'imale', 'imala'],
    imperative: ['imaj', 'imajmo', 'imajte'],
    note: 'Отрицание сливается с глаголом: nemam, nemaš, nema.',
  ),
  Verb(
    infinitive: 'pisati',
    ru: 'писать',
    conjugation: Conjugation.em,
    present: ['pišem', 'pišeš', 'piše', 'pišemo', 'pišete', 'pišu'],
    participle: [
      'pisao',
      'pisala',
      'pisalo',
      'pisali',
      'pisale',
      'pisala',
    ],
    imperative: ['piši', 'pišimo', 'pišite'],
    note: 'В настоящем времени основа меняется: pisati → pišem.',
  ),
  Verb(
    infinitive: 'ići',
    ru: 'идти',
    conjugation: Conjugation.em,
    present: ['idem', 'ideš', 'ide', 'idemo', 'idete', 'idu'],
    participle: ['išao', 'išla', 'išlo', 'išli', 'išle', 'išla'],
    imperative: ['idi', 'idimo', 'idite'],
    note:
        'Неправильный глагол: ići → idem, išao. Будущее не стягивается: '
        'ja ću ići.',
  ),
  Verb(
    infinitive: 'doći',
    ru: 'прийти',
    conjugation: Conjugation.em,
    perfective: true,
    present: ['dođem', 'dođeš', 'dođe', 'dođemo', 'dođete', 'dođu'],
    participle: ['došao', 'došla', 'došlo', 'došli', 'došle', 'došla'],
    imperative: ['dođi', 'dođimo', 'dođite'],
  ),
  Verb(
    infinitive: 'jesti',
    ru: 'есть',
    conjugation: Conjugation.em,
    present: ['jedem', 'jedeš', 'jede', 'jedemo', 'jedete', 'jedu'],
    participle: ['jeo', 'jela', 'jelo', 'jeli', 'jele', 'jela'],
    imperative: ['jedi', 'jedimo', 'jedite'],
    futureStem: 'ješ',
    note: 'В будущем времени основа меняется: jesti → ješću.',
  ),
  Verb(
    infinitive: 'piti',
    ru: 'пить',
    conjugation: Conjugation.em,
    present: ['pijem', 'piješ', 'pije', 'pijemo', 'pijete', 'piju'],
    participle: ['pio', 'pila', 'pilo', 'pili', 'pile', 'pila'],
    imperative: ['pij', 'pijmo', 'pijte'],
  ),
  Verb(
    infinitive: 'putovati',
    ru: 'путешествовать',
    conjugation: Conjugation.em,
    present: [
      'putujem',
      'putuješ',
      'putuje',
      'putujemo',
      'putujete',
      'putuju',
    ],
    participle: [
      'putovao',
      'putovala',
      'putovalo',
      'putovali',
      'putovale',
      'putovala',
    ],
    imperative: ['putuj', 'putujmo', 'putujte'],
    note: 'Глаголы на -ovati в настоящем времени дают -ujem: putujem.',
  ),
  Verb(
    infinitive: 'reći',
    ru: 'сказать',
    conjugation: Conjugation.em,
    perfective: true,
    present: ['kažem', 'kažeš', 'kaže', 'kažemo', 'kažete', 'kažu'],
    participle: ['rekao', 'rekla', 'reklo', 'rekli', 'rekle', 'rekla'],
    imperative: ['reci', 'recimo', 'recite'],
    note: 'Неправильный глагол: reći → kažem, rekao.',
  ),
  Verb(
    infinitive: 'moći',
    ru: 'мочь',
    conjugation: Conjugation.em,
    present: ['mogu', 'možeš', 'može', 'možemo', 'možete', 'mogu'],
    participle: ['mogao', 'mogla', 'moglo', 'mogli', 'mogle', 'mogla'],
    note: 'Первое лицо - mogu (без -em), третье лицо множественного тоже mogu.',
  ),
  Verb(
    infinitive: 'hteti',
    ru: 'хотеть',
    conjugation: Conjugation.em,
    present: ['hoću', 'hoćeš', 'hoće', 'hoćemo', 'hoćete', 'hoće'],
    participle: ['hteo', 'htela', 'htelo', 'hteli', 'htele', 'htela'],
    note: 'Краткие формы этого глагола (ću, ćeš, će) образуют будущее время.',
  ),
  Verb(
    infinitive: 'misliti',
    ru: 'думать',
    conjugation: Conjugation.im,
    present: ['mislim', 'misliš', 'misli', 'mislimo', 'mislite', 'misle'],
    participle: [
      'mislio',
      'mislila',
      'mislilo',
      'mislili',
      'mislile',
      'mislila',
    ],
    imperative: ['misli', 'mislimo', 'mislite'],
  ),
  Verb(
    infinitive: 'želeti',
    ru: 'желать, хотеть',
    conjugation: Conjugation.im,
    present: ['želim', 'želiš', 'želi', 'želimo', 'želite', 'žele'],
    participle: ['želeo', 'želela', 'želelo', 'želeli', 'želele', 'želela'],
    imperative: ['želi', 'želimo', 'želite'],
  ),
  Verb(
    infinitive: 'sedeti',
    ru: 'сидеть',
    conjugation: Conjugation.im,
    present: ['sedim', 'sediš', 'sedi', 'sedimo', 'sedite', 'sede'],
    participle: ['sedeo', 'sedela', 'sedelo', 'sedeli', 'sedele', 'sedela'],
    imperative: ['sedi', 'sedimo', 'sedite'],
  ),
  Verb(
    infinitive: 'nositi',
    ru: 'нести, носить',
    conjugation: Conjugation.im,
    present: ['nosim', 'nosiš', 'nosi', 'nosimo', 'nosite', 'nose'],
    participle: ['nosio', 'nosila', 'nosilo', 'nosili', 'nosile', 'nosila'],
    imperative: ['nosi', 'nosimo', 'nosite'],
  ),
  Verb(
    infinitive: 'otvoriti',
    ru: 'открыть',
    conjugation: Conjugation.im,
    perfective: true,
    present: [
      'otvorim',
      'otvoriš',
      'otvori',
      'otvorimo',
      'otvorite',
      'otvore',
    ],
    participle: [
      'otvorio',
      'otvorila',
      'otvorilo',
      'otvorili',
      'otvorile',
      'otvorila',
    ],
    imperative: ['otvori', 'otvorimo', 'otvorite'],
  ),
  Verb(
    infinitive: 'trčati',
    ru: 'бежать',
    conjugation: Conjugation.im,
    present: ['trčim', 'trčiš', 'trči', 'trčimo', 'trčite', 'trče'],
    participle: ['trčao', 'trčala', 'trčalo', 'trčali', 'trčale', 'trčala'],
    imperative: ['trči', 'trčimo', 'trčite'],
  ),
  Verb(
    infinitive: 'kuvati',
    ru: 'готовить',
    conjugation: Conjugation.am,
    present: ['kuvam', 'kuvaš', 'kuva', 'kuvamo', 'kuvate', 'kuvaju'],
    participle: ['kuvao', 'kuvala', 'kuvalo', 'kuvali', 'kuvale', 'kuvala'],
    imperative: ['kuvaj', 'kuvajmo', 'kuvajte'],
  ),
  Verb(
    infinitive: 'pevati',
    ru: 'петь',
    conjugation: Conjugation.am,
    present: ['pevam', 'pevaš', 'peva', 'pevamo', 'pevate', 'pevaju'],
    participle: ['pevao', 'pevala', 'pevalo', 'pevali', 'pevale', 'pevala'],
    imperative: ['pevaj', 'pevajmo', 'pevajte'],
  ),
  Verb(
    infinitive: 'igrati',
    ru: 'играть',
    conjugation: Conjugation.am,
    present: ['igram', 'igraš', 'igra', 'igramo', 'igrate', 'igraju'],
    participle: ['igrao', 'igrala', 'igralo', 'igrali', 'igrale', 'igrala'],
    imperative: ['igraj', 'igrajmo', 'igrajte'],
  ),
  Verb(
    infinitive: 'morati',
    ru: 'быть должным',
    conjugation: Conjugation.am,
    present: ['moram', 'moraš', 'mora', 'moramo', 'morate', 'moraju'],
    participle: ['morao', 'morala', 'moralo', 'morali', 'morale', 'morala'],
    note: 'Обычно идёт с конструкцией da: moram da radim.',
  ),
  Verb(
    infinitive: 'razumeti',
    ru: 'понимать',
    conjugation: Conjugation.em,
    present: [
      'razumem',
      'razumeš',
      'razume',
      'razumemo',
      'razumete',
      'razumeju',
    ],
    participle: [
      'razumeo',
      'razumela',
      'razumelo',
      'razumeli',
      'razumele',
      'razumela',
    ],
  ),
  Verb(
    infinitive: 'zvati',
    ru: 'звать, звонить',
    conjugation: Conjugation.em,
    present: ['zovem', 'zoveš', 'zove', 'zovemo', 'zovete', 'zovu'],
    participle: ['zvao', 'zvala', 'zvalo', 'zvali', 'zvale', 'zvala'],
    imperative: ['zovi', 'zovimo', 'zovite'],
    note: 'В настоящем времени основа меняется: zvati -> zovem.',
  ),
  Verb(
    infinitive: 'kupovati',
    ru: 'покупать',
    conjugation: Conjugation.em,
    present: [
      'kupujem',
      'kupuješ',
      'kupuje',
      'kupujemo',
      'kupujete',
      'kupuju',
    ],
    participle: [
      'kupovao',
      'kupovala',
      'kupovalo',
      'kupovali',
      'kupovale',
      'kupovala',
    ],
    imperative: ['kupuj', 'kupujmo', 'kupujte'],
    note: 'Глаголы на -ovati в настоящем времени дают -ujem.',
  ),
  Verb(
    infinitive: 'početi',
    ru: 'начать',
    conjugation: Conjugation.em,
    perfective: true,
    present: ['počnem', 'počneš', 'počne', 'počnemo', 'počnete', 'počnu'],
    participle: ['počeo', 'počela', 'počelo', 'počeli', 'počele', 'počela'],
    imperative: ['počni', 'počnimo', 'počnite'],
    note: 'Основа настоящего времени počn-: početi -> počnem.',
  ),
];
