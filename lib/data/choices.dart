/// Задание «выберите правильный вариант предложения».
///
/// Такие задания нужны там, где правило касается целого предложения:
/// порядок энклитик, конструкция с da, отрицание.
class ChoiceTask {
  const ChoiceTask({
    required this.ru,
    required this.correct,
    required this.wrong,
    required this.explanation,
  });

  /// Что нужно сказать по-сербски (задание на русском).
  final String ru;

  /// Правильный вариант.
  final String correct;

  /// Неверные варианты - минимум три.
  final List<String> wrong;

  /// Почему правильный вариант именно такой.
  final String explanation;
}

/// Порядок кратких (энклитических) форм - вторая позиция в предложении.
const List<ChoiceTask> kWordOrderTasks = [
  ChoiceTask(
    ru: 'Я тебе это сказал.',
    correct: 'Rekao sam ti to.',
    wrong: ['Rekao ti sam to.', 'Sam ti to rekao.', 'Rekao sam to ti.'],
    explanation:
        'Энклитики идут сразу после первого ударного слова, '
        'а внутри цепочки первым стоит глагольное sam, затем дательное ti.',
  ),
  ChoiceTask(
    ru: 'Он мне его дал.',
    correct: 'Dao mi ga je.',
    wrong: ['Dao je mi ga.', 'Dao mi je ga.', 'Mi ga je dao.'],
    explanation:
        'Форма je (3-е лицо единственного числа) всегда замыкает '
        'цепочку энклитик: dativ (mi) → akuzativ (ga) → je.',
  ),
  ChoiceTask(
    ru: 'Я его видел.',
    correct: 'Video sam ga.',
    wrong: ['Video ga sam.', 'Sam ga video.', 'Ga sam video.'],
    explanation:
        'Глагольная энклитика sam стоит перед местоимением ga, '
        'и ни одна энклитика не может начинать предложение.',
  ),
  ChoiceTask(
    ru: 'Меня зовут Марко.',
    correct: 'Zovem se Marko.',
    wrong: ['Se zovem Marko.', 'Zovem Marko se.', 'Zove me se Marko.'],
    explanation:
        'Возвратное se - тоже энклитика: оно занимает вторую '
        'позицию и не может стоять ни первым, ни в конце.',
  ),
  ChoiceTask(
    ru: 'Ты меня понимаешь?',
    correct: 'Da li me razumeš?',
    wrong: ['Da li razumeš me?', 'Li me razumeš?', 'Da me li razumeš?'],
    explanation:
        'В вопросе с da li энклитика идёт сразу за li: '
        'li → дательный → винительный.',
  ),
  ChoiceTask(
    ru: 'Я вернулся домой.',
    correct: 'Vratio sam se kući.',
    wrong: [
      'Vratio se sam kući.',
      'Sam se vratio kući.',
      'Vratio sam kući se.',
    ],
    explanation: 'Порядок в цепочке: глагольная энклитика sam, затем se.',
  ),
  ChoiceTask(
    ru: 'Мы вам поможем.',
    correct: 'Pomoći ćemo vam.',
    wrong: ['Ćemo vam pomoći.', 'Pomoći vam ćemo.', 'Pomoćićemo vam.'],
    explanation:
        'Глаголы на -ći не сливаются с ću/ćeš: pomoći ćemo, '
        'а не «pomoćićemo».',
  ),
  ChoiceTask(
    ru: 'Она мне не сказала.',
    correct: 'Nije mi rekla.',
    wrong: ['Mi nije rekla.', 'Nije rekla mi.', 'Ne je mi rekla.'],
    explanation:
        'Отрицательная форма nije ударная, поэтому открывает '
        'предложение, а энклитика mi встаёт сразу за ней.',
  ),
  ChoiceTask(
    ru: 'Мне нравится эта книга.',
    correct: 'Ova knjiga mi se sviđa.',
    wrong: [
      'Ova knjiga se mi sviđa.',
      'Mi se ova knjiga sviđa.',
      'Ova knjiga mi sviđa se.',
    ],
    explanation: 'Дательное mi идёт перед se: mi se sviđa.',
  ),
  ChoiceTask(
    ru: 'Я его вчера видел.',
    correct: 'Juče sam ga video.',
    wrong: ['Juče ga sam video.', 'Sam ga juče video.', 'Juče video sam ga.'],
    explanation:
        'Энклитики встают после первого слова - здесь после juče, '
        'причём sam идёт перед ga.',
  ),
  ChoiceTask(
    ru: 'Ему было холодно.',
    correct: 'Bilo mu je hladno.',
    wrong: ['Mu je bilo hladno.', 'Bilo je mu hladno.', 'Hladno mu bilo je.'],
    explanation:
        'Сначала дательное mu, затем je - и обе энклитики '
        'следуют за первым ударным словом bilo.',
  ),
  ChoiceTask(
    ru: 'Дай мне это!',
    correct: 'Daj mi to!',
    wrong: ['Mi daj to!', 'Daj to mi!', 'To daj mi!'],
    explanation:
        'В повелительном предложении энклитика идёт сразу '
        'после глагола.',
  ),
  ChoiceTask(
    ru: 'Я подарил ей книгу.',
    correct: 'Poklonio sam joj knjigu.',
    wrong: [
      'Poklonio joj sam knjigu.',
      'Sam joj poklonio knjigu.',
      'Poklonio sam knjigu joj.',
    ],
    explanation:
        'Порядок неизменен: глагольная энклитика sam, затем '
        'дательное joj.',
  ),
  ChoiceTask(
    ru: 'Мы там были.',
    correct: 'Bili smo tamo.',
    wrong: ['Smo bili tamo.', 'Bili tamo smo.', 'Tamo bili smo.'],
    explanation:
        'Энклитика smo не может открывать предложение и не '
        'уходит в конец: она встаёт после первого ударного слова.',
  ),
];

