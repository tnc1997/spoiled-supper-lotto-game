import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/card_aspect_ratio.dart';
import 'package:spoiled_supper_lotto_game/empty_slot.dart';

void main() {
  group(
    'EmptySlot',
    () {
      /// Shows an empty slot labelled Dessert, in a slot [width] logical
      /// pixels wide.
      Future<void> pumpSlot(WidgetTester tester, {double width = 200}) {
        return tester.pumpWidget(
          MaterialApp(
            home: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: const EmptySlot(label: 'Dessert'),
              ),
            ),
          ),
        );
      }

      testWidgets(
        'shows the label',
        (tester) async {
          await pumpSlot(tester);

          expect(find.text('Dessert'), findsOneWidget);
        },
      );

      testWidgets(
        "is plain, in the theme's lowest container colour",
        (tester) async {
          await pumpSlot(tester);

          final colorScheme = Theme.of(
            tester.element(find.byType(EmptySlot)),
          ).colorScheme;

          expect(
            tester
                .widget<ColoredBox>(
                  find.descendant(
                    of: find.byType(EmptySlot),
                    matching: find.byType(ColoredBox),
                  ),
                )
                .color,
            colorScheme.surfaceContainerLowest,
          );
        },
      );

      testWidgets(
        "fills the slot's width, in the card's shape",
        (tester) async {
          await pumpSlot(tester, width: 150);

          expect(
            tester.getSize(find.byType(EmptySlot)),
            const Size(150, 150 / cardAspectRatio),
          );
        },
      );
    },
  );
}
