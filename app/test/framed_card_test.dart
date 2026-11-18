import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Card;
import 'package:spoiled_supper_lotto_game/card.dart';
import 'package:spoiled_supper_lotto_game/card_aspect_ratio.dart';
import 'package:spoiled_supper_lotto_game/framed_card.dart';

void main() {
  group(
    'FramedCard',
    () {
      const sausages = engine.Card(
        id: '1',
        type: engine.CardType.standard,
        category: engine.Category.main,
        name: 'Sausages',
      );

      /// Shows Sausages framed, in a slot [width] logical pixels wide.
      Future<void> pumpCard(WidgetTester tester, {double width = 200}) {
        return tester.pumpWidget(
          MaterialApp(
            home: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: const FramedCard(card: sausages),
              ),
            ),
          ),
        );
      }

      testWidgets(
        'shows the card',
        (tester) async {
          await pumpCard(tester);

          expect(
            tester.widget<Card>(find.byType(Card)).card,
            same(sausages),
          );
        },
      );

      /// Returns the decoration around the card that has [property].
      DecoratedBox decorationWith(
        WidgetTester tester,
        bool Function(BoxDecoration decoration) property,
      ) {
        return tester
            .widgetList<DecoratedBox>(
              find.descendant(
                of: find.byType(FramedCard),
                matching: find.ancestor(
                  of: find.byType(Card),
                  matching: find.byType(DecoratedBox),
                ),
              ),
            )
            .singleWhere((box) => property(box.decoration as BoxDecoration));
      }

      testWidgets(
        'casts a shadow behind the card, with square corners',
        (tester) async {
          await pumpCard(tester);

          final shadow = decorationWith(
            tester,
            (decoration) => decoration.boxShadow != null,
          );
          final decoration = shadow.decoration as BoxDecoration;

          expect(shadow.position, DecorationPosition.background);
          expect(decoration.boxShadow, isNotEmpty);
          expect(decoration.shape, BoxShape.rectangle);
          expect(decoration.borderRadius, isNull);
        },
      );

      testWidgets(
        "outlines the card over its edge in the theme's outline colour",
        (tester) async {
          await pumpCard(tester);

          final outline = decorationWith(
            tester,
            (decoration) => decoration.border != null,
          );
          final decoration = outline.decoration as BoxDecoration;
          final colorScheme = Theme.of(
            tester.element(find.byType(FramedCard)),
          ).colorScheme;

          expect(outline.position, DecorationPosition.foreground);
          expect(
            decoration.border,
            Border.all(color: colorScheme.outlineVariant),
          );
          expect(decoration.borderRadius, isNull);
        },
      );

      testWidgets(
        "fills the slot's width, in the card's shape",
        (tester) async {
          await pumpCard(tester, width: 150);

          expect(
            tester.getSize(find.byType(FramedCard)),
            const Size(150, 150 / cardAspectRatio),
          );
          expect(
            tester.getSize(find.byType(Card)),
            const Size(150, 150 / cardAspectRatio),
          );
        },
      );
    },
  );
}
