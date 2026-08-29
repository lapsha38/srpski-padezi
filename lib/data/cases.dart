import 'package:srpski_padezi/models/models.dart';

/// Порядок изучения: от нужного в первых фразах к тому, что можно отложить.
///
/// Школьная нумерация (N-G-D-A-V-I-L) для этого не годится: второй же падеж
/// в ней самый трудный. Датив идёт сразу за локативом - формы у них общие.
const List<GramCase> kCaseLearningOrder = [
  GramCase.nominativ,
  GramCase.akuzativ,
  GramCase.lokativ,
  GramCase.dativ,
  GramCase.genitiv,
  GramCase.instrumental,
  GramCase.vokativ,
];

/// Номер падежа в маршруте обучения (1-7).
int caseLearningStep(GramCase c) => kCaseLearningOrder.indexOf(c) + 1;

/// Следующий падеж маршрута; null - если это последний.
GramCase? nextCaseInLearningOrder(GramCase c) {
  final next = kCaseLearningOrder.indexOf(c) + 1;
  return next < kCaseLearningOrder.length ? kCaseLearningOrder[next] : null;
}

/// Теоретические карточки по всем семи падежам сербского языка.
const List<CaseInfo> kCaseInfos = [
  // ── Nominativ ────────────────────────────────────────────────────────
  CaseInfo(
    gramCase: GramCase.nominativ,
    tagline: 'Исходная форма слова: кто? что?',
    summary:
        'Номинатив - словарная форма существительного. Именно её вы видите в '
        'словаре '
        'и от неё образуются все остальные падежи. В предложении номинатив '
        'обычно '
        'является подлежащим, а также именной частью сказуемого после глагола '
        'biti'
        '(быть) - в отличие от русского, где мы говорим «он был врачом» '
        '(творительный), сербский требует именительного: on je bio lekar.',
    meanings: [
      'Подлежащее: Grad je lep. - Город красивый.',
      'Именная часть сказуемого после biti: Ona je lekar. - Она врач.',
      'Название, перечисление, подпись к картинке.',
      'После zove se / ime mu je: Ovo je moj prijatelj Marko.',
    ],
    prepositions: [],
    endings: [
      EndingRow(
        'м. р. на согласный',
        '-∅',
        '-i (часто +ov/ev)',
        example: 'grad → gradovi, prozor → prozori',
      ),
      EndingRow('ж. р. на -a', '-a', '-e', example: 'žena → žene'),
      EndingRow('ж. р. на согласный', '-∅', '-i', example: 'noć → noći'),
      EndingRow('ср. р.', '-o / -e', '-a', example: 'selo → sela, more → mora'),
    ],
    examples: [
      Example('Ovo je moj stan.', 'Это моя квартира.'),
      Example('Gradovi su veliki.', 'Города большие.'),
      Example('Moja sestra je profesor.', 'Моя сестра - преподаватель.'),
    ],
    russianNote:
        'Совпадает с русским именительным. Главное отличие - конструкция с '
        'глаголом'
        '«быть»: в сербском после biti стоит номинатив, а не творительный '
        'падеж.'
        'Ещё одно отличие: у односложных слов мужского рода во множественном '
        'числе '
        'появляется вставка -ov-/-ev-: grad → gradovi, nož → noževi.',
    pitfalls: [
      'Не переводите «он был студентом» творительным: правильно on je bio '
          'student.',
      'После числительных 2, 3, 4 стоит НЕ номинатив множественного числа, '
          'а особая форма (родительный падежа ед. ч.): dva grada, tri žene.',
    ],
  ),

  // ── Genitiv ──────────────────────────────────────────────────────────
  CaseInfo(
    gramCase: GramCase.genitiv,
    tagline: 'Принадлежность, отсутствие, количество: кого? чего?',
    summary:
        'Генитив - самый «рабочий» падеж сербского языка: у него больше всего '
        'предлогов. Он выражает принадлежность (knjiga mog brata), отсутствие '
        '(nema vode), происхождение и точку отсчёта (iz Beograda, od kuće), '
        'количество (mnogo ljudi, čaša vina) и время (tokom dana).',
    meanings: [
      'Принадлежность: krov kuće - крыша дома.',
      'Отсутствие после nema / nije bilo: Nema hleba. - Хлеба нет.',
      'Количество после mnogo, malo, nekoliko, čaša, kilo: mnogo knjiga.',
      'После числительных от 5 и выше: pet gradova.',
      'После числительных 2, 3, 4 - форма родительного падежа ед. ч.: dva '
          'grada.',
      'Дата и время: prvog maja, tokom noći.',
    ],
    prepositions: [
      'od',
      'do',
      'iz',
      'sa (с поверхности)',
      'kod',
      'bez',
      'pre',
      'posle',
      'oko',
      'blizu',
      'pored',
      'ispred',
      'iza',
      'iznad',
      'ispod',
      'zbog',
      'umesto',
      'tokom',
      'preko',
    ],
    endings: [
      EndingRow(
        'м. р.',
        '-a',
        '-a (часто +ov/ev, беглое «а»)',
        example: 'grada → gradova, studenta → studenata',
      ),
      EndingRow(
        'ж. р. на -a',
        '-e',
        '-a / -i',
        example: 'žene → žena, majke → majki',
      ),
      EndingRow('ж. р. на согласный', '-i', '-i', example: 'noći → noći'),
      EndingRow('ср. р.', '-a', '-a', example: 'sela → sela, pisma → pisama'),
    ],
    examples: [
      Example('Dolazim iz Beograda.', 'Я приезжаю из Белграда.'),
      Example('Nema vode u boci.', 'В бутылке нет воды.'),
      Example('Ovo je kuća mojih roditelja.', 'Это дом моих родителей.'),
      Example('Kupio sam pet knjiga.', 'Я купил пять книг.'),
    ],
    russianNote:
        'Почти полностью совпадает с русским родительным падежом, включая '
        'употребление при отрицании и после числительных. Обратите внимание: '
        'сербское kod + генитив соответствует русскому «у» (kod lekara - у '
        'врача),'
        'а sa + генитив означает движение с поверхности (sa stola - со стола).',
    pitfalls: [
      'Родительный падеж множественного числа мужского рода часто получает '
          'беглое «а»: student → studenata, а не «studenta».',
      'Не путайте sa + генитив (со стола) и sa + инструментал (с другом).',
      'После nema всегда генитив, даже если по-русски хочется поставить '
          'именительный: Nema problema.',
    ],
  ),

  // ── Dativ ────────────────────────────────────────────────────────────
  CaseInfo(
    gramCase: GramCase.dativ,
    tagline: 'Адресат и направление: кому? чему?',
    summary:
        'Датив указывает на того, кому что-то даётся, говорится или '
        'принадлежит '
        'по ощущению, а также на направление движения к кому-то или чему-то. '
        'Форма датива полностью совпадает с формой локатива, поэтому вы учите '
        'фактически одну форму, а различаете их по употреблению: датив '
        'самостоятелен или идёт с ka/prema, локатив - только с предлогами u, '
        'na, o, po.',
    meanings: [
      'Адресат действия: Dajem knjigu prijatelju. - Даю книгу другу.',
      'Направление к цели: Idem ka gradu. - Иду к городу.',
      'Лицо, которое испытывает состояние: Hladno mi je. - Мне холодно.',
      'После глаголов pomoći, verovati, smetati, nedostajati: Verujem sestri.',
    ],
    prepositions: ['k / ka', 'prema', 'nasuprot', 'uprkos'],
    endings: [
      EndingRow('м. р.', '-u', '-ima', example: 'gradu → gradovima'),
      EndingRow(
        'ж. р. на -a',
        '-i',
        '-ama',
        example: 'ženi → ženama, knjizi → knjigama',
      ),
      EndingRow('ж. р. на согласный', '-i', '-ima', example: 'noći → noćima'),
      EndingRow('ср. р.', '-u', '-ima', example: 'selu → selima'),
    ],
    examples: [
      Example('Pišem pismo majci.', 'Пишу письмо матери.'),
      Example('Idemo ka moru.', 'Мы едем к морю.'),
      Example('Deci je dosadno.', 'Детям скучно.'),
      Example('Pomozi prijateljima.', 'Помоги друзьям.'),
    ],
    russianNote:
        'Совпадает с русским дательным. Ключевое отличие от русского - '
        'чередование '
        'согласных у женского рода на -a: k, g, h перед окончанием -i '
        'переходят '
        'в c, z, s: majka → majci, knjiga → knjizi, snaha → snasi.',
    pitfalls: [
      'Забытое чередование: «knjigi» - ошибка, правильно knjizi.',
      'Датив и локатив выглядят одинаково - не пугайтесь, различие только в '
          'употреблении.',
      'Предлог ka употребляется перед словами на g и k: ka gradu, но k sestri.',
    ],
  ),

  // ── Akuzativ ─────────────────────────────────────────────────────────
  CaseInfo(
    gramCase: GramCase.akuzativ,
    tagline: 'Прямое дополнение и движение куда-то: кого? что?',
    summary:
        'Акузатив - падеж прямого дополнения: то, на что направлено действие. '
        'Кроме того, он употребляется с предлогами u, na, za, pod, pred, nad, '
        'među, kroz, niz, uz, когда есть движение, направление внутрь или на '
        'поверхность. Сравните: Idem u grad (акузатив, движение) - Živim u '
        'gradu'
        '(локатив, место).',
    meanings: [
      'Прямое дополнение: Čitam knjigu. - Читаю книгу.',
      'Направление: Idem u školu. - Иду в школу.',
      'Продолжительность: Radim ceo dan. - Работаю весь день.',
      'После imati: Imam brata. - У меня есть брат.',
    ],
    prepositions: [
      'u (куда)',
      'na (куда)',
      'za',
      'kroz',
      'niz',
      'uz',
      'pod / pred / nad / među (с движением)',
      'po (за чем-то)',
    ],
    endings: [
      EndingRow(
        'м. р. неодушевлённый',
        '= номинатив (-∅)',
        '-e',
        example: 'grad → gradove',
      ),
      EndingRow(
        'м. р. одушевлённый',
        '= генитив (-a)',
        '-e',
        example: 'studenta → studente',
      ),
      EndingRow('ж. р. на -a', '-u', '-e', example: 'ženu → žene'),
      EndingRow(
        'ж. р. на согласный',
        '= номинатив (-∅)',
        '-i',
        example: 'noć → noći',
      ),
      EndingRow('ср. р.', '= номинатив', '-a', example: 'selo → sela'),
    ],
    examples: [
      Example('Vidim grad.', 'Я вижу город.'),
      Example('Vidim studenta.', 'Я вижу студента.'),
      Example('Idem u kuću.', 'Иду в дом.'),
      Example('Čekam prijatelje.', 'Жду друзей.'),
    ],
    russianNote:
        'Логика одушевлённости та же, что в русском: у одушевлённых слов '
        'мужского '
        'рода винительный совпадает с родительным (vidim studenta), у '
        'неодушевлённых'
        '- с именительным (vidim grad). Важное отличие: во множественном числе '
        'сербский не различает одушевлённость - всегда -e: vidim gradove и '
        'vidim studente.',
    pitfalls: [
      'Во множественном числе НЕ используйте форму родительного падежа для '
          'одушевлённых: правильно vidim studente, а не «vidim studenata».',
      'Пара «куда - где»: u grad (акузатив) против u gradu (локатив).',
      'После imati всегда акузатив: Imam sestru.',
    ],
  ),

  // ── Vokativ ──────────────────────────────────────────────────────────
  CaseInfo(
    gramCase: GramCase.vokativ,
    tagline: 'Обращение - падеж, которого нет в русском',
    summary:
        'Вокатив - падеж обращения. В русском языке он почти исчез (остались '
        'только '
        'формы вроде «мам!», «Саш!»), а в сербском это живая обязательная '
        'форма:'
        'обращаясь к человеку, вы обязаны изменить слово. Вокатив никогда не '
        'бывает '
        'членом предложения - он стоит отдельно и выделяется запятой.',
    meanings: [
      'Обращение к человеку: Marko, dođi! - Марко, иди сюда!',
      'Вежливое обращение: Gospodine, izvinite. - Господин, извините.',
      'Обращение в письме: Dragi prijatelju, ...',
      'Восклицание: Bože! - Боже!',
    ],
    prepositions: [],
    endings: [
      EndingRow(
        'м. р. твёрдая основа',
        '-e',
        '= номинатив',
        example: 'grad → grade, student → studente',
      ),
      EndingRow(
        'м. р. мягкая основа (ј, љ, њ, ћ, ђ, ч, ж, ш)',
        '-u',
        '= номинатив',
        example: 'prijatelj → prijatelju, muž → mužu',
      ),
      EndingRow(
        'ж. р. на -a',
        '-o (у слов на -ica → -e)',
        '= номинатив',
        example: 'žena → ženo, ulica → ulice',
      ),
      EndingRow(
        'ж. р. на согласный',
        '-i',
        '= номинатив',
        example: 'noć → noći',
      ),
      EndingRow('ср. р.', '= номинатив', '= номинатив', example: 'selo → selo'),
    ],
    examples: [
      Example('Prijatelju, hvala ti!', 'Друг, спасибо тебе!'),
      Example('Ženo, gde si bila?', 'Женщина, где ты была?'),
      Example('Dobro jutro, profesore!', 'Доброе утро, преподаватель!'),
      Example('Sine, dođi ovamo.', 'Сын, иди сюда.'),
    ],
    russianNote:
        'В русском аналога нет, поэтому его чаще всего забывают: русскоязычные '
        'говорят «Marko, dođi» вместо Marko, dođi - здесь совпало, но «Nikola» '
        '→'
        'Nikola, а «Milan» → Milane. Множественное число вокатива всегда равно '
        'номинативу множественного числа, так что учить нужно только '
        'единственное.',
    pitfalls: [
      'Выбор -e или -u зависит от последнего согласного основы: твёрдый → -e, '
          'мягкий (ј, љ, њ, ћ, ђ, ч, ж, ш, ц) → -u.',
      'Слова женского рода на -ica берут -e, а не -o: Milice, ulice.',
      'Средний род и множественное число не меняются вовсе.',
    ],
  ),

  // ── Instrumental ─────────────────────────────────────────────────────
  CaseInfo(
    gramCase: GramCase.instrumental,
    tagline: 'Орудие и совместность: кем? чем? с кем?',
    summary:
        'Инструментал отвечает на вопросы «чем?» (орудие) и «с кем?» '
        '(совместность).'
        'Ключевое правило, которое отличает сербский от русского: если это '
        'орудие,'
        'предлог НЕ ставится (pišem olovkom - пишу ручкой), а если это '
        'совместность,'
        'обязателен предлог s / sa (idem sa sestrom - иду с сестрой).',
    meanings: [
      'Орудие, средство - без предлога: Putujem vozom. - Еду поездом.',
      'Совместность - с предлогом s / sa: Razgovaram s prijateljem.',
      'Место без движения с предлогами pod, nad, pred, iza, među, za: '
          'Sedim za stolom.',
      'Время: Nedeljom idem na pijacu. - По воскресеньям хожу на рынок.',
    ],
    prepositions: [
      's / sa (вместе с)',
      'pod',
      'nad',
      'pred',
      'za',
      'među',
    ],
    endings: [
      EndingRow(
        'м. р. твёрдая основа',
        '-om',
        '-ima',
        example: 'gradom → gradovima',
      ),
      EndingRow(
        'м. р. мягкая основа',
        '-em',
        '-ima',
        example: 'nožem → noževima',
      ),
      EndingRow('ж. р. на -a', '-om', '-ama', example: 'ženom → ženama'),
      EndingRow(
        'ж. р. на согласный',
        '-ju (реже -i)',
        '-ima',
        example: 'noću, rečju → noćima',
      ),
      EndingRow(
        'ср. р.',
        '-om / -em',
        '-ima',
        example: 'selom, morem → selima',
      ),
    ],
    examples: [
      Example('Idem u grad autobusom.', 'Еду в город автобусом.'),
      Example('Živim sa sestrom.', 'Живу с сестрой.'),
      Example('Knjiga je pod stolom.', 'Книга под столом.'),
      Example('Pišem olovkom.', 'Пишу карандашом.'),
    ],
    russianNote:
        'Отличие от русского только одно, но важное: русский «с» перед орудием '
        'не переводится. «Я режу ножом» - sečem nožem, без предлога. А вот '
        '«я иду с другом» - idem s prijateljem, предлог обязателен. Форма sa '
        'вместо s ставится перед словами на s, š, z, ž и перед стечением '
        'согласных.',
    pitfalls: [
      'Не добавляйте s к орудию: «putujem s vozom» - ошибка, нужно putujem '
          'vozom.',
      'Мягкие основы берут -em, а не -om: nožem, prijateljem, morem.',
      'Инструментал множественного числа совпадает с дативом и локативом: '
          'одна форма на три падежа.',
    ],
  ),

  // ── Lokativ ──────────────────────────────────────────────────────────
  CaseInfo(
    gramCase: GramCase.lokativ,
    tagline: 'Место и тема разговора - всегда с предлогом',
    summary:
        'Локатив (местный падеж) отвечает на вопрос «где?» и «о ком/о чём?». '
        'Он никогда не употребляется без предлога - это его главная примета. '
        'Форма локатива совпадает с формой датива, поэтому фактически вы '
        'уже её '
        'знаете: различие только в предлогах и значении.',
    meanings: [
      'Место без движения: Živim u gradu. - Живу в городе.',
      'Тема разговора или мысли: Govorimo o filmu. - Говорим о фильме.',
      'Передвижение по поверхности: Šetam po parku. - Гуляю по парку.',
      'Время: po podne, u januaru.',
    ],
    prepositions: ['u (где)', 'na (где)', 'o', 'po', 'pri', 'prema (о месте)'],
    endings: [
      EndingRow('м. р.', '-u', '-ima', example: 'u gradu → u gradovima'),
      EndingRow(
        'ж. р. на -a',
        '-i',
        '-ama',
        example: 'u školi, u knjizi → u školama',
      ),
      EndingRow(
        'ж. р. на согласный',
        '-i',
        '-ima',
        example: 'u noći → u noćima',
      ),
      EndingRow('ср. р.', '-u', '-ima', example: 'u selu → u selima'),
    ],
    examples: [
      Example('Živim u Beogradu.', 'Я живу в Белграде.'),
      Example('Knjiga je na stolu.', 'Книга на столе.'),
      Example('Pričamo o ljubavi.', 'Мы говорим о любви.'),
      Example('Deca su u školama.', 'Дети в школах.'),
    ],
    russianNote:
        'Аналог русского предложного падежа, и логика та же: только с '
        'предлогом.'
        'Чередования у женского рода те же, что в дативе: k, g, h → c, z, s '
        '(u knjizi, na reci). Пара «где - куда» работает как в русском: '
        'u gradu (где) - u grad (куда).',
    pitfalls: [
      'Локатив без предлога невозможен - если предлога нет, это датив.',
      'Не путайте с акузативом: idem u školu (куда) и učim u školi (где).',
      'Во множественном числе локатив, датив и инструментал совпадают: '
          'u gradovima, gradovima, sa gradovima.',
    ],
  ),
];

/// Теория по конкретному падежу.
CaseInfo caseInfoFor(GramCase c) =>
    kCaseInfos.firstWhere((info) => info.gramCase == c);
