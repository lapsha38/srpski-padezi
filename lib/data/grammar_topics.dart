import 'package:srpski_padezi/models/models.dart';

/// Тренировка внутри грамматической темы.
enum GrammarDrill {
  presentTense,
  pastTense,
  futureTense,
  imperative,
  negation,
  pronounShort,
  wordOrder,
  daConstruction,
  comparison,
  prepositionCase,
  motionOrPlace,
}

extension GrammarDrillX on GrammarDrill {
  String get title => switch (this) {
    GrammarDrill.presentTense => 'Настоящее время',
    GrammarDrill.pastTense => 'Прошедшее время',
    GrammarDrill.futureTense => 'Будущее время',
    GrammarDrill.imperative => 'Повелительное наклонение',
    GrammarDrill.negation => 'Отрицание',
    GrammarDrill.pronounShort => 'Краткие формы местоимений',
    GrammarDrill.wordOrder => 'Порядок энклитик',
    GrammarDrill.daConstruction => 'Конструкция da + глагол',
    GrammarDrill.comparison => 'Степени сравнения',
    GrammarDrill.prepositionCase => 'Предлог и падеж',
    GrammarDrill.motionOrPlace => 'Куда или где',
  };

  String get description => switch (this) {
    GrammarDrill.presentTense =>
      'Поставить глагол в нужное лицо: три спряжения вперемешку.',
    GrammarDrill.pastTense =>
      'Вспомогательный глагол плюс причастие, согласованное по роду.',
    GrammarDrill.futureTense =>
      'Формы ću / ćeš и слитные варианты вроде radiću.',
    GrammarDrill.imperative => 'Скажите то же самое как приказ или просьбу.',
    GrammarDrill.negation => 'Слитные формы и двойное отрицание.',
    GrammarDrill.pronounShort =>
      'Подставить безударную форму местоимения в предложение.',
    GrammarDrill.wordOrder =>
      'Выбрать предложение, где энклитики стоят правильно.',
    GrammarDrill.daConstruction =>
      'Сербский вместо инфинитива чаще берёт da и настоящее время.',
    GrammarDrill.comparison => 'Сравнительная и превосходная степень.',
    GrammarDrill.prepositionCase =>
      'Поставить слово в падеж, которого требует предлог.',
    GrammarDrill.motionOrPlace =>
      'Выбрать между винительным (куда) и локативом (где).',
  };

  String get progressKey => 'grammar_$name';
}

/// Грамматическая тема: теория плюс тренировки.
class GrammarTopic {
  const new({
    required this.title,
    required this.subtitle,
    required this.sections,
    required this.drills,
  });

  final String title;
  final String subtitle;
  final List<TopicSection> sections;
  final List<GrammarDrill> drills;
}

