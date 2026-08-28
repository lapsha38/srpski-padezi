import 'package:flutter/material.dart';

/// Стандартная тема Material 3 - без кастомных цветов и шрифтов.
class AppTheme {
  static ThemeData light() => ThemeData(useMaterial3: true);

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
  );
}

/// Максимальная ширина контента - чтобы в браузере на широком экране
/// текст не растягивался на всю страницу.
const double kContentMaxWidth = 720;

/// Ограничивает ширину содержимого и центрирует его.
class ContentWidth extends StatelessWidget {
  const ContentWidth({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: kContentMaxWidth),
      child: child,
    ),
  );
}
