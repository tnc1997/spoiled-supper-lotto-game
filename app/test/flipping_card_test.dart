import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Card;
import 'package:spoiled_supper_lotto_game/card.dart';
import 'package:spoiled_supper_lotto_game/card_back.dart';
import 'package:spoiled_supper_lotto_game/card_frame.dart';
import 'package:spoiled_supper_lotto_game/flipping_card.dart';

void main() {
  group(
    'FlippingCard',
    () {
      const sausages = engine.Card(
        id: '1',
        type: engine.CardType.standard,
        category: engine.Category.main,
        name: 'Sausages',
      );

      /// Shows sausages [progress] of the way through turning face up.
      Future<void> pumpCard(WidgetTester tester, double progress) {
        return tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: SizedBox(
                width: 120,
                child: FlippingCard(card: sausages, progress: progress),
              ),
            ),
          ),
        );
      }

      for (final progress in [0.0, 0.4]) {
        testWidgets(
          'shows the back of the card at $progress',
          (tester) async {
            await pumpCard(tester, progress);

            expect(find.byType(CardBack), findsOneWidget);
            expect(find.byType(Card), findsNothing);
          },
        );
      }

      for (final progress in [0.6, 1.0]) {
        testWidgets(
          'shows the face of the card at $progress',
          (tester) async {
            await pumpCard(tester, progress);

            expect(find.byType(CardBack), findsNothing);
            expect(tester.widget<Card>(find.byType(Card)).card, sausages);
          },
        );
      }

      testWidgets(
        'frames the card on the table',
        (tester) async {
          await pumpCard(tester, 1);

          expect(
            find.ancestor(
              of: find.byType(Card),
              matching: find.byType(CardFrame),
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        "isn't mirrored once face up",
        (tester) async {
          await pumpCard(tester, 1);

          final transform = tester
              .widget<Transform>(
                find
                    .descendant(
                      of: find.byType(FlippingCard),
                      matching: find.byType(Transform),
                    )
                    .first,
              )
              .transform;

          expect(
            MatrixUtils.transformPoint(transform, const Offset(10, 0)),
            const Offset(10, 0),
          );
        },
      );

      testWidgets(
        "doesn't announce anything",
        (tester) async {
          await pumpCard(tester, 1);

          expect(find.bySemanticsLabel(RegExp('Sausages')), findsNothing);
        },
      );
    },
  );
}
