import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Table;
import 'package:spoiled_supper_lotto_game/card_frame.dart';
import 'package:spoiled_supper_lotto_game/discard_pile.dart';
import 'package:spoiled_supper_lotto_game/draw_pile.dart';
import 'package:spoiled_supper_lotto_game/drawn_card.dart';
import 'package:spoiled_supper_lotto_game/empty_slot.dart';
import 'package:spoiled_supper_lotto_game/game_notifier.dart';
import 'package:spoiled_supper_lotto_game/game_scope.dart';
import 'package:spoiled_supper_lotto_game/plate.dart';
import 'package:spoiled_supper_lotto_game/table.dart';

void main() {
  group(
    'Table',
    () {
      late GameNotifier notifier;
      late GlobalKey plateKey;
      late GlobalKey discardPileKey;

      setUp(() {
        notifier = GameNotifier(
          engine.GameController.start([
            engine.Player(name: 'Sam'),
            engine.Player(name: 'Alex'),
          ]),
        );
        plateKey = GlobalKey();
        discardPileKey = GlobalKey();
      });

      tearDown(() => notifier.dispose());

      /// Shows the table of the game of [notifier], with the current
      /// player's plate.
      Future<void> pumpTable(WidgetTester tester) {
        return tester.pumpWidget(
          MaterialApp(
            home: GameScope(
              notifier: notifier,
              child: Center(
                child: FittedBox(
                  child: Table(
                    player: notifier.game.currentPlayer,
                    plateKey: plateKey,
                    discardPileKey: discardPileKey,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      testWidgets(
        "shows the player's plate with the plate key",
        (tester) async {
          await pumpTable(tester);

          final plate = tester.widget<Plate>(find.byType(Plate));

          expect(plate.player, same(notifier.game.currentPlayer));
          expect(plate.key, plateKey);
        },
      );

      testWidgets(
        'shows the draw pile, the discard pile and the drawn card',
        (tester) async {
          await pumpTable(tester);

          expect(find.byType(DrawPile), findsOneWidget);
          expect(find.byType(DiscardPile), findsOneWidget);
          expect(find.byType(DrawnCard), findsOneWidget);
        },
      );

      testWidgets(
        'places the drawn card on the plate shown',
        (tester) async {
          await pumpTable(tester);

          expect(
            tester.widget<DrawnCard>(find.byType(DrawnCard)).plateKey,
            plateKey,
          );
        },
      );

      testWidgets(
        'discards the drawn card to the discard pile shown',
        (tester) async {
          await pumpTable(tester);

          expect(
            tester.widget<DiscardPile>(find.byType(DiscardPile)).cardKey,
            discardPileKey,
          );
          expect(
            tester.widget<DrawnCard>(find.byType(DrawnCard)).discardPileKey,
            discardPileKey,
          );
        },
      );

      testWidgets(
        'lines up the drawn card with the draw and discard piles',
        (tester) async {
          await pumpTable(tester);

          notifier.drawFromDrawPile();
          await tester.pump();

          final drawPile = tester.getRect(
            find.descendant(
              of: find.byType(DrawPile),
              matching: find.byType(CardFrame),
            ),
          );
          final discardPile = tester.getRect(
            find.descendant(
              of: find.byType(DiscardPile),
              matching: find.byType(EmptySlot),
            ),
          );
          final drawnCard = tester.getRect(find.byType(DrawnCard));

          expect(drawnCard.top, moreOrLessEquals(drawPile.top));
          expect(drawnCard.top, moreOrLessEquals(discardPile.top));
        },
      );

      testWidgets(
        "keeps the piles the plate's card size",
        (tester) async {
          await pumpTable(tester);

          final drawPile = tester.getRect(
            find.descendant(
              of: find.byType(DrawPile),
              matching: find.byType(CardFrame),
            ),
          );
          final discardPile = tester.getRect(
            find.descendant(
              of: find.byType(DiscardPile),
              matching: find.byType(EmptySlot),
            ),
          );
          final slot = tester.getRect(
            find
                .descendant(
                  of: find.byType(Plate),
                  matching: find.byType(EmptySlot),
                )
                .first,
          );

          expect(tester.takeException(), isNull);
          expect(drawPile.width, moreOrLessEquals(slot.width));
          expect(discardPile.width, moreOrLessEquals(slot.width));
        },
      );
    },
  );
}
