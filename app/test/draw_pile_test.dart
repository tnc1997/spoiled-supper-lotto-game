import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/card_aspect_ratio.dart';
import 'package:spoiled_supper_lotto_game/draw_pile.dart';
import 'package:spoiled_supper_lotto_game/game_notifier.dart';
import 'package:spoiled_supper_lotto_game/game_scope.dart';

void main() {
  group(
    'DrawPile',
    () {
      const sausages = engine.Card(
        id: '1',
        type: engine.CardType.standard,
        category: engine.Category.main,
        name: 'Sausages',
      );
      const pondWater = engine.Card(
        id: '2',
        type: engine.CardType.spoiled,
        category: engine.Category.drink,
        name: 'Pond Water',
      );

      /// Returns a notifier for a game between two players with [drawPile]
      /// and [discardPile], disposed of after the test.
      GameNotifier notifierWith({
        required List<engine.Card> drawPile,
        List<engine.Card> discardPile = const [],
      }) {
        final notifier = GameNotifier(
          engine.GameController(
            players: [
              engine.Player(name: 'Alice'),
              engine.Player(name: 'Bob'),
            ],
            drawPile: drawPile,
            discardPile: discardPile,
          ),
        );
        addTearDown(notifier.dispose);

        return notifier;
      }

      /// Shows the draw pile of the game of [notifier].
      Future<void> pumpPile(WidgetTester tester, GameNotifier notifier) {
        return tester.pumpWidget(
          MaterialApp(
            home: GameScope(
              notifier: notifier,
              child: const Center(child: DrawPile()),
            ),
          ),
        );
      }

      testWidgets(
        'shows how many cards are left',
        (tester) async {
          await pumpPile(
            tester,
            notifierWith(drawPile: [sausages, pondWater]),
          );

          expect(find.text('2 cards'), findsOneWidget);
        },
      );

      testWidgets(
        'shows a single card left in the singular',
        (tester) async {
          await pumpPile(tester, notifierWith(drawPile: [sausages]));

          expect(find.text('1 card'), findsOneWidget);
        },
      );

      testWidgets(
        'keeps the cards face down',
        (tester) async {
          await pumpPile(tester, notifierWith(drawPile: [sausages]));

          expect(find.textContaining('Sausages'), findsNothing);
          expect(find.text('Empty'), findsNothing);
        },
      );

      testWidgets(
        'draws the top card when tapped',
        (tester) async {
          final notifier = notifierWith(drawPile: [pondWater, sausages]);
          await pumpPile(tester, notifier);

          await tester.tap(find.byType(DrawPile));
          await tester.pump();

          expect(notifier.game.drawnCard, same(sausages));
          expect(find.text('1 card'), findsOneWidget);
        },
      );

      testWidgets(
        'does nothing when tapped once a card has been drawn',
        (tester) async {
          final notifier = notifierWith(drawPile: [pondWater, sausages]);
          await pumpPile(tester, notifier);
          notifier.drawFromDrawPile();
          await tester.pump();

          await tester.tap(find.byType(DrawPile));
          await tester.pump();

          expect(notifier.game.drawnCard, same(sausages));
          expect(notifier.game.drawPile, [pondWater]);
        },
      );

      testWidgets(
        'shows that it is empty',
        (tester) async {
          await pumpPile(
            tester,
            notifierWith(drawPile: [], discardPile: [sausages]),
          );

          expect(find.text('Empty'), findsOneWidget);
          expect(find.text('0 cards'), findsOneWidget);
        },
      );

      testWidgets(
        'refills from the discard pile when tapped while empty',
        (tester) async {
          final notifier = notifierWith(drawPile: [], discardPile: [sausages]);
          await pumpPile(tester, notifier);

          await tester.tap(find.byType(DrawPile));
          await tester.pump();

          expect(notifier.game.drawnCard, same(sausages));
        },
      );

      testWidgets(
        'is announced as a button with how many cards are left',
        (tester) async {
          final notifier = notifierWith(drawPile: [pondWater, sausages]);
          await pumpPile(tester, notifier);

          expect(
            tester.getSemantics(find.byType(DrawPile)),
            matchesSemantics(
              label: 'Draw pile, 2 cards',
              isButton: true,
              hasEnabledState: true,
              isEnabled: true,
              isFocusable: true,
              hasTapAction: true,
              hasFocusAction: true,
            ),
          );

          notifier.drawFromDrawPile();
          // Lets the focus state settle, which follows a frame later.
          await tester.pumpAndSettle();

          expect(
            tester.getSemantics(find.byType(DrawPile)),
            matchesSemantics(
              label: 'Draw pile, 1 card',
              isButton: true,
              hasEnabledState: true,
            ),
          );
        },
      );

      testWidgets(
        'tells a screen reader when it has keyboard focus',
        (tester) async {
          await pumpPile(tester, notifierWith(drawPile: [sausages]));

          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();

          expect(
            tester.getSemantics(find.byType(DrawPile)),
            isSemantics(
              label: 'Draw pile, 1 card',
              isButton: true,
              isFocusable: true,
              isFocused: true,
            ),
          );
        },
      );

      testWidgets(
        'draws only once when tapped twice before it rebuilds',
        (tester) async {
          final notifier = notifierWith(drawPile: [pondWater, sausages]);
          await pumpPile(tester, notifier);

          final onTap = tester.widget<InkWell>(find.byType(InkWell)).onTap!;
          onTap();
          onTap();

          expect(notifier.game.drawnCard, same(sausages));
          expect(notifier.game.drawPile, [pondWater]);
        },
      );

      testWidgets(
        'draws the top card when activated with the keyboard',
        (tester) async {
          final notifier = notifierWith(drawPile: [sausages]);
          await pumpPile(tester, notifier);

          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pump();

          expect(notifier.game.drawnCard, same(sausages));
        },
      );

      testWidgets(
        'is card-shaped and as wide as the card width given',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: GameScope(
                notifier: notifierWith(drawPile: [sausages]),
                child: const Center(child: DrawPile(cardWidth: 80)),
              ),
            ),
          );

          final size = tester.getSize(
            find
                .descendant(
                  of: find.byType(DrawPile),
                  matching: find.byType(AspectRatio),
                )
                .first,
          );

          expect(size.width, 80);
          expect(size.height, 80 / cardAspectRatio);
        },
      );
    },
  );
}