/// Конструкция «da + настоящее время» вместо инфинитива.
const List<ChoiceTask> kDaConstructionTasks = [
  ChoiceTask(
    ru: 'Я хочу пойти домой.',
    correct: 'Hoću da idem kući.',
    wrong: ['Hoću idem kući.', 'Hoću da idem kuću.', 'Hoću da ideš kući.'],
    explanation:
        'В сербском вместо инфинитива обычно ставят da и глагол '
        'в настоящем времени, согласованный с подлежащим.',
  ),
  ChoiceTask(
    ru: 'Он должен работать.',
    correct: 'On mora da radi.',
    wrong: ['On mora da radim.', 'On mora da radio.', 'On mora radi.'],
    explanation:
        'После mora глагол стоит в том же лице, что и подлежащее: '
        'on mora da radi.',
  ),
  ChoiceTask(
    ru: 'Мы начинаем учить сербский.',
    correct: 'Počinjemo da učimo srpski.',
    wrong: [
      'Počinjemo da učiti srpski.',
      'Počinjemo učimo srpski.',
      'Počinjemo da učim srpski.',
    ],
    explanation: 'После da идёт настоящее время в том же лице: mi - učimo.',
  ),
  ChoiceTask(
    ru: 'Я не могу это сделать.',
    correct: 'Ne mogu to da uradim.',
    wrong: [
      'Ne mogu to da uradiš.',
      'Ne mogu da to uradim.',
      'Ne mogu to uradim.',
    ],
    explanation: 'Между da и глаголом ничего не вставляют: da uradim.',
  ),
  ChoiceTask(
    ru: 'Хочешь пойти со мной?',
    correct: 'Hoćeš li da ideš sa mnom?',
    wrong: [
      'Hoćeš li ideš sa mnom?',
      'Hoćeš da li ideš sa mnom?',
      'Hoćeš li da ideš sa mene?',
    ],
    explanation:
        'Вопрос строится как hoćeš li, дальше da + настоящее время; '
        'после sa нужен инструментал mnom.',
  ),
  ChoiceTask(
    ru: 'Она любит читать книги.',
    correct: 'Ona voli da čita knjige.',
    wrong: [
      'Ona voli da čitam knjige.',
      'Ona voli čita knjige.',
      'Ona voli da čitati knjige.',
    ],
    explanation: 'da + настоящее время в третьем лице: da čita.',
  ),
];

/// Отрицание: слитные формы и двойное отрицание.
const List<ChoiceTask> kNegationTasks = [
  ChoiceTask(
    ru: 'У меня нет времени.',
    correct: 'Nemam vremena.',
    wrong: ['Ne imam vremena.', 'Nemam vreme.', 'Ne mam vremena.'],
    explanation:
        'Глагол imati сливается с отрицанием: nemam. После '
        'отрицания дополнение стоит в родительном падеже: vremena.',
  ),
  ChoiceTask(
    ru: 'Я (муж.) не был там.',
    correct: 'Nisam bio tamo.',
    wrong: ['Ne sam bio tamo.', 'Nije sam bio tamo.', 'Nisam bila tamo.'],
    explanation:
        'biti в отрицании даёт nisam; причастие согласуется '
        'с подлежащим мужского рода: bio.',
  ),
  ChoiceTask(
    ru: 'Я не хочу.',
    correct: 'Neću.',
    wrong: ['Ne hoću.', 'Ne ću.', 'Nisam hoću.'],
    explanation: 'hteti в отрицании даёт слитную форму neću.',
  ),
  ChoiceTask(
    ru: 'Он не знает.',
    correct: 'On ne zna.',
    wrong: ['On nezna.', 'On ne znati.', 'On nije zna.'],
    explanation:
        'С обычными глаголами ne пишется отдельно; слитно только '
        'nisam, neću и nemam.',
  ),
  ChoiceTask(
    ru: 'Дома никого нет.',
    correct: 'Nema nikoga kod kuće.',
    wrong: [
      'Ima nikoga kod kuće.',
      'Nema niko kod kuće.',
      'Ne ima nikoga kod kuće.',
    ],
    explanation:
        'Двойное отрицание обязательно: nema + nikoga, причём '
        'nikoga стоит в родительном падеже.',
  ),
  ChoiceTask(
    ru: 'Я никогда там не был.',
    correct: 'Nikada nisam bio tamo.',
    wrong: [
      'Nikada sam bio tamo.',
      'Nisam nikada ne bio tamo.',
      'Nikada nisam bio tamo ne.',
    ],
    explanation:
        'При отрицательном слове nikada глагол тоже стоит '
        'в отрицательной форме: nikada nisam.',
  ),
];
