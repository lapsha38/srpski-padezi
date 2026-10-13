import 'package:srpski_padezi/models/models.dart';

/// Пропуск в тексте: слово, которое нужно поставить в форму.
///
/// Как и в заданиях с предложениями, правильная форма не хранится, а берётся
/// из словаря по [lemma], [gramCase] и [number].
class TextGap {
  const new(this.lemma, this.gramCase, this.number, this.hint);

  final String lemma;
  final GramCase gramCase;
  final GramNumber number;

  /// Почему здесь нужен именно этот падеж.
  final String hint;
}

/// Связный текст с пропусками.
class GapText {
  const new({
    required this.id,
    required this.title,
    required this.titleRu,
    required this.text,
    required this.gaps,
    required this.translation,
  });

  /// Ключ для сохранения результата; не меняется при правке текста.
  final String id;
  final String title;
  final String titleRu;

  /// Текст, где каждый пропуск обозначен `{}`; пропуски идут по порядку
  /// [gaps].
  final String text;
  final List<TextGap> gaps;

  /// Перевод всего текста - показывается после проверки.
  final String translation;

  /// Куски текста между пропусками: их на один больше, чем пропусков.
  List<String> get pieces => text.split(placeholder);

  static const String placeholder = '{}';
}

const GramNumber _sg = GramNumber.singular;
const GramNumber _pl = GramNumber.plural;
const GramCase _nom = GramCase.nominativ;
const GramCase _gen = GramCase.genitiv;
const GramCase _dat = GramCase.dativ;
const GramCase _akk = GramCase.akuzativ;
const GramCase _vok = GramCase.vokativ;
const GramCase _ins = GramCase.instrumental;
const GramCase _lok = GramCase.lokativ;

