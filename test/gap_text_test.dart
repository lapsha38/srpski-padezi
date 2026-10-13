import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srpski_padezi/data/nouns.dart';
import 'package:srpski_padezi/data/texts.dart';
import 'package:srpski_padezi/logic/gap_check.dart';
import 'package:srpski_padezi/models/models.dart';
import 'package:srpski_padezi/screens/gap_text_screen.dart';

void main() {
  group('Тексты с пропусками', () {
    test('число пропусков в тексте совпадает со списком', () {
      for (final text in kGapTexts) {
        expect(text.pieces.length, text.gaps.length + 1, reason: text.title);
      }
    });

    test('у каждого пропуска есть форма в словаре', () {
      for (final text in kGapTexts) {
        for (final gap in text.gaps) {
          final noun = kNounsByLemma[gap.lemma];
          expect(noun, isNotNull, reason: '${text.title}: ${gap.lemma}');
          expect(
            noun!.form(gap.gramCase, gap.number),
            isNotNull,
            reason: '${text.title}: ${gap.lemma}',
          );
        }
      }
    });

    test('пропуск не совпадает со словарной формой из скобок', () {
      // Номинатив единственного числа - это и есть подсказка в скобках.
      for (final text in kGapTexts) {
        for (final gap in text.gaps) {
          expect(
            gap.gramCase == GramCase.nominativ &&
                gap.number == GramNumber.singular,
            isFalse,
            reason: '${text.title}: ${gap.lemma}',
          );
        }
      }
    });

    test('ключи текстов уникальны', () {
      final ids = kGapTexts.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });

  group('Разбор ответа', () {
    const lokativ = TextGap('grad', GramCase.lokativ, GramNumber.singular, '');

    test('верная форма засчитывается без учёта регистра и пробелов', () {
      expect(checkGap(lokativ, ' Gradu ').verdict, GapVerdict.correct);
    });

    test('другой падеж того же числа назван по имени', () {
      final result = checkGap(lokativ, 'grada');
      expect(result.verdict, GapVerdict.wrongCase);
      expect(result.message, contains('родительный'));
      expect(result.isCorrect, isFalse);
    });

    test('совпадающие формы разных падежей перечисляются', () {
      // gradom - только инструментал, grad - номинатив и аккузатив.
      final result = checkGap(lokativ, 'grad');
      expect(result.message, contains('именительный или винительный'));
    });

    test('верный падеж в другом числе', () {
      final result = checkGap(lokativ, 'gradovima');
      expect(result.verdict, GapVerdict.wrongNumber);
      expect(result.message, contains('Падеж верный'));
    });

    test('другой падеж в другом числе', () {
      final result = checkGap(lokativ, 'gradova');
      expect(result.verdict, GapVerdict.wrongNumber);
      expect(result.message, contains('родительный'));
    });

    test('несуществующая форма', () {
      final result = checkGap(lokativ, 'gradi');
      expect(result.verdict, GapVerdict.wrongForm);
      expect(result.message, contains('gradu'));
    });

    test('без диакритики - верно, но с замечанием', () {
      const gap = TextGap('kuća', GramCase.lokativ, GramNumber.singular, '');
      final result = checkGap(gap, 'kuci');
      expect(result.verdict, GapVerdict.diacritics);
      expect(result.isCorrect, isTrue);
      expect(result.message, contains('kući'));
    });

    test('пустой пропуск - ошибка', () {
      expect(checkGap(lokativ, '  ').verdict, GapVerdict.empty);
    });
  });

  group('Экран', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    testWidgets('после проверки видны верные ответы и разбор ошибок', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final text = kGapTexts.first;
      await tester.pumpWidget(MaterialApp(home: GapTextScreen(text: text)));

      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(text.gaps.length));

      // Первый пропуск - верно, второй - другим падежом, остальные пусты.
      await tester.enterText(fields.at(0), gapAnswer(text.gaps[0]));
      final second = kNounsByLemma[text.gaps[1].lemma]!;
      await tester.enterText(
        fields.at(1),
        second.form(GramCase.nominativ, GramNumber.singular)!,
      );

      // Буква с диакритикой уходит в поле, где стоит курсор.
      await tester.tap(fields.at(2));
      await tester.tap(find.text('š'));
      await tester.pump();
      expect(find.widgetWithText(TextField, 'š'), findsOneWidget);

      await tester.tap(find.text('Проверить'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
      expect(find.textContaining('Верно 1 из ${text.gaps.length}'), findsOne);
      expect(find.textContaining('Это именительный'), findsOneWidget);
      expect(find.text('Пропуск не заполнен.'), findsWidgets);

      await tester.tap(find.text('Ещё раз'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNWidgets(text.gaps.length));
    });
  });
}
