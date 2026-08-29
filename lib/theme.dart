import 'package:flutter/material.dart';
import 'package:srpski_padezi/widgets/selectable_on_web.dart';

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

/// Ограничивает ширину содержимого, центрирует его и включает выделение
/// текста на вебе.
///
/// Через этот контейнер проходит содержимое каждого экрана, поэтому здесь же
/// удобно включить выделение. Выше по дереву его ставить нельзя:
/// [SelectionArea] требует предка [Overlay], а он появляется только внутри
/// маршрута навигатора.
class ContentWidth extends StatelessWidget {
  const ContentWidth({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: kContentMaxWidth),
      child: SelectableOnWeb(child: child),
    ),
  );
}
