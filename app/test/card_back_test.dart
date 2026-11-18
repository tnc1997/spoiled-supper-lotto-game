import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/card_aspect_ratio.dart';
import 'package:spoiled_supper_lotto_game/card_back.dart';
import 'package:spoiled_supper_lotto_game/card_size.dart';

void main() {
  group(
    'CardBack',
    () {
      testWidgets(
        "is the theme's primary container colour",
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: CardBack()));

          final colorScheme = Theme.of(
            tester.element(find.byType(CardBack)),
          ).colorScheme;

          expect(
            tester
                .widget<Container>(
                  find.descendant(
                    of: find.byType(CardBack),
                    matching: find.byType(Container),
                  ),
                )
                .color,
            colorScheme.primaryContainer,
          );
        },
      );

      testWidgets(
        "fills its parent's width, in the card's shape",
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 150,
                  height: 150 / cardAspectRatio,
                  child: CardBack(),
                ),
              ),
            ),
          );

          expect(
            tester.getRect(find.byType(Container)).size,
            const Size(150, 150 / cardAspectRatio),
          );
        },
      );

      testWidgets(
        'shows at the card size in an unbounded parent',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Center(child: UnconstrainedBox(child: CardBack())),
            ),
          );

          expect(tester.getSize(find.byType(CardBack)), cardSize);
        },
      );
    },
  );
}
