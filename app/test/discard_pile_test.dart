import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Card;
import 'package:spoiled_supper_lotto_game/card.dart';
import 'package:spoiled_supper_lotto_game/card_aspect_ratio.dart';
import 'package:spoiled_supper_lotto_game/card_frame.dart';
import 'package:spoiled_supper_lotto_game/discard_pile.dart';
import 'package:spoiled_supper_lotto_game/game_notifier.dart';
import 'package:spoiled_supper_lotto_game/game_scope.dart';

void main() {
  group(
    'DiscardPile',
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

      /// Returns a notifier for a game between two players with
      /// [discardPile] and [drawPile], disposed of after the test.
      GameNotifier notifierWith({
        required List<engine.Card> discardPile,
        List<engine.Card> drawPile = const [],
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

      /// Shows the discard pile of the game of [notifier].
      Future<void> pumpPile(WidgetTester tester, GameNotifier notifier) {
        return tester.pumpWidget(
          MaterialApp(
            home: GameScope(
              notifier: notifier,
              child: const Center(child: DiscardPile()),
            ),
          ),
        );
      }

      /// Returns the card shown on top of the pile.
      engine.Card topCard(WidgetTester tester) {
        return tester.widget<Card>(find.byType(Card)).card;
      }

      testWidgets(
        'shows how many cards are in it',
        (tester) async {
          await pumpPile(
            tester,
            notifierWith(discardPile: [sausages, pondWater]),
          );

          expect(find.text('2 cards'), findsOneWidget);
        },
      );

      testWidgets(
        'shows a single card in the singular',
        (tester) async {
          await pumpPile(tester, notifierWith(discardPile: [sausages]));

          expect(find.text('1 card'), findsOneWidget);
        },
      );

      testWidgets(
        'shows its top card face up, framed on the table',
        (tester) async {
          await pumpPile(
            tester,
            notifierWith(discardPile: [pondWater, sausages]),
          );

          expect(
            find.descendant(
              of: find.byType(CardFrame),
              matching: find.byType(Card),
            ),
            findsOneWidget,
          );
          expect(topCard(tester), same(sausages));
          expect(find.text('Empty'), findsNothing);
        },
      );

      testWidgets(
        'takes the top card when tapped',
        (tester) async {
          final notifier = notifierWith(discardPile: [pondWater, sausages]);
          await pumpPile(tester, notifier);

          await tester.tap(find.byType(DiscardPile));
          await tester.pump();

          expect(notifier.game.drawnCard, same(sausages));
          expect(topCard(tester), same(pondWater));
          expect(find.text('1 card'), findsOneWidget);
        },
      );

      testWidgets(
        'does nothing when tapped once a card has been drawn',
        (tester) async {
          final notifier = notifierWith(
            discardPile: [sausages],
            drawPile: [pondWater],
          );
          await pumpPile(tester, notifier);
          notifier.drawFromDrawPile();
          await tester.pump();

          await tester.tap(find.byType(DiscardPile));
          await tester.pump();

          expect(notifier.game.drawnCard, same(pondWater));
          expect(notifier.game.discardPile, [sausages]);
        },
      );

      testWidgets(
        'shows that it is empty',
        (tester) async {
          await pumpPile(
            tester,
            notifierWith(discardPile: [], drawPile: [sausages]),
          );

          expect(find.text('Empty'), findsOneWidget);
          expect(find.text('0 cards'), findsOneWidget);
          expect(find.byType(CardFrame), findsNothing);
        },
      );

      testWidgets(
        'does nothing when tapped while empty',
        (tester) async {
          final notifier = notifierWith(
            discardPile: [],
            drawPile: [sausages],
          );
          await pumpPile(tester, notifier);

          await tester.tap(find.byType(DiscardPile));
          await tester.pump();

          expect(notifier.game.drawnCard, isNull);
          expect(notifier.game.drawPile, [sausages]);
        },
      );

      testWidgets(
        'is announced as a button with its top card and how many cards are '
        'in it',
        (tester) async {
          final notifier = notifierWith(discardPile: [pondWater, sausages]);
          await pumpPile(tester, notifier);

          expect(
            tester.getSemantics(find.byType(DiscardPile)),
            matchesSemantics(
              label: 'Discard pile\nSausages, Main\n2 cards',
              isButton: true,
              hasEnabledState: true,
              isEnabled: true,
              isFocusable: true,
              hasTapAction: true,
              hasFocusAction: true,
            ),
          );

          notifier.drawFromDiscardPile();
          // Lets the focus state settle, which follows a frame later.
          await tester.pumpAndSettle();

          expect(
            tester.getSemantics(find.byType(DiscardPile)),
            matchesSemantics(
              label: 'Discard pile\nPond Water, Drink, Spoiled\n1 card',
              isButton: true,
              hasEnabledState: true,
            ),
          );
        },
      );

      testWidgets(
        'is announced as a disabled button while empty',
        (tester) async {
          await pumpPile(
            tester,
            notifierWith(discardPile: [], drawPile: [sausages]),
          );

          expect(
            tester.getSemantics(find.byType(DiscardPile)),
            matchesSemantics(
              label: 'Discard pile\n0 cards',
              isButton: true,
              hasEnabledState: true,
            ),
          );
        },
      );

      testWidgets(
        'tells a screen reader when it has keyboard focus',
        (tester) async {
          await pumpPile(tester, notifierWith(discardPile: [sausages]));

          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();

          expect(
            tester.getSemantics(find.byType(DiscardPile)),
            isSemantics(
              label: 'Discard pile\nSausages, Main\n1 card',
              isButton: true,
              isFocusable: true,
              isFocused: true,
            ),
          );
        },
      );

      testWidgets(
        'takes the top card when activated with the keyboard',
        (tester) async {
          final notifier = notifierWith(discardPile: [sausages]);
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
                notifier: notifierWith(discardPile: [sausages]),
                child: const Center(child: DiscardPile(cardWidth: 80)),
              ),
            ),
          );

          final size = tester.getSize(
            find
                .descendant(
                  of: find.byType(DiscardPile),
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
