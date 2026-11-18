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

      testWidgets(
        'rounds the corners and casts a shadow',
        (tester) async {
          await pumpCard(tester);

          final model = tester.widget<PhysicalModel>(
            find.ancestor(
              of: find.byType(Card),
              matching: find.byType(PhysicalModel),
            ),
          );

          expect(model.borderRadius, FramedCard.borderRadius);
          expect(model.clipBehavior, isNot(Clip.none));
          expect(model.elevation, greaterThan(0));
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
