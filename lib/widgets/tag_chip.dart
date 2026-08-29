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

/// Цветная метка числа.
class NumberChip extends StatelessWidget {
  const NumberChip(this.number, {this.label, super.key});

  final GramNumber number;

  /// Текст метки; по умолчанию - короткое название числа.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = numberBadgeColors(number, Theme.of(context).brightness);
    return Chip(
      label: Text(label ?? number.ruShort),
      backgroundColor: colors.background,
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: colors.foreground,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Метка задания: число выделяется цветом, остальные метки нейтральны.
class TagChip extends StatelessWidget {
  const TagChip(this.tag, {super.key});

  final String tag;

  @override
  Widget build(BuildContext context) {
    final number = gramNumberFromLabel(tag);
    if (number != null) return NumberChip(number);
    return Chip(label: Text(tag), visualDensity: VisualDensity.compact);
  }
}
