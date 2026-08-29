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

  final Widget child;

  /// Включено ли выделение; отдельный параметр нужен для тестов.
  final bool enabled;

  @override
  Widget build(BuildContext context) =>
      enabled ? SelectionArea(child: child) : child;
}
