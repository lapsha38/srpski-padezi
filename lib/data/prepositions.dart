import 'package:srpski_padezi/models/models.dart';

/// Предлог и падеж, которого он требует.
class PrepositionEntry {
  const PrepositionEntry(this.preposition, this.gramCase, this.ru, this.lemma);

  final String preposition;
  final GramCase gramCase;

  /// Перевод предлога на русский.
  final String ru;

  /// Слово из словаря, на котором показывается пример.
  final String lemma;
}

/// Предлоги с падежным управлением.
const List<PrepositionEntry> kPrepositions = [
  PrepositionEntry('iz', GramCase.genitiv, 'из', 'grad'),
  PrepositionEntry('od', GramCase.genitiv, 'от', 'kuća'),
  PrepositionEntry('do', GramCase.genitiv, 'до', 'reka'),
  PrepositionEntry('kod', GramCase.genitiv, 'у', 'lekar'),
  PrepositionEntry('bez', GramCase.genitiv, 'без', 'voda'),
  PrepositionEntry('posle', GramCase.genitiv, 'после', 'posao'),
  PrepositionEntry('oko', GramCase.genitiv, 'вокруг', 'sto'),
  PrepositionEntry('pored', GramCase.genitiv, 'рядом с', 'prozor'),
  PrepositionEntry('ispred', GramCase.genitiv, 'перед', 'škola'),
  PrepositionEntry('iza', GramCase.genitiv, 'за, позади', 'zid'),
  PrepositionEntry('iznad', GramCase.genitiv, 'над', 'krevet'),
  PrepositionEntry('ispod', GramCase.genitiv, 'под', 'most'),
  PrepositionEntry('zbog', GramCase.genitiv, 'из-за', 'bolest'),
  PrepositionEntry('tokom', GramCase.genitiv, 'в течение', 'leto'),
  PrepositionEntry('ka', GramCase.dativ, 'к', 'grad'),
  PrepositionEntry('prema', GramCase.dativ, 'к, по направлению', 'more'),
  PrepositionEntry('kroz', GramCase.akuzativ, 'сквозь, через', 'prozor'),
  PrepositionEntry('uz', GramCase.akuzativ, 'вверх по, вдоль', 'reka'),
  PrepositionEntry('niz', GramCase.akuzativ, 'вниз по', 'ulica'),
  PrepositionEntry('za', GramCase.akuzativ, 'за (цель)', 'sestra'),
  PrepositionEntry('sa', GramCase.instrumental, 'с (вместе)', 'prijatelj'),
  PrepositionEntry('pod', GramCase.instrumental, 'под (где)', 'sto'),
  PrepositionEntry('nad', GramCase.instrumental, 'над (где)', 'grad'),
  PrepositionEntry('pred', GramCase.instrumental, 'перед (где)', 'kuća'),
  PrepositionEntry('među', GramCase.instrumental, 'между', 'prijatelj'),
  PrepositionEntry('o', GramCase.lokativ, 'о, об', 'ljubav'),
  PrepositionEntry('po', GramCase.lokativ, 'по', 'grad'),
  PrepositionEntry('pri', GramCase.lokativ, 'при', 'posao'),
];

/// Пара «куда - где»: одно и то же слово с предлогом u или na.
///
/// Это главная ловушка для русскоязычных: предлог тот же, а падеж меняется
/// в зависимости от того, есть движение или нет.
class PlacePair {
  const PlacePair(this.lemma, this.preposition, this.ruMotion, this.ruPlace);

  final String lemma;

  /// u или na.
  final String preposition;

  /// Перевод предложения с движением.
  final String ruMotion;

  /// Перевод предложения о месте.
  final String ruPlace;
}

/// Слова, на которых тренируется пара «куда - где».
const List<PlacePair> kPlacePairs = [
  PlacePair('grad', 'u', 'Я еду в город.', 'Сейчас я в городе.'),
  PlacePair('škola', 'u', 'Я иду в школу.', 'Сейчас я в школе.'),
  PlacePair('restoran', 'u', 'Я иду в ресторан.', 'Сейчас я в ресторане.'),
  PlacePair(
    'prodavnica',
    'u',
    'Я иду в магазин.',
    'Сейчас я в магазине.',
  ),
  PlacePair('soba', 'u', 'Я иду в комнату.', 'Сейчас я в комнате.'),
  PlacePair('dvorište', 'u', 'Я иду во двор.', 'Сейчас я во дворе.'),
  PlacePair('more', 'na', 'Я еду на море.', 'Сейчас я на море.'),
  PlacePair('plaža', 'na', 'Я иду на пляж.', 'Сейчас я на пляже.'),
  PlacePair('planina', 'na', 'Я еду в горы.', 'Сейчас я в горах.'),
  PlacePair('posao', 'na', 'Я иду на работу.', 'Сейчас я на работе.'),
  PlacePair('selo', 'na', 'Я еду в село.', 'Сейчас я в селе.'),
];
