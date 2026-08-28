import 'package:srpski_padezi/models/models.dart';

/// Личное местоимение: полные и краткие (энклитические) формы.
///
/// Краткие формы безударны и стоят на втором месте в предложении; полные
/// употребляются под логическим ударением и после предлогов.
class PersonalPronoun {
  const PersonalPronoun({
    required this.nominative,
    required this.ru,
    required this.genitiveFull,
    required this.genitiveShort,
    required this.dativeFull,
    required this.dativeShort,
    required this.accusativeFull,
    required this.accusativeShort,
    required this.instrumental,
  });

  final String nominative;
  final String ru;
  final String genitiveFull;
  final String genitiveShort;
  final String dativeFull;
  final String dativeShort;
  final String accusativeFull;
  final String accusativeShort;
  final String instrumental;

  /// Местный падеж у личных местоимений совпадает с дательным.
  String get locative => dativeFull;

  /// Полная форма в заданном падеже.
  String? fullForm(GramCase c) => switch (c) {
    GramCase.nominativ => nominative,
    GramCase.genitiv => genitiveFull,
    GramCase.dativ => dativeFull,
    GramCase.akuzativ => accusativeFull,
    GramCase.instrumental => instrumental,
    GramCase.lokativ => locative,
    GramCase.vokativ => null,
  };

  /// Краткая форма в заданном падеже (есть только у трёх падежей).
  String? shortForm(GramCase c) => switch (c) {
    GramCase.genitiv => genitiveShort,
    GramCase.dativ => dativeShort,
    GramCase.akuzativ => accusativeShort,
    _ => null,
  };
}

const List<PersonalPronoun> kPronouns = [
  PersonalPronoun(
    nominative: 'ja',
    ru: 'я',
    genitiveFull: 'mene',
    genitiveShort: 'me',
    dativeFull: 'meni',
    dativeShort: 'mi',
    accusativeFull: 'mene',
    accusativeShort: 'me',
    instrumental: 'mnom',
  ),
  PersonalPronoun(
    nominative: 'ti',
    ru: 'ты',
    genitiveFull: 'tebe',
    genitiveShort: 'te',
    dativeFull: 'tebi',
    dativeShort: 'ti',
    accusativeFull: 'tebe',
    accusativeShort: 'te',
    instrumental: 'tobom',
  ),
  PersonalPronoun(
    nominative: 'on',
    ru: 'он',
    genitiveFull: 'njega',
    genitiveShort: 'ga',
    dativeFull: 'njemu',
    dativeShort: 'mu',
    accusativeFull: 'njega',
    accusativeShort: 'ga',
    instrumental: 'njim',
  ),
  PersonalPronoun(
    nominative: 'ona',
    ru: 'она',
    genitiveFull: 'nje',
    genitiveShort: 'je',
    dativeFull: 'njoj',
    dativeShort: 'joj',
    accusativeFull: 'nju',
    accusativeShort: 'je',
    instrumental: 'njom',
  ),
  PersonalPronoun(
    nominative: 'ono',
    ru: 'оно',
    genitiveFull: 'njega',
    genitiveShort: 'ga',
    dativeFull: 'njemu',
    dativeShort: 'mu',
    accusativeFull: 'njega',
    accusativeShort: 'ga',
    instrumental: 'njim',
  ),
  PersonalPronoun(
    nominative: 'mi',
    ru: 'мы',
    genitiveFull: 'nas',
    genitiveShort: 'nas',
    dativeFull: 'nama',
    dativeShort: 'nam',
    accusativeFull: 'nas',
    accusativeShort: 'nas',
    instrumental: 'nama',
  ),
  PersonalPronoun(
    nominative: 'vi',
    ru: 'вы',
    genitiveFull: 'vas',
    genitiveShort: 'vas',
    dativeFull: 'vama',
    dativeShort: 'vam',
    accusativeFull: 'vas',
    accusativeShort: 'vas',
    instrumental: 'vama',
  ),
  PersonalPronoun(
    nominative: 'oni',
    ru: 'они',
    genitiveFull: 'njih',
    genitiveShort: 'ih',
    dativeFull: 'njima',
    dativeShort: 'im',
    accusativeFull: 'njih',
    accusativeShort: 'ih',
    instrumental: 'njima',
  ),
];

/// Притяжательные местоимения - склоняются как прилагательные.
class PossessivePronoun {
  const PossessivePronoun(this.masculine, this.feminine, this.neuter, this.ru);

  final String masculine;
  final String feminine;
  final String neuter;
  final String ru;
}

const List<PossessivePronoun> kPossessives = [
  PossessivePronoun('moj', 'moja', 'moje', 'мой'),
  PossessivePronoun('tvoj', 'tvoja', 'tvoje', 'твой'),
  PossessivePronoun('njegov', 'njegova', 'njegovo', 'его'),
  PossessivePronoun('njen', 'njena', 'njeno', 'её'),
  PossessivePronoun('naš', 'naša', 'naše', 'наш'),
  PossessivePronoun('vaš', 'vaša', 'vaše', 'ваш'),
  PossessivePronoun('njihov', 'njihova', 'njihovo', 'их'),
  PossessivePronoun('svoj', 'svoja', 'svoje', 'свой'),
];
