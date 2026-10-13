import 'package:srpski_padezi/models/models.dart';

/// Порядок изучения, как в учебниках сербского для иностранцев: сначала
/// падежи первых фраз (кто? что? где?), затем генитив и датив, инструментал,
/// в конце - вокатив.
///
/// Школьная нумерация (N-G-D-A-V-I-L) для этого не годится: второй же падеж
/// в ней самый трудный. Этот же порядок - у строк таблицы склонения.
const List<GramCase> kCaseLearningOrder = [
  GramCase.nominativ,
  GramCase.akuzativ,
  GramCase.lokativ,
  GramCase.genitiv,
  GramCase.dativ,
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
        'Мужской род',
        '-∅',
        '-i (часто +ov/ev)',
        lemmas: ['grad', 'student'],
      ),
      EndingRow('Женский род на -a', '-a', '-e', lemmas: ['žena', 'majka']),
      EndingRow('Женский род на согласный', '-∅', '-i', lemmas: ['noć']),
      EndingRow('Средний род', '-o / -e', '-a', lemmas: ['selo', 'more']),
    ],
    examples: [
      Example('Ovo je moj stan.', 'Это моя квартира.'),
      Example('Gradovi su veliki.', 'Города большие.'),
      Example('Moja sestra je profesor.', 'Моя сестра - преподаватель.'),
      Example('Mlada žena čita knjigu.', 'Молодая женщина читает книгу.'),
      Example('Stari gradovi su lepi.', 'Старые города красивые.'),
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
        'Мужской род',
        '-a',
        '-a (часто +ov/ev, беглое «а»)',
        lemmas: ['grad', 'student'],
      ),
      EndingRow(
        'Женский род на -a',
        '-e',
        '-a / -i',
        lemmas: ['žena', 'majka'],
      ),
      EndingRow('Женский род на согласный', '-i', '-i', lemmas: ['noć']),
      EndingRow('Средний род', '-a', '-a', lemmas: ['selo', 'pismo']),
    ],
    examples: [
      Example('Dolazim iz Beograda.', 'Я приезжаю из Белграда.'),
      Example('Nema vode u boci.', 'В бутылке нет воды.'),
      Example('Ovo je kuća mojih roditelja.', 'Это дом моих родителей.'),
      Example('Kupio sam pet knjiga.', 'Я купил пять книг.'),
      Example(
        'Ovo je kuća mog starog prijatelja.',
        'Это дом моего старого друга.',
      ),
      Example('Nema tople vode.', 'Нет горячей воды.'),
      Example('Kupio sam pet novih knjiga.', 'Я купил пять новых книг.'),
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
      EndingRow('Мужской род', '-u', '-ima', lemmas: ['grad', 'student']),
      EndingRow('Женский род на -a', '-i', '-ama', lemmas: ['žena', 'knjiga']),
      EndingRow('Женский род на согласный', '-i', '-ima', lemmas: ['noć']),
      EndingRow('Средний род', '-u', '-ima', lemmas: ['selo', 'more']),
    ],
    examples: [
      Example('Pišem pismo majci.', 'Пишу письмо матери.'),
      Example('Idemo ka moru.', 'Мы едем к морю.'),
      Example('Deci je dosadno.', 'Детям скучно.'),
      Example('Pomozi prijateljima.', 'Помоги друзьям.'),
      Example(
        'Pišem pismo staroj prijateljici.',
        'Пишу письмо старой подруге.',
      ),
      Example(
        'Dao sam knjigu malom detetu.',
        'Я дал книгу маленькому ребёнку.',
      ),
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
        'Мужской род, неодушевлённый',
        '= номинатив (-∅)',
        '-e',
        lemmas: ['grad'],
      ),
      EndingRow(
        'Мужской род, одушевлённый',
        '= генитив (-a)',
        '-e',
        lemmas: ['student'],
      ),
      EndingRow('Женский род на -a', '-u', '-e', lemmas: ['žena']),
      EndingRow(
        'Женский род на согласный',
        '= номинатив (-∅)',
        '-i',
        lemmas: ['noć'],
      ),
      EndingRow('Средний род', '= номинатив', '-a', lemmas: ['selo']),
    ],
    examples: [
      Example('Vidim grad.', 'Я вижу город.'),
      Example('Vidim studenta.', 'Я вижу студента.'),
      Example('Idem u kuću.', 'Иду в дом.'),
      Example('Čekam prijatelje.', 'Жду друзей.'),
      Example('Vidim velikog psa.', 'Я вижу большую собаку.'),
      Example('Čitam zanimljivu knjigu.', 'Читаю интересную книгу.'),
      Example('Volim stare gradove.', 'Люблю старые города.'),
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
        'Мужской род, твёрдая основа',
        '-e',
        '= номинатив',
        lemmas: ['grad', 'student'],
      ),
      EndingRow(
        'Мужской род, мягкая основа (j, lj, nj, ć, đ, č, ž, š)',
        '-u',
        '= номинатив',
        lemmas: ['prijatelj', 'muž'],
      ),
      EndingRow(
        'Женский род на -a',
        '-o (у слов на -ica → -e)',
        '= номинатив',
        lemmas: ['žena', 'ulica'],
      ),
      EndingRow(
        'Женский род на согласный',
        '-i',
        '= номинатив',
        lemmas: ['noć'],
      ),
      EndingRow('Средний род', '= номинатив', '= номинатив', lemmas: ['selo']),
    ],
    examples: [
      Example('Prijatelju, hvala ti!', 'Друг, спасибо тебе!'),
      Example('Ženo, gde si bila?', 'Женщина, где ты была?'),
      Example('Dobro jutro, profesore!', 'Доброе утро, преподаватель!'),
      Example('Sine, dođi ovamo.', 'Сын, иди сюда.'),
      Example(
        'Dragi prijatelju, dobro došao!',
        'Дорогой друг, добро пожаловать!',
      ),
      Example('Poštovani gosti, izvolite!', 'Уважаемые гости, проходите!'),
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
    prepositions: ['s / sa (вместе с)', 'pod', 'nad', 'pred', 'za', 'među'],
    endings: [
      EndingRow(
        'Мужской род, твёрдая основа',
        '-om',
        '-ima',
        lemmas: ['grad', 'student'],
      ),
      EndingRow(
        'Мужской род, мягкая основа',
        '-em',
        '-ima',
        lemmas: ['nož', 'prijatelj'],
      ),
      EndingRow('Женский род на -a', '-om', '-ama', lemmas: ['žena']),
      EndingRow(
        'Женский род на согласный',
        '-ju (реже -i)',
        '-ima',
        lemmas: ['noć', 'reč'],
      ),
      EndingRow('Средний род', '-om / -em', '-ima', lemmas: ['selo', 'more']),
    ],
    examples: [
      Example('Idem u grad autobusom.', 'Еду в город автобусом.'),
      Example('Živim sa sestrom.', 'Живу с сестрой.'),
      Example('Knjiga je pod stolom.', 'Книга под столом.'),
      Example('Pišem olovkom.', 'Пишу карандашом.'),
      Example('Putujem novim autobusom.', 'Еду на новом автобусе.'),
      Example(
        'Razgovaram sa starim prijateljem.',
        'Разговариваю со старым другом.',
      ),
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
      EndingRow('Мужской род', '-u', '-ima', lemmas: ['grad', 'student']),
      EndingRow('Женский род на -a', '-i', '-ama', lemmas: ['škola', 'knjiga']),
      EndingRow('Женский род на согласный', '-i', '-ima', lemmas: ['noć']),
      EndingRow('Средний род', '-u', '-ima', lemmas: ['selo']),
    ],
    examples: [
      Example('Živim u Beogradu.', 'Я живу в Белграде.'),
      Example('Knjiga je na stolu.', 'Книга на столе.'),
      Example('Pričamo o ljubavi.', 'Мы говорим о любви.'),
      Example('Deca su u školama.', 'Дети в школах.'),
      Example('Živim u malom gradu.', 'Я живу в маленьком городе.'),
      Example('Pričamo o novoj knjizi.', 'Мы говорим о новой книге.'),
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
