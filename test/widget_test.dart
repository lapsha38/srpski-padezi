import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srpski_padezi/main.dart';
import 'package:srpski_padezi/services/progress_service.dart';

void main() {
  group('Интерфейс', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await ProgressService.instance.reset();
    });

    testWidgets('на главном экране есть падежи и раздел числительных', (
      tester,
    ) async {
      await tester.pumpWidget(const SrpskiPadeziApp());
      await tester.pumpAndSettle();

      expect(find.text('Srpski Padeži'), findsOneWidget);
      expect(find.textContaining('Nominativ'), findsWidgets);
      await tester.scrollUntilVisible(find.text('Числительные'), 200);
      expect(find.text('Числительные'), findsOneWidget);
    });

    testWidgets('первый падеж открывается и запускает тренировку', (
      tester,
    ) async {
      await tester.pumpWidget(const SrpskiPadeziApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nominativ - именительный'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Множественное число'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Множественное число'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Множественное число'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Вопрос 1 из'), findsOneWidget);
    });

    testWidgets('ответ на вопрос показывает пояснение', (tester) async {
      await tester.pumpWidget(const SrpskiPadeziApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nominativ - именительный'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Единственное число'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Единственное число'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Единственное число'));
      await tester.pumpAndSettle();

      // Отвечаем первым вариантом - важно, что экран реагирует в любом случае.
      final option = find.byType(OutlinedButton).first;
      await tester.tap(option);
      await tester.pumpAndSettle();

      // После ответа кнопка перехода к следующему вопросу становится активной.
      final next = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Дальше'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(next.onPressed, isNotNull);
    });

    testWidgets('последний падеж доступен без прохождения предыдущих', (
      tester,
    ) async {
      await tester.pumpWidget(const SrpskiPadeziApp());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Lokativ - предложный (местный)'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Lokativ - предложный (местный)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lokativ - предложный (местный)'));
      await tester.pumpAndSettle();

      expect(find.text('7. Lokativ'), findsOneWidget);
    });

    testWidgets('раздел грамматики открывается и запускает тренировку', (
      tester,
    ) async {
      await tester.pumpWidget(const SrpskiPadeziApp());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Грамматика'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Грамматика'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Грамматика'));
      await tester.pumpAndSettle();

      expect(find.text('Настоящее время'), findsWidgets);
      await tester.tap(find.text('Настоящее время').first);
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Тренировка'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Начать').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Начать').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('Вопрос 1 из'), findsOneWidget);
    });

    testWidgets('во время тренировки можно открыть правило', (tester) async {
      await tester.pumpWidget(const SrpskiPadeziApp());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Числительные'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Числительные'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Числительные'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Тренировки'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Начать').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Начать').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Правило'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
    });
  });
}
