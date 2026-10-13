import 'package:flutter/material.dart';
import 'package:srpski_padezi/models/models.dart';

/// Цвета метки числа: «ед. ч.» и «мн. ч.» различаются одной буквой,
/// поэтому число различает цвет, а не текст.
({Color background, Color foreground}) numberBadgeColors(
  GramNumber number,
  Brightness brightness,
) {
  final dark = brightness == Brightness.dark;
  return switch (number) {
    GramNumber.singular =>
      dark
          ? (background: Colors.green.shade400, foreground: Colors.black87)
          : (background: Colors.green.shade800, foreground: Colors.white),
    GramNumber.plural =>
      dark
          ? (background: Colors.amber.shade400, foreground: Colors.black87)
          : (background: Colors.amber.shade700, foreground: Colors.black87),
  };
}

/// Цвета метки рода: род виден по цвету раньше, чем прочитан текст.
({Color background, Color foreground}) genderBadgeColors(
  Gender gender,
  Brightness brightness,
) {
  final dark = brightness == Brightness.dark;
  return switch (gender) {
    Gender.masculine =>
      dark
          ? (background: Colors.blue.shade300, foreground: Colors.black87)
          : (background: Colors.blue.shade700, foreground: Colors.white),
    Gender.feminine =>
      dark
          ? (background: Colors.pink.shade200, foreground: Colors.black87)
          : (background: Colors.pink.shade600, foreground: Colors.white),
    Gender.neuter =>
      dark
          ? (background: Colors.deepPurple.shade200, foreground: Colors.black87)
          : (background: Colors.deepPurple.shade400, foreground: Colors.white),
  };
}

/// Цветная метка числа.
class NumberChip extends StatelessWidget {
  const new(this.number, {this.label, super.key});

  final GramNumber number;

  /// Текст метки; по умолчанию - короткое название числа.
  final String? label;

  @override
  Widget build(BuildContext context) => _ColoredChip(
    label: label ?? number.ruShort,
    colors: numberBadgeColors(number, Theme.of(context).brightness),
  );
}

/// Цветная метка рода.
class GenderChip extends StatelessWidget {
  const new(this.gender, {this.label, super.key});

  final Gender gender;

  /// Текст метки; по умолчанию - название рода.
  final String? label;

  @override
  Widget build(BuildContext context) => _ColoredChip(
    label: label ?? gender.ru,
    colors: genderBadgeColors(gender, Theme.of(context).brightness),
  );
}

/// Метка задания: число выделяется цветом, остальные метки нейтральны.
class TagChip extends StatelessWidget {
  const new(this.tag, {super.key});

  final String tag;

  @override
  Widget build(BuildContext context) {
    final number = gramNumberFromLabel(tag);
    if (number != null) return NumberChip(number);
    return Chip(label: Text(tag), visualDensity: VisualDensity.compact);
  }
}

class _ColoredChip extends StatelessWidget {
  const new({required this.label, required this.colors});

  final String label;
  final ({Color background, Color foreground}) colors;

  @override
  Widget build(BuildContext context) => Chip(
    label: Text(label),
    backgroundColor: colors.background,
    labelStyle: Theme.of(context).textTheme.labelLarge
        ?.copyWith(color: colors.foreground, fontWeight: FontWeight.w600),
    side: BorderSide.none,
    visualDensity: VisualDensity.compact,
  );
}
