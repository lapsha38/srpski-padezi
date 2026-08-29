import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Включает выделение текста на вебе: в браузере ждут поведения обычной
/// страницы, а на телефоне выделение мешает нажатиям.
class SelectableOnWeb extends StatelessWidget {
  const SelectableOnWeb({
    required this.child,
    this.enabled = kIsWeb,
    super.key,
  });

  /// Включает выделение в тестах: [kIsWeb] в них всегда false.
  @visibleForTesting
  static bool debugForceEnabled = false;

  final Widget child;

  /// Включено ли выделение; отдельный параметр нужен для тестов.
  final bool enabled;

  @override
  Widget build(BuildContext context) =>
      enabled || debugForceEnabled ? SelectionArea(child: child) : child;
}
