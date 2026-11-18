import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/card_frame.dart';
import 'package:spoiled_supper_lotto_game/draw_pile.dart';
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
        'shows whose turn it is as a header',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(home: GameScreen(playerNames: ['Sam', 'Alex'])),
          );

          expect(
            tester.getSemantics(find.text("Sam's turn")),
            matchesSemantics(label: "Sam's turn", isHeader: true),
          );
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
        "shrinks the draw pile with the plate, keeping it the plate's card size",
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

          expect(tester.takeException(), isNull);
          expect(slot.width, lessThan(120));
          expect(pile.width, moreOrLessEquals(slot.width));
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
