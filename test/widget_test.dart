import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srpski_padezi/logic/phrase_table.dart';
import 'package:srpski_padezi/logic/quiz_engine.dart';
import 'package:srpski_padezi/main.dart';
import 'package:srpski_padezi/models/models.dart';
import 'package:srpski_padezi/screens/phrase_table_screen.dart';
import 'package:srpski_padezi/screens/quiz_screen.dart';
import 'package:srpski_padezi/screens/result_screen.dart';
import 'package:srpski_padezi/services/progress_service.dart';
import 'package:srpski_padezi/services/theme_service.dart';
import 'package:srpski_padezi/widgets/selectable_on_web.dart';
import 'package:srpski_padezi/widgets/tag_chip.dart';

void main() {
  group('Интерфейс', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await ProgressService.instance.reset();
      await ThemeService.instance.setMode(ThemeMode.system);
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

      const last = 'Vokativ - звательный';
      await tester.scrollUntilVisible(
        find.text(last),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text(last));
      await tester.pumpAndSettle();
      await tester.tap(find.text(last));
      await tester.pumpAndSettle();

      expect(find.text('7. Vokativ'), findsOneWidget);
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

    testWidgets('метки числа покрашены в разные цвета', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                NumberChip(GramNumber.singular),
                NumberChip(GramNumber.plural),
              ],
            ),
          ),
        ),
      );

      final chips = tester.widgetList<Chip>(find.byType(Chip)).toList();
      expect(chips.length, 2);
      expect(chips[0].backgroundColor, isNot(chips[1].backgroundColor));
      expect(
        chips[0].backgroundColor,
        numberBadgeColors(GramNumber.singular, Brightness.light).background,
      );
      expect(
        chips[1].backgroundColor,
        numberBadgeColors(GramNumber.plural, Brightness.light).background,
      );
    });

    testWidgets('метки рода покрашены в разные цвета', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                GenderChip(Gender.masculine),
                GenderChip(Gender.feminine),
                GenderChip(Gender.neuter),
              ],
            ),
          ),
        ),
      );

      final chips = tester.widgetList<Chip>(find.byType(Chip)).toList();
      expect(chips.length, 3);
      final backgrounds = chips.map((c) => c.backgroundColor).toSet();
      expect(backgrounds.length, 3);
      for (final (index, gender) in Gender.values.indexed) {
        expect(
          chips[index].backgroundColor,
          genderBadgeColors(gender, Brightness.light).background,
        );
      }
    });

    testWidgets('таблица склонения заполняется выбором формы', (tester) async {
      await tester.pumpWidget(const SrpskiPadeziApp());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Таблица склонения'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Таблица склонения'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Таблица склонения'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Заполнено 0 из 7'), findsOneWidget);
      expect(find.text('выбрать'), findsNWidgets(7));

      // Первая строка: открываем варианты и выбираем любой.
      await tester.tap(find.text('выбрать').first);
      await tester.pumpAndSettle();
      expect(find.text('Правило'), findsOneWidget);

      // Форма собирается из двух выборов: прилагательное, затем
      // существительное. После первого лист ещё открыт.
      await tester.tap(find.byType(OutlinedButton).first);
      await tester.pumpAndSettle();
      expect(find.textContaining('Заполнено 0 из 7'), findsOneWidget);
      await tester.tap(find.byType(OutlinedButton).last);
      await tester.pumpAndSettle();

      expect(find.textContaining('Заполнено 1 из 7'), findsOneWidget);
      expect(find.text('выбрать'), findsNWidgets(6));
    });

    testWidgets('таблица не ломает вёрстку на длинных формах', (tester) async {
      // Формы бывают длинные («jednostavnim mogućnostima»), а экран узкий:
      // прогоняем много разных пар слов на телефонной ширине.
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      for (var seed = 0; seed < 40; seed++) {
        await tester.pumpWidget(
          MaterialApp(
            home: PhraseTableScreen(
              key: ValueKey(seed),
              generator: PhraseTableGenerator(Random(seed)),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Заполняем первую строку: так проверяется и вид с ответом.
        await tester.tap(find.text('выбрать').first);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OutlinedButton).first);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OutlinedButton).last);
        await tester.pumpAndSettle();

        expect(find.textContaining('Заполнено 1 из 7'), findsOneWidget);
      }
    });

    testWidgets('на вебе всё приложение выделяется без ошибок', (tester) async {
      // SelectionArea требует предка Overlay. Если поставить её выше
      // навигатора, приложение падает - но только на вебе, поэтому веб-ветку
      // включаем принудительно и проходим по экранам.
      SelectableOnWeb.debugForceEnabled = true;
      addTearDown(() => SelectableOnWeb.debugForceEnabled = false);

      await tester.pumpWidget(const SrpskiPadeziApp());
      await tester.pumpAndSettle();
      expect(find.byType(SelectionArea), findsWidgets);

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
      expect(find.textContaining('Вопрос 1 из'), findsOneWidget);

      // Правило открывается отдельным маршрутом - там своя обёртка.
      await tester.tap(find.text('Правило'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
    });

    testWidgets('на вебе текст можно выделить', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SelectableOnWeb(enabled: true, child: Text('lepa knjiga')),
        ),
      );
      expect(find.byType(SelectionArea), findsOneWidget);

      // На телефоне выделение выключено и лишнего слоя нет.
      await tester.pumpWidget(
        const MaterialApp(
          home: SelectableOnWeb(enabled: false, child: Text('lepa knjiga')),
        ),
      );
      expect(find.byType(SelectionArea), findsNothing);
    });

    testWidgets('кнопка в шапке переключает светлую и тёмную тему', (
      tester,
    ) async {
      await tester.pumpWidget(const SrpskiPadeziApp());
      await tester.pumpAndSettle();

      Brightness brightness() =>
          Theme.of(tester.element(find.text('Srpski Padeži'))).brightness;

      expect(brightness(), Brightness.light);
      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.dark_mode_outlined));
      await tester.pumpAndSettle();

      expect(brightness(), Brightness.dark);
      expect(ThemeService.instance.mode, ThemeMode.dark);
      expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.light_mode_outlined));
      await tester.pumpAndSettle();

      expect(brightness(), Brightness.light);
      expect(ThemeService.instance.mode, ThemeMode.light);
    });

    testWidgets('выбранная тема переживает перезапуск', (tester) async {
      await ThemeService.instance.setMode(ThemeMode.dark);
      await ThemeService.instance.setMode(ThemeMode.system);
      // Выбор лежит в хранилище, поэтому после загрузки он возвращается.
      SharedPreferences.setMockInitialValues({'srpski_padezi_theme': 'dark'});
      await ThemeService.instance.load();

      await tester.pumpWidget(const SrpskiPadeziApp());
      await tester.pumpAndSettle();

      expect(
        Theme.of(tester.element(find.text('Srpski Padeži'))).brightness,
        Brightness.dark,
      );
    });

    /// Разбор тренировки, где все ответы верны.
    Future<void> pumpResult(WidgetTester tester, QuizSession session) async {
      final answers = [
        for (final q in session.build())
          AnswerRecord(question: q, given: q.answer, correct: true),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: ResultScreen(answers: answers, session: session),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('после единственного числа предлагается множественное', (
      tester,
    ) async {
      await pumpResult(
        tester,
        QuizPresets.forCase(GramCase.nominativ, NumberMode.singular),
      );

      expect(find.text('Дальше: множественное число'), findsOneWidget);
      // Пока у урока есть продолжение, следующий падеж не предлагается.
      expect(find.textContaining('Следующий падеж'), findsNothing);

      await tester.tap(find.text('Дальше: множественное число'));
      await tester.pumpAndSettle();
      expect(find.text('Nominativ - множественное число'), findsOneWidget);
      expect(find.textContaining('Вопрос 1 из'), findsOneWidget);
    });

    testWidgets('при слабом результате первой стоит кнопка повтора', (
      tester,
    ) async {
      final session = QuizPresets.forCase(
        GramCase.nominativ,
        NumberMode.singular,
      );
      final answers = [
        for (final q in session.build())
          AnswerRecord(question: q, given: 'мимо', correct: false),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: ResultScreen(answers: answers, session: session),
        ),
      );
      await tester.pumpAndSettle();

      // Порог не взят: продолжение предлагается, но вторым.
      expect(
        tester.getTopLeft(find.text('Пройти ещё раз')).dy,
        lessThan(
          tester.getTopLeft(find.text('Дальше: множественное число')).dy,
        ),
      );
    });

    testWidgets('после множественного предлагается смешанная тренировка', (
      tester,
    ) async {
      await pumpResult(
        tester,
        QuizPresets.forCase(GramCase.nominativ, NumberMode.plural),
      );
      expect(find.text('Дальше: оба числа вперемешку'), findsOneWidget);
    });

    testWidgets('после смешанной тренировки предлагается следующий падеж', (
      tester,
    ) async {
      await pumpResult(
        tester,
        QuizPresets.forCase(GramCase.nominativ, NumberMode.mixed),
      );
      expect(find.textContaining('Дальше:'), findsNothing);
      expect(find.text('Следующий падеж: Akuzativ'), findsOneWidget);
    });

    testWidgets('словосочетание собирается из прилагательного и '
        'существительного', (tester) async {
      final question = QuizGenerator(Random(1))
          .generate(
            const QuizConfig(
              cases: [GramCase.lokativ],
              numberMode: NumberMode.singular,
              practiceMode: PracticeMode.phrases,
              questionCount: 1,
            ),
          )
          .single;
      final session = QuizSession(title: 'Тест', build: () => [question]);
      // Обе части и пояснение должны поместиться без прокрутки.
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: QuizScreen(session: session)));
      await tester.pumpAndSettle();

      expect(find.text('Прилагательное'), findsOneWidget);
      expect(find.text('Существительное'), findsOneWidget);

      final [adjective, noun] = question.parts;
      await tester.tap(find.text(adjective.answer));
      await tester.pumpAndSettle();
      // Пока выбрана одна часть, ответ не засчитан.
      expect(find.text('Верно!'), findsNothing);

      await tester.tap(find.text(noun.answer));
      await tester.pumpAndSettle();
      expect(find.text('Верно!'), findsOneWidget);
    });
  });
}