/// Тексты для режима «текст с пропусками», от простого к сложному.
const List<GapText> kGapTexts = [
  GapText(
    id: 'moj_dan',
    title: 'Moj dan',
    titleRu: 'Мой день',
    text:
        'Zovem se Ana i živim u {}. Ujutru pijem {} i čitam {} na '
        'telefonu. Na posao idem {}. Radim u {} blizu {}. Posle posla '
        'idem kod {}. Uveče pišem poruku {} i slušam {}.',
    gaps: [
      TextGap('grad', _lok, _sg, 'u + локатив отвечает на вопрос «где?».'),
      TextGap('kafa', _akk, _sg, 'Прямое дополнение: pijem šta? - аккузатив.'),
      TextGap('vest', _akk, _pl, 'Прямое дополнение: čitam šta? - аккузатив.'),
      TextGap(
        'autobus',
        _ins,
        _sg,
        'Средство передвижения - инструментал без предлога.',
      ),
      TextGap('banka', _lok, _sg, 'u + локатив: где? Ещё и k → c: banci.'),
      TextGap('reka', _gen, _sg, 'После blizu всегда генитив.'),
      TextGap('prijatelj', _gen, _pl, 'kod + генитив: к кому? у кого?'),
      TextGap('sestra', _dat, _sg, 'Кому пишу? - датив.'),
      TextGap('muzika', _akk, _sg, 'Прямое дополнение: slušam šta?'),
    ],
    translation:
        'Меня зовут Ана, я живу в городе. Утром я пью кофе и читаю новости '
        'в телефоне. На работу езжу на автобусе. Работаю в банке недалеко '
        'от реки. После работы хожу к друзьям. Вечером пишу сообщение '
        'сестре и слушаю музыку.',
  ),
  GapText(
    id: 'na_pijaci',
    title: 'Na pijaci',
    titleRu: 'На рынке',
    text:
        'Subotom idem na {} sa {}. Kupujemo {}, kilogram {} i malo {}. '
        'Na pijaci uvek sretnemo {}. Mama kupuje {} za {}. Posle zajedno '
        'spremamo ručak u {}.',
    gaps: [
      TextGap('pijaca', _akk, _sg, 'na + аккузатив - направление: куда?'),
      TextGap('majka', _ins, _sg, 'sa + инструментал - вместе с кем?'),
      TextGap('jabuka', _akk, _pl, 'Прямое дополнение: kupujemo šta?'),
      TextGap(
        'meso',
        _gen,
        _sg,
        'После слов меры (kilogram, litar) - генитив.',
      ),
      TextGap('so', _gen, _sg, 'После malo, mnogo - генитив.'),
      TextGap(
        'komšija',
        _akk,
        _sg,
        'Прямое дополнение. Слова мужского рода на -a склоняются как '
            'женские: komšiju.',
      ),
      TextGap('torta', _akk, _sg, 'Прямое дополнение: kupuje šta?'),
      TextGap('deda', _akk, _sg, 'za + аккузатив - для кого?'),
      TextGap('kuhinja', _lok, _sg, 'u + локатив: где?'),
    ],
    translation:
        'По субботам я хожу на рынок с мамой. Мы покупаем яблоки, '
        'килограмм мяса и немного соли. На рынке мы всегда встречаем '
        'соседа. Мама покупает торт для дедушки. Потом вместе готовим обед '
        'на кухне.',
  ),
  GapText(
    id: 'moja_porodica',
    title: 'Moja porodica',
    titleRu: 'Моя семья',
    text:
        'Moja porodica nije velika. Imam dva {} i jednu {}. Mama radi u {}, '
        'a tata je inženjer. Brat ide u {} sa svojim {}. Sestra mnogo voli '
        '{}. Nedeljom idemo kod {} i {}. Baka nam uvek peče {}. Kad se brat '
        'igra predugo, mama ga zove: „{}, dođi kući!“',
    gaps: [
      TextGap(
        'brat',
        _gen,
        _sg,
        'После dva, tri, četiri - форма родительного единственного числа.',
      ),
      TextGap('sestra', _akk, _sg, 'Прямое дополнение: imam koga?'),
      TextGap('bolnica', _lok, _sg, 'u + локатив: где работает?'),
      TextGap('škola', _akk, _sg, 'u + аккузатив - направление: куда?'),
      TextGap('prijatelj', _ins, _pl, 'sa + инструментал - с кем?'),
      TextGap(
        'pas',
        _akk,
        _pl,
        'Прямое дополнение. Во множественном числе аккузатив всегда на -e.',
      ),
      TextGap('baka', _gen, _sg, 'kod + генитив - у кого? к кому?'),
      TextGap('deda', _gen, _sg, 'kod + генитив; deda склоняется как žena.'),
      TextGap('kolač', _akk, _pl, 'Прямое дополнение: peče šta?'),
      TextGap('sin', _vok, _sg, 'Обращение - вокатив.'),
    ],
    translation:
        'Моя семья небольшая. У меня два брата и одна сестра. Мама работает '
        'в больнице, а папа инженер. Брат ходит в школу со своими друзьями. '
        'Сестра очень любит собак. По воскресеньям мы ездим к бабушке '
        'и дедушке. Бабушка всегда печёт нам пироги. Когда брат слишком '
        'долго играет, мама зовёт его: «Сынок, иди домой!»',
  ),
  GapText(
    id: 'nas_stan',
    title: 'Naš stan',
    titleRu: 'Наша квартира',
    text:
        'Naš stan je u novoj {} blizu {}. Ispred {} je mala prodavnica. '
        'U spavaćoj sobi su dva {}. U dnevnoj sobi ima mnogo {}. '
        'Iznad {} visi velika slika, a na {} je ogledalo. Pod {} uvek '
        'spava naša mačka. Moji {} kažu da je stan lep.',
    gaps: [
      TextGap('zgrada', _lok, _sg, 'u + локатив: где?'),
      TextGap('pošta', _gen, _sg, 'После blizu - генитив.'),
      TextGap('zgrada', _gen, _sg, 'После ispred - генитив.'),
      TextGap(
        'krevet',
        _gen,
        _sg,
        'После dva, tri, četiri - форма родительного единственного числа.',
      ),
      TextGap(
        'knjiga',
        _gen,
        _pl,
        'После mnogo - генитив множественного числа.',
      ),
      TextGap('prozor', _gen, _sg, 'После iznad - генитив.'),
      TextGap('zid', _lok, _sg, 'na + локатив: где?'),
      TextGap('sto', _ins, _sg, 'pod + инструментал - местонахождение: где?'),
      TextGap(
        'prijatelj',
        _nom,
        _pl,
        'Подлежащее - номинатив множественного числа.',
      ),
    ],
    translation:
        'Наша квартира в новом доме рядом с почтой. Перед домом маленький '
        'магазин. В спальне две кровати. В гостиной много книг. Над окном '
        'висит большая картина, а на стене зеркало. Под столом всегда спит '
        'наша кошка. Мои друзья говорят, что квартира красивая.',
  ),
  GapText(
    id: 'putovanje',
    title: 'Putovanje na more',
    titleRu: 'Поездка на море',
    text:
        'Prošlog {} putovali smo {} do {}. Spavali smo u malom {} pored {}. '
        'Svakog dana smo plivali u {} i šetali po {}. Uveče smo jeli {} '
        'u dobrom {}. Svim {} smo poslali {} sa plaže.',
    gaps: [
      TextGap('leto', _gen, _sg, 'Время: prošlog leta - генитив.'),
      TextGap(
        'automobil',
        _ins,
        _sg,
        'Средство передвижения - инструментал без предлога.',
      ),
      TextGap('more', _gen, _sg, 'После do - генитив.'),
      TextGap('hotel', _lok, _sg, 'u + локатив: где?'),
      TextGap('plaža', _gen, _sg, 'После pored - генитив.'),
      TextGap('more', _lok, _sg, 'u + локатив: где?'),
      TextGap(
        'grad',
        _lok,
        _sg,
        'po + локатив - движение по поверхности: šetati po gradu.',
      ),
      TextGap('riba', _akk, _sg, 'Прямое дополнение: jeli smo šta?'),
      TextGap('restoran', _lok, _sg, 'u + локатив: где?'),
      TextGap('prijatelj', _dat, _pl, 'Кому послали? - датив.'),
      TextGap('slika', _akk, _pl, 'Прямое дополнение: poslali smo šta?'),
    ],
    translation:
        'Прошлым летом мы ездили на машине на море. Жили в маленькой '
        'гостинице рядом с пляжем. Каждый день мы плавали в море и гуляли '
        'по городу. Вечером ели рыбу в хорошем ресторане. Всем друзьям мы '
        'отправили фотографии с пляжа.',
  ),
  GapText(
    id: 'pismo',
    title: 'Pismo prijatelju',
    titleRu: 'Письмо другу',
    text:
        'Dragi {}, hvala ti na {}. Sada živim u {} pored {}. Svakog jutra '
        'idem u {} sa {}. Popodne pomažem {} u {}. Ovde nema {}, ali ima '
        'mnogo {}. Pozdravi {} i piši mi o {}! Tvoj Ivan',
    gaps: [
      TextGap(
        'prijatelj',
        _vok,
        _sg,
        'Обращение - вокатив; мягкая основа: -u.',
      ),
      TextGap('pismo', _lok, _sg, 'hvala na + локатив - спасибо за что?'),
      TextGap('selo', _lok, _sg, 'u + локатив: где?'),
      TextGap('planina', _gen, _sg, 'После pored - генитив.'),
      TextGap('šuma', _akk, _sg, 'u + аккузатив - направление: куда?'),
      TextGap('pas', _ins, _sg, 'sa + инструментал - с кем? Беглое «а»: psom.'),
      TextGap('komšija', _dat, _sg, 'pomagati kome? - датив.'),
      TextGap('dvorište', _lok, _sg, 'u + локатив: где?'),
      TextGap('bioskop', _gen, _sg, 'nema + генитив - отсутствие.'),
      TextGap(
        'ptica',
        _gen,
        _pl,
        'После mnogo - генитив множественного числа.',
      ),
      TextGap('sestra', _akk, _sg, 'Прямое дополнение: pozdravi koga?'),
      TextGap('posao', _lok, _sg, 'o + локатив - о чём?'),
    ],
    translation:
        'Дорогой друг, спасибо тебе за письмо. Сейчас я живу в деревне '
        'у гор. Каждое утро хожу в лес с собакой. После обеда помогаю '
        'соседу во дворе. Здесь нет кинотеатра, но много птиц. Передай '
        'привет сестре и напиши мне о работе! Твой Иван',
  ),
];
