import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/card_aspect_ratio.dart';
import 'package:spoiled_supper_lotto_game/card_frame.dart';

void main() {
  group(
    'CardFrame',
    () {
      const child = ColoredBox(color: Colors.red);

      /// Frames [child] in a slot [width] logical pixels wide.
      Future<void> pumpFrame(WidgetTester tester, {double width = 200}) {
        return tester.pumpWidget(
          MaterialApp(
            home: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: const CardFrame(child: child),
              ),
            ),
          ),
        );
      }

      testWidgets(
        'shows the child',
        (tester) async {
          await pumpFrame(tester);

          expect(find.byWidget(child), findsOneWidget);
        },
      );

      testWidgets(
        'casts a shadow behind the child and outlines it',
        (tester) async {
          await pumpFrame(tester);

          final boxes = tester
              .widgetList<DecoratedBox>(
                find.descendant(
                  of: find.byType(CardFrame),
                  matching: find.byType(DecoratedBox),
                ),
              )
              .toList();
          final colorScheme = Theme.of(
            tester.element(find.byType(CardFrame)),
          ).colorScheme;

          expect(
            boxes.map((box) => (box.decoration as BoxDecoration).boxShadow),
            contains(isNotEmpty),
          );
          expect(
            boxes.where(
              (box) =>
                  box.position == DecorationPosition.foreground &&
                  (box.decoration as BoxDecoration).border ==
                      Border.all(color: colorScheme.outlineVariant),
            ),
            hasLength(1),
          );
        },
      );

      testWidgets(
        'has square corners, like the physical cards',
        (tester) async {
          await pumpFrame(tester);

          final decorations = tester.widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(CardFrame),
              matching: find.byType(DecoratedBox),
            ),
          );

          for (final box in decorations) {
            final decoration = box.decoration as BoxDecoration;

            expect(decoration.shape, BoxShape.rectangle);
            expect(decoration.borderRadius, isNull);
          }
        },
      );

      testWidgets(
        "fills the slot's width, in the card's shape",
        (tester) async {
          await pumpFrame(tester, width: 150);

          expect(
            tester.getSize(find.byWidget(child)),
            const Size(150, 150 / cardAspectRatio),
          );
        },
      );
    },
  );
}
