import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Делает текст выделяемым на вебе.
///
/// Веб-версию открывают в браузере, и там ожидают обычного поведения
/// страницы: слово можно выделить мышью и скопировать. На телефоне
/// выделение только мешает - там по тексту нажимают, а не выделяют его, -
/// поэтому обёртка включается только на вебе.
class SelectableOnWeb extends StatelessWidget {
  const SelectableOnWeb({
    required this.child,
    this.enabled = kIsWeb,
    super.key,
  });

  /// Включает выделение во всём приложении в тестах.
  ///
  /// В тестах [kIsWeb] всегда false, поэтому иначе веб-ветка не проверялась
  /// бы вовсе - а именно в ней [SelectionArea] может не найти [Overlay].
  @visibleForTesting
  static bool debugForceEnabled = false;

  final Widget child;

  /// Включено ли выделение; отдельный параметр нужен для тестов.
  final bool enabled;

  @override
  Widget build(BuildContext context) =>
      enabled || debugForceEnabled ? SelectionArea(child: child) : child;
}
