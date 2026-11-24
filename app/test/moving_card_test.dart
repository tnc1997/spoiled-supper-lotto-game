import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/card_aspect_ratio.dart';
import 'package:spoiled_supper_lotto_game/game_notifier.dart';
import 'package:spoiled_supper_lotto_game/game_scope.dart';
import 'package:spoiled_supper_lotto_game/moving_card.dart';
import 'package:spoiled_supper_lotto_game/plate.dart';

void main() {
  group(
    'MovingCard',
    () {
      const duration = Duration(milliseconds: 400);
      const cardKey = Key('card');

      late engine.Player alice;
      late GameNotifier notifier;
      late int ends;

      setUp(
        () {
          alice = engine.Player(name: 'Alice');
          notifier = GameNotifier(
            engine.GameController(
              players: [alice, engine.Player(name: 'Bob')],
              drawPile: const [],
            ),
          );
          addTearDown(notifier.dispose);
          ends = 0;
        },
      );

      /// Shows a card going to the main slot on Alice's plate, shown above
      /// it unless [showsPlate] is `false`.
      Future<void> pumpMovingCard(
        WidgetTester tester, {
        bool showsPlate = true,
        bool disableAnimations = false,
      }) {
        final plateKey = GlobalKey();

        return tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: disableAnimations),
              child: GameScope(
                notifier: notifier,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 24,
                  children: [
                    // Fits both on the test's screen.
                    if (showsPlate)
                      Plate(key: plateKey, player: alice, cardWidth: 60),
                    MovingCard(
                      targetKey: plateKey,
                      targetOffset: Plate(player: alice, cardWidth: 60)
                          .slotOffsetOf(engine.Category.main),
                      duration: duration,
                      onEnd: () => ends++,
                      child: const SizedBox(
                        key: cardKey,
                        width: 60,
                        height: 60 / cardAspectRatio,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      /// Returns where the main slot is on screen.
      Rect mainSlotRect(WidgetTester tester) {
        return tester.getRect(find.bySemanticsLabel('Main, empty'));
      }

      testWidgets(
        'takes the card to its target over the duration, then calls onEnd',
        (tester) async {
          await pumpMovingCard(tester);

          final start = tester.getRect(find.byKey(cardKey));
          final slot = mainSlotRect(tester);

          await tester.pump(duration ~/ 2);

          final halfway = tester.getRect(find.byKey(cardKey));
          expect(halfway.top, lessThan(start.top));
          expect(halfway.top, greaterThan(slot.top));

          await tester.pump(duration ~/ 2 - const Duration(milliseconds: 1));

          expect(
            tester.getRect(find.byKey(cardKey)),
            rectMoreOrLessEquals(slot, epsilon: 1),
          );
          expect(ends, 0);

          await tester.pump(const Duration(milliseconds: 2));

          expect(
              tester.getRect(find.byKey(cardKey)), rectMoreOrLessEquals(slot));
          expect(ends, 1);
        },
      );

      testWidgets(
        'shows the card at its target straight away, then calls onEnd after '
        'the duration, if animations are disabled',
        (tester) async {
          await pumpMovingCard(tester, disableAnimations: true);
          // Finds the slot once the card has been laid out.
          await tester.pump();

          expect(
            tester.getRect(find.byKey(cardKey)),
            rectMoreOrLessEquals(mainSlotRect(tester)),
          );

          await tester.pump(duration);
          await tester.pump(const Duration(milliseconds: 1));

          expect(ends, 1);
        },
      );

      testWidgets(
        'leaves the card where it is, then calls onEnd, if the target is '
        'not shown',
        (tester) async {
          await pumpMovingCard(tester, showsPlate: false);

          final start = tester.getRect(find.byKey(cardKey));

          await tester.pump(duration);
          await tester.pump(const Duration(milliseconds: 1));

          expect(tester.getRect(find.byKey(cardKey)), start);
          expect(ends, 1);
        },
      );
    },
  );
}
