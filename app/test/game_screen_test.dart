import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/card_frame.dart';
import 'package:spoiled_supper_lotto_game/discard_pile.dart';
import 'package:spoiled_supper_lotto_game/draw_pile.dart';
import 'package:spoiled_supper_lotto_game/drawn_card.dart';
import 'package:spoiled_supper_lotto_game/drawn_card_actions.dart';
import 'package:spoiled_supper_lotto_game/empty_slot.dart';
import 'package:spoiled_supper_lotto_game/game_notifier.dart';
import 'package:spoiled_supper_lotto_game/game_scope.dart';
import 'package:spoiled_supper_lotto_game/game_screen.dart';
import 'package:spoiled_supper_lotto_game/plate.dart';

void main() {
  group(
    'GameScreen',
    () {
      /// Returns the notifier of the game on screen.
      GameNotifier notifierOf(WidgetTester tester) {
        return tester.widget<GameScope>(find.byType(GameScope)).notifier!;
      }

      testWidgets(
        'starts a game between the players named, in turn order',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: GameScreen(playerNames: ['Sam', 'Alex', 'Player 3']),
            ),
          );

          expect(
            notifierOf(tester).game.players.map((player) => player.name),
            ['Sam', 'Alex', 'Player 3'],
          );
        },
      );

      testWidgets(
        'starts the game with the first player',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(home: GameScreen(playerNames: ['Sam', 'Alex'])),
          );

          expect(notifierOf(tester).game.currentPlayerIndex, 0);
        },
      );

      testWidgets(
        'shuffles the deck with the random given',
        (tester) async {
          Future<List<String>> drawPileWith(int seed) async {
            await tester.pumpWidget(
              MaterialApp(
                home: GameScreen(
                  key: UniqueKey(),
                  playerNames: const ['Sam', 'Alex'],
                  random: Random(seed),
                ),
              ),
            );

            return [
              for (final card in notifierOf(tester).game.drawPile) card.id,
            ];
          }

          final first = await drawPileWith(1);

          expect(await drawPileWith(1), first);
          expect(await drawPileWith(2), isNot(first));
        },
      );

      testWidgets(
        'announces whose turn it is as a header in a live region',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(home: GameScreen(playerNames: ['Sam', 'Alex'])),
          );

          expect(
            tester.getSemantics(find.text("Sam's turn")),
            matchesSemantics(
              label: "Sam's turn",
              isHeader: true,
              isLiveRegion: true,
            ),
          );
        },
      );

      testWidgets(
        'shows whose turn it is in the headlineSmall text style',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(
                textTheme: const TextTheme(
                  headlineSmall: TextStyle(fontFamily: 'Fredoka'),
                ),
              ),
              home: const GameScreen(playerNames: ['Sam', 'Alex']),
            ),
          );

          final text = tester.widget<Text>(find.text("Sam's turn"));

          expect(text.style?.fontFamily, 'Fredoka');
        },
      );

      testWidgets(
        "shows the current player's plate",
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(home: GameScreen(playerNames: ['Sam', 'Alex'])),
          );
          final game = notifierOf(tester).game;

          expect(
            tester.widget<Plate>(find.byType(Plate)).player,
            same(game.players[0]),
          );

          notifierOf(tester)
            ..drawFromDrawPile()
            ..placeDrawnCard();
          await tester.pump();

          expect(find.text("Alex's turn"), findsOneWidget);
          expect(
            tester.widget<Plate>(find.byType(Plate)).player,
            same(game.players[1]),
          );
        },
      );

      testWidgets(
        'shows the draw pile',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(home: GameScreen(playerNames: ['Sam', 'Alex'])),
          );

          final count = notifierOf(tester).game.drawPile.length;

          expect(find.byType(DrawPile), findsOneWidget);
          expect(find.text('$count cards'), findsOneWidget);
        },
      );

      testWidgets(
        'shows the drawn card and its actions',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(home: GameScreen(playerNames: ['Sam', 'Alex'])),
          );

          expect(find.byType(DrawnCard), findsOneWidget);
          expect(find.byType(DrawnCardActions), findsOneWidget);
        },
      );

      testWidgets(
        'shows the discard pile, empty at the start of the game',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(home: GameScreen(playerNames: ['Sam', 'Alex'])),
          );

          expect(find.byType(DiscardPile), findsOneWidget);
          expect(
            find.descendant(
              of: find.byType(DiscardPile),
              matching: find.text('0 cards'),
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'lines up the drawn card with the draw and discard piles',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(home: GameScreen(playerNames: ['Sam', 'Alex'])),
          );

          notifierOf(tester).drawFromDrawPile();
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
        'fits the plate on a narrow screen',
        (tester) async {
          tester.view
            ..physicalSize = const Size(360, 740)
            ..devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            const MaterialApp(home: GameScreen(playerNames: ['Sam', 'Alex'])),
          );

          expect(tester.takeException(), isNull);
          expect(
            tester.getRect(find.byType(Plate)).width,
            lessThanOrEqualTo(360 - 2 * 24),
          );
        },
      );

      testWidgets(
        "keeps the drawn card's actions full size on a narrow screen",
        (tester) async {
          tester.view
            ..physicalSize = const Size(360, 740)
            ..devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            const MaterialApp(home: GameScreen(playerNames: ['Sam', 'Alex'])),
          );

          // Measures the actions, which keep their space while hidden.
          for (final button in [FilledButton, OutlinedButton]) {
            expect(
              tester.getSize(find.byType(button)).height,
              greaterThanOrEqualTo(kMinInteractiveDimension),
            );
          }
        },
      );

      testWidgets(
        "shrinks the piles with the plate, keeping them the plate's card size",
        (tester) async {
          tester.view
            ..physicalSize = const Size(360, 740)
            ..devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            const MaterialApp(home: GameScreen(playerNames: ['Sam', 'Alex'])),
          );

          // Measures them on screen, after the plate has been shrunk.
          final pile = tester.getRect(
            find.descendant(
              of: find.byType(DrawPile),
              matching: find.byType(CardFrame),
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

          final discardPile = tester.getRect(
            find.descendant(
              of: find.byType(DiscardPile),
              matching: find.byType(EmptySlot),
            ),
          );

          expect(tester.takeException(), isNull);
          expect(slot.width, lessThan(120));
          expect(pile.width, moreOrLessEquals(slot.width));
          expect(discardPile.width, moreOrLessEquals(slot.width));
        },
      );

      testWidgets(
        'places the drawn card on the plate shown',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(home: GameScreen(playerNames: ['Sam', 'Alex'])),
          );

          expect(
            tester.widget<DrawnCard>(find.byType(DrawnCard)).plateKey,
            tester.widget<Plate>(find.byType(Plate)).key,
          );
        },
      );

      testWidgets(
        'disposes of the game when removed',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(home: GameScreen(playerNames: ['Sam', 'Alex'])),
          );
          final notifier = notifierOf(tester);
          await tester.pumpWidget(const SizedBox());

          expect(notifier.drawFromDrawPile, throwsStateError);
        },
      );
    },
  );
}
