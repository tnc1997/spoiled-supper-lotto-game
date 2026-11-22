import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/spoiled_reveal.dart';

void main() {
  group(
    'SpoiledReveal',
    () {
      const duration = Duration(milliseconds: 600);
      const cardKey = Key('card');

      /// Reveals a card, with the given text size and animations disabled
      /// if [disableAnimations].
      Future<void> pumpReveal(
        WidgetTester tester, {
        bool disableAnimations = false,
        TextScaler textScaler = TextScaler.noScaling,
      }) {
        return tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                disableAnimations: disableAnimations,
                textScaler: textScaler,
              ),
              child: const Center(
                child: SpoiledReveal(
                  duration: duration,
                  child: SizedBox(key: cardKey, width: 120, height: 180),
                ),
              ),
            ),
          ),
        );
      }

      /// How far the card is from where it rests, sideways.
      double shakeOf(WidgetTester tester) {
        return tester.getCenter(find.byKey(cardKey)).dx -
            tester.getCenter(find.byType(SpoiledReveal)).dx;
      }

      testWidgets(
        'calls out the card in the displaySmall text style',
        (tester) async {
          await pumpReveal(tester);

          expect(
            tester.widget<Text>(find.text('Spoiled!')).style?.fontSize,
            Theme.of(
              tester.element(find.byType(SpoiledReveal)),
            ).textTheme.displaySmall?.fontSize,
          );
        },
      );

      testWidgets(
        'shakes the card, then settles',
        (tester) async {
          await pumpReveal(tester);
          await tester.pump(duration ~/ 16);

          expect(shakeOf(tester), isNot(moreOrLessEquals(0)));

          await tester.pumpAndSettle();

          expect(shakeOf(tester), moreOrLessEquals(0));
        },
      );

      testWidgets(
        'does not shake the card if animations are disabled',
        (tester) async {
          await pumpReveal(tester, disableAnimations: true);
          await tester.pump(duration ~/ 16);

          expect(shakeOf(tester), moreOrLessEquals(0));
          expect(find.text('Spoiled!'), findsOneWidget);
        },
      );

      testWidgets(
        'keeps the callout the same size with a larger text size',
        (tester) async {
          await pumpReveal(tester);

          final size = tester.getSize(find.text('Spoiled!'));

          await pumpReveal(tester, textScaler: const TextScaler.linear(2));

          expect(tester.getSize(find.text('Spoiled!')), size);
        },
      );

      testWidgets(
        'leaves the callout out of the semantics tree',
        (tester) async {
          await pumpReveal(tester);

          expect(find.bySemanticsLabel('Spoiled!'), findsNothing);
        },
      );
    },
  );
}