/// Грамматические темы вне падежей и числительных.
const List<GrammarTopic> kGrammarTopics = [
  GrammarTopic(
    title: 'Настоящее время',
    subtitle: 'Три спряжения и почему местоимение можно опустить',
    drills: [GrammarDrill.presentTense],
    sections: [
      TopicSection(
        title: 'Три спряжения',
        body:
            'Глаголы в настоящем времени делятся на три группы по гласной '
            'в окончании: -am, -im и -em. Определить группу проще всего по '
            'форме первого лица, поэтому её и стоит запоминать вместе '
            'с инфинитивом.',
        bullets: [
          'Спряжение на -am: gledam, gledaš, gleda, gledamo, gledate, gledaju.',
          'Спряжение на -im: radim, radiš, radi, radimo, radite, rade.',
          'Спряжение на -em: pišem, pišeš, piše, pišemo, pišete, pišu.',
          'Только у -am третье лицо множественного числа даёт -aju, '
              'у -im это -e, у -em это -u.',
        ],
        table: [
          EndingRow(
            'спряжение на -am',
            '-am, -aš, -a',
            '-amo, -ate, -aju',
            example: 'gledati → gledam',
          ),
          EndingRow(
            'спряжение на -im',
            '-im, -iš, -i',
            '-imo, -ite, -e',
            example: 'raditi → radim',
          ),
          EndingRow(
            'спряжение на -em',
            '-em, -eš, -e',
            '-emo, -ete, -u',
            example: 'pisati → pišem',
          ),
        ],
        examples: [
          Example('Radim u Beogradu.', 'Я работаю в Белграде.'),
          Example('Šta gledaš?', 'Что ты смотришь?'),
          Example('Oni pišu domaći zadatak.', 'Они пишут домашнее задание.'),
        ],
      ),
      TopicSection(
        title: 'Местоимение обычно опускают',
        body:
            'Окончание уже показывает лицо, поэтому личное местоимение '
            'ставят только для выделения. Русское «я работаю» по-сербски '
            'звучит просто как radim, а ja radim означает скорее '
            '«именно я работаю».',
        examples: [
          Example('Učim srpski.', 'Я учу сербский.'),
          Example('Ja učim, a ti spavaš.', 'Я-то учу, а ты спишь.'),
        ],
      ),
      TopicSection(
        title: 'Глагол biti',
        body:
            'У глагола biti две формы настоящего времени: краткая '
            '(безударная) и полная (ударная). Краткая форма употребляется '
            'в обычном предложении, полная - в ответах, при отрицании '
            'смысла и для выделения.',
        bullets: [
          'Краткие: sam, si, je, smo, ste, su.',
          'Полные: jesam, jesi, jeste, jesmo, jeste, jesu.',
          'Отрицательные: nisam, nisi, nije, nismo, niste, nisu.',
          'Краткая форма не может стоять в начале предложения.',
        ],
        examples: [
          Example('Ja sam student.', 'Я студент.'),
          Example('Jesi li ti student? - Jesam.', 'Ты студент? - Да.'),
          Example('Nisam umoran.', 'Я не устал.'),
        ],
      ),
    ],
  ),
  GrammarTopic(
    title: 'Прошедшее время',
    subtitle: 'Перфект: краткая форма biti плюс причастие',
    drills: [GrammarDrill.pastTense],
    sections: [
      TopicSection(
        title: 'Как образуется перфект',
        body:
            'Перфект состоит из двух частей: краткой формы глагола biti '
            '(sam, si, je, smo, ste, su) и причастия на -o / -la / -lo. '
            'Причастие согласуется с подлежащим в роде и числе - это '
            'главное отличие от русского, где род меняется только '
            'в единственном числе.',
        bullets: [
          'Мужской род: radio sam, radio si, radio je.',
          'Женский род: radila sam, radila si, radila je.',
          'Средний род: radilo je.',
          'Множественное число: radili (муж.), radile (жен.), radila (ср.).',
          'Отрицание: nisam radio, nije radila.',
        ],
        table: [
          EndingRow('м. р.', '-o (radio)', '-i (radili)'),
          EndingRow('ж. р.', '-la (radila)', '-le (radile)'),
          EndingRow('ср. р.', '-lo (radilo)', '-la (radila)'),
        ],
        examples: [
          Example('Juče sam radio ceo dan.', 'Вчера я работал весь день.'),
          Example('Ona je došla u pet.', 'Она пришла в пять.'),
          Example('Nismo videli taj film.', 'Мы не видели этот фильм.'),
        ],
      ),
      TopicSection(
        title: 'Порядок слов важнее, чем кажется',
        body:
            'Краткая форма biti - энклитика: она не может открывать '
            'предложение. Поэтому говорят Radio sam, а не «Sam radio». '
            'Если предложение начинается с другого слова, энклитика встаёт '
            'сразу после него.',
        examples: [
          Example('Juče sam bio kod lekara.', 'Вчера я был у врача.'),
          Example('Video sam ga u gradu.', 'Я видел его в городе.'),
        ],
      ),
    ],
  ),
  GrammarTopic(
    title: 'Будущее время',
    subtitle: 'ću, ćeš, će и слитные формы вроде radiću',
    drills: [GrammarDrill.futureTense],
    sections: [
      TopicSection(
        title: 'Как образуется будущее',
        body:
            'Будущее время строится из кратких форм глагола hteti '
            '(ću, ćeš, će, ćemo, ćete, će) и инфинитива. У глаголов на -ti '
            'в сербском обычна слитная форма: raditi + ću → radiću.',
        bullets: [
          'Раздельно: Ja ću raditi. Ti ćeš raditi.',
          'Слитно (только для глаголов на -ti): radiću, radićeš, radiće.',
          'Глаголы на -ći не сливаются: ja ću ići, ti ćeš doći.',
          'Отрицание: neću raditi, nećeš doći.',
        ],
        examples: [
          Example(
            'Sutra ću raditi od devet.',
            'Завтра я буду работать с девяти.',
          ),
          Example('Videćemo se u petak.', 'Увидимся в пятницу.'),
          Example('Neću doći večeras.', 'Я не приду сегодня вечером.'),
        ],
      ),
    ],
  ),
  GrammarTopic(
    title: 'Повелительное наклонение',
    subtitle: 'Просьба, приказ и вежливый запрет',
    drills: [GrammarDrill.imperative],
    sections: [
      TopicSection(
        title: 'Три формы императива',
        body:
            'Императив образуется от основы настоящего времени и имеет три '
            'формы: для ты, для мы и для вы. Форма на -te одновременно '
            'служит вежливым обращением к одному человеку.',
        bullets: [
          'radi - radimo - radite.',
          'gledaj - gledajmo - gledajte (основа на гласную даёт -j).',
          'reci - recimo - recite (неправильная форма от reći).',
          'Запрет: nemoj da radiš или nemoj raditi; во множественном - '
              'nemojte.',
        ],
        examples: [
          Example('Dođi ovamo!', 'Иди сюда!'),
          Example('Sedite, molim vas.', 'Садитесь, пожалуйста.'),
          Example('Nemoj to da radiš.', 'Не делай этого.'),
        ],
      ),
    ],
  ),
  GrammarTopic(
    title: 'Отрицание',
    subtitle: 'Что пишется слитно и почему отрицаний бывает несколько',
    drills: [GrammarDrill.negation],
    sections: [
      TopicSection(
        title: 'Слитно или раздельно',
        body:
            'Частица ne пишется отдельно от глагола, но три глагола '
            'сливаются с ней: biti, imati и hteti. Именно на них чаще всего '
            'ошибаются.',
        bullets: [
          'nisam, nisi, nije, nismo, niste, nisu - от biti.',
          'nemam, nemaš, nema, nemamo, nemate, nemaju - от imati.',
          'neću, nećeš, neće, nećemo, nećete, neće - от hteti.',
          'Все остальные глаголы: ne radim, ne znam, ne mogu.',
        ],
        examples: [
          Example('Nemam vremena.', 'У меня нет времени.'),
          Example('Ne razumem te.', 'Я тебя не понимаю.'),
          Example('Neću da idem.', 'Я не хочу идти.'),
        ],
      ),
      TopicSection(
        title: 'Двойное отрицание обязательно',
        body:
            'Как и в русском, отрицательные слова требуют отрицательного '
            'глагола: niko ne zna, nikada nisam bio. Кроме того, после '
            'отрицания дополнение часто переходит в родительный падеж.',
        examples: [
          Example('Niko ne zna odgovor.', 'Никто не знает ответа.'),
          Example('Nemam novca.', 'У меня нет денег.'),
          Example('Nikada nisam bio u Nišu.', 'Я никогда не был в Нише.'),
        ],
      ),
    ],
  ),
  GrammarTopic(
    title: 'Местоимения',
    subtitle: 'Полные и краткие формы: me или mene',
    drills: [GrammarDrill.pronounShort],
    sections: [
      TopicSection(
        title: 'Две формы у одного местоимения',
        body:
            'У личных местоимений в родительном, дательном и винительном '
            'падежах есть две формы: краткая (безударная) и полная (ударная). '
            'В обычной речи используется краткая, полная нужна после предлогов '
            'и при логическом ударении.',
        bullets: [
          'Винительный: me, te, ga, je, nas, vas, ih.',
          'Дательный: mi, ti, mu, joj, nam, vam, im.',
          'Полные формы: mene, tebe, njega, nju, nas, vas, njih.',
          'После предлога - только полная форма: sa mnom, kod njega, za tebe.',
        ],
        table: [
          EndingRow('ja', 'me / mene (вин.), mi / meni (дат.)', 'nas, nam'),
          EndingRow('ti', 'te / tebe, ti / tebi', 'vas, vam'),
          EndingRow('on, ono', 'ga / njega, mu / njemu', 'ih, im'),
          EndingRow('ona', 'je / nju, joj / njoj', 'ih, im'),
        ],
        examples: [
          Example('Vidim ga svaki dan.', 'Я вижу его каждый день.'),
          Example('Njega vidim, a nju ne.', 'Его я вижу, а её нет.'),
          Example('Daj mi to.', 'Дай мне это.'),
        ],
      ),
    ],
  ),
  GrammarTopic(
    title: 'Порядок слов',
    subtitle: 'Энклитики и правило второй позиции',
    drills: [GrammarDrill.wordOrder],
    sections: [
      TopicSection(
        title: 'Правило второй позиции',
        body:
            'Безударные словечки - sam, si, je, ću, me, ga, mu, se - '
            'называются энклитиками и занимают вторую позицию в предложении: '
            'сразу после первого ударного слова. Именно порядок энклитик '
            'сильнее всего выдаёт иностранца.',
        bullets: [
          'Энклитика никогда не начинает предложение.',
          'Порядок в цепочке: li → глагольная (sam, ćeš) → дательная (mi, mu) '
              '→ винительная или родительная (me, ga) → se → je.',
          'Форма je (3-е лицо) всегда последняя: Dao mi ga je.',
          'После запятой цепочка начинается заново.',
        ],
        examples: [
          Example('Rekao sam ti to.', 'Я тебе это сказал.'),
          Example('Dao mi ga je.', 'Он мне его дал.'),
          Example('Juče smo se videli.', 'Вчера мы виделись.'),
        ],
      ),
    ],
  ),
  GrammarTopic(
    title: 'Конструкция da + глагол',
    subtitle: 'Сербский способ обойтись без инфинитива',
    drills: [GrammarDrill.daConstruction],
    sections: [
      TopicSection(
        title: 'Вместо инфинитива',
        body:
            'Там, где русский ставит инфинитив («хочу пойти»), сербский '
            'обычно использует da и глагол в настоящем времени, согласованный '
            'с подлежащим: hoću da idem. Инфинитив тоже возможен, но '
            'da-конструкция звучит естественнее.',
        bullets: [
          'Лицо после da совпадает с подлежащим: on mora da radi.',
          'Между da и глаголом ничего не вставляют.',
          'Так же строятся конструкции с moći, morati, hteti, voleti, '
              'početi, želeti.',
          'В вопросе: Hoćeš li da idemo? - Пойдём?',
        ],
        examples: [
          Example('Moram da učim.', 'Мне нужно учиться.'),
          Example('Volim da putujem.', 'Я люблю путешествовать.'),
          Example('Možeš li da mi pomogneš?', 'Можешь мне помочь?'),
        ],
      ),
    ],
  ),
  GrammarTopic(
    title: 'Степени сравнения',
    subtitle: 'lep - lepši - najlepši',
    drills: [GrammarDrill.comparison],
    sections: [
      TopicSection(
        title: 'Сравнительная степень',
        body:
            'Сравнительная степень образуется тремя суффиксами: -iji '
            '(самый частый), -ji с чередованием и -ši у нескольких слов. '
            'Превосходная степень - это просто naj- перед сравнительной.',
        bullets: [
          '-iji: nov → noviji, star → stariji, pametan → pametniji.',
          '-ji с чередованием: mlad → mlađi, jak → jači, skup → skuplji.',
          '-ši: lep → lepši, lak → lakši.',
          'Превосходная: naj + сравнительная - najnoviji, najlepši.',
          'Неправильные: dobar → bolji, loš → gori, velik → veći, '
              'mali → manji.',
        ],
        examples: [
          Example('Beograd je veći od Niša.', 'Белград больше Ниша.'),
          Example('Ovo je najlepši grad.', 'Это самый красивый город.'),
          Example('Danas je toplije nego juče.', 'Сегодня теплее, чем вчера.'),
        ],
      ),
      TopicSection(
        title: 'Как сказать «чем»',
        body:
            'Есть два способа сравнить: od с родительным падежом или nego '
            'с той же формой, что у первого предмета. Оба верны, но od '
            'встречается чаще.',
        examples: [
          Example('Stariji sam od tebe.', 'Я старше тебя.'),
          Example('On je brži nego ja.', 'Он быстрее, чем я.'),
        ],
      ),
    ],
  ),
  GrammarTopic(
    title: 'Предлоги и падежи',
    subtitle: 'Какой падеж требует предлог и в чём разница между куда и где',
    drills: [GrammarDrill.prepositionCase, GrammarDrill.motionOrPlace],
    sections: [
      TopicSection(
        title: 'Каждый предлог требует своего падежа',
        body:
            'Предлог в сербском не бывает сам по себе: он всегда тянет за '
            'собой определённый падеж. Больше всего предлогов у родительного '
            'падежа, поэтому его и учат первым после именительного.',
        bullets: [
          'Родительный: iz, od, do, kod, bez, pre, posle, oko, pored, '
              'ispred, iza, iznad, ispod, zbog, tokom.',
          'Дательный: ka, prema, nasuprot.',
          'Винительный: kroz, niz, uz, za (цель), а также u и na при движении.',
          'Инструментал: sa, pod, nad, pred, među, za (место).',
          'Локатив: o, po, pri, а также u и na при обозначении места.',
        ],
        examples: [
          Example('Dolazim iz grada.', 'Я приезжаю из города.'),
          Example('Idem ka moru.', 'Я еду к морю.'),
          Example('Prolazim kroz park.', 'Я прохожу через парк.'),
          Example('Sedim pored prozora.', 'Я сижу рядом с окном.'),
        ],
      ),
      TopicSection(
        title: 'Куда или где: u и na меняют падеж',
        body:
            'Предлоги u и na работают с двумя падежами. Если есть движение '
            '(вопрос «куда?»), нужен винительный падеж. Если движения нет '
            '(вопрос «где?»), нужен локатив. Логика та же, что в русском, '
            'но окончания приходится держать в голове.',
        bullets: [
          'Idem u grad (куда?) - Živim u gradu (где?).',
          'Idem na more (куда?) - Odmaram na moru (где?).',
          'То же самое у pod, nad, pred, među: с движением винительный, '
              'без движения инструментал.',
          'Проверка простая: если глагол показывает перемещение, ставьте '
              'винительный.',
        ],
        examples: [
          Example('Idem u školu.', 'Я иду в школу.'),
          Example('Učim u školi.', 'Я учусь в школе.'),
          Example('Stavljam knjigu na sto.', 'Я кладу книгу на стол.'),
          Example('Knjiga je na stolu.', 'Книга на столе.'),
        ],
      ),
    ],
  ),
];
