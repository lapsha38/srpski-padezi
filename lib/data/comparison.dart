/// Прилагательное в трёх степенях сравнения.
class ComparisonEntry {
  const new(
    this.positive,
    this.comparative,
    this.superlative,
    this.ru, {
    this.irregular = false,
    this.note,
  });

  /// Положительная степень: lep.
  final String positive;

  /// Сравнительная степень: lepši.
  final String comparative;

  /// Превосходная степень: najlepši.
  final String superlative;

  final String ru;

  /// Форма образуется не по общему правилу.
  final bool irregular;

  final String? note;
}

/// Степени сравнения прилагательных.
const List<ComparisonEntry> kComparisons = [
  ComparisonEntry('lep', 'lepši', 'najlepši', 'красивый'),
  ComparisonEntry('nov', 'noviji', 'najnoviji', 'новый'),
  ComparisonEntry('star', 'stariji', 'najstariji', 'старый'),
  ComparisonEntry(
    'mlad',
    'mlađi',
    'najmlađi',
    'молодой',
    note: 'd + j → đ: mlad → mlađi.',
  ),
  ComparisonEntry('velik', 'veći', 'najveći', 'большой', irregular: true),
  ComparisonEntry('mali', 'manji', 'najmanji', 'маленький', irregular: true),
  ComparisonEntry('dobar', 'bolji', 'najbolji', 'хороший', irregular: true),
  ComparisonEntry('loš', 'gori', 'najgori', 'плохой', irregular: true),
  ComparisonEntry('visok', 'viši', 'najviši', 'высокий'),
  ComparisonEntry('nizak', 'niži', 'najniži', 'низкий'),
  ComparisonEntry('dug', 'duži', 'najduži', 'длинный'),
  ComparisonEntry('kratak', 'kraći', 'najkraći', 'короткий'),
  ComparisonEntry('jak', 'jači', 'najjači', 'сильный'),
  ComparisonEntry('slab', 'slabiji', 'najslabiji', 'слабый'),
  ComparisonEntry('brz', 'brži', 'najbrži', 'быстрый'),
  ComparisonEntry('spor', 'sporiji', 'najsporiji', 'медленный'),
  ComparisonEntry('težak', 'teži', 'najteži', 'тяжёлый, трудный'),
  ComparisonEntry('lak', 'lakši', 'najlakši', 'лёгкий'),
  ComparisonEntry(
    'skup',
    'skuplji',
    'najskuplji',
    'дорогой',
    note: 'p + j → plj: skup → skuplji.',
  ),
  ComparisonEntry('jeftin', 'jeftiniji', 'najjeftiniji', 'дешёвый'),
  ComparisonEntry('topao', 'topliji', 'najtopliji', 'тёплый'),
  ComparisonEntry('hladan', 'hladniji', 'najhladniji', 'холодный'),
  ComparisonEntry('pametan', 'pametniji', 'najpametniji', 'умный'),
  ComparisonEntry('zanimljiv', 'zanimljiviji', 'najzanimljiviji', 'интересный'),
];
