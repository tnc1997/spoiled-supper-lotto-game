import 'dart:math';

import 'package:game_engine/game_engine.dart';
import 'package:test/test.dart';

void main() {
  group(
    'GameController',
    () {
      const sausages = Card(
        id: '1',
        type: CardType.standard,
        category: Category.main,
        name: 'Sausages',
      );
      const milk = Card(
        id: '2',
        type: CardType.standard,
        category: Category.drink,
        name: 'Milk',
      );

      late Player alice;
      late Player bob;

      setUp(
        () {
          alice = Player(name: 'Alice');
          bob = Player(name: 'Bob');
        },
      );

      test(
        'holds the players in turn order',
        () {
          final controller = GameController(players: [alice, bob]);

          expect(controller.players, [alice, bob]);
        },
      );

      test(
        'starts with the first player taking the first turn',
        () {
          final controller = GameController(players: [alice, bob]);

          expect(controller.currentPlayerIndex, 0);
          expect(controller.currentPlayer, alice);
        },
      );

      test(
        'defaults the draw pile to the full deck',
        () {
          final controller = GameController(players: [alice, bob]);

          expect(controller.drawPile, unorderedEquals(buildDeck()));
        },
      );

      test(
        'shuffles the default draw pile with the given random',
        () {
          final first = GameController(
            players: [alice, bob],
            random: Random(42),
          );
          final second = GameController(
            players: [alice, bob],
            random: Random(42),
          );

          expect(first.drawPile, second.drawPile);
          expect(first.drawPile, isNot(buildDeck()));
        },
      );

      test(
        'defaults to an empty discard pile',
        () {
          final controller = GameController(players: [alice, bob]);

          expect(controller.discardPile, isEmpty);
        },
      );

      test(
        'can be given specific draw and discard piles',
        () {
          final controller = GameController(
            players: [alice, bob],
            drawPile: [sausages],
            discardPile: [milk],
          );

          expect(controller.drawPile, [sausages]);
          expect(controller.discardPile, [milk]);
        },
      );

      test(
        'is not affected by later changes to the lists it was given',
        () {
          final players = [alice, bob];
          final drawPile = [sausages];
          final discardPile = [milk];

          final controller = GameController(
            players: players,
            drawPile: drawPile,
            discardPile: discardPile,
          );
          players.clear();
          drawPile.clear();
          discardPile.clear();

          expect(controller.players, [alice, bob]);
          expect(controller.drawPile, [sausages]);
          expect(controller.discardPile, [milk]);
        },
      );

      test(
        'does not allow its state to be modified from outside',
        () {
          final controller = GameController(
            players: [alice, bob],
            drawPile: [sausages],
            discardPile: [milk],
          );

          expect(() => controller.players.add(alice), throwsUnsupportedError);
          expect(() => controller.drawPile.clear(), throwsUnsupportedError);
          expect(() => controller.discardPile.clear(), throwsUnsupportedError);
        },
      );

      test(
        'accepts between 2 and 4 players',
        () {
          for (var count = 2; count <= 4; count++) {
            final players = [
              for (var i = 0; i < count; i++) Player(name: 'Player $i'),
            ];

            expect(
              GameController(players: players).players,
              hasLength(count),
            );
          }
        },
      );

      test(
        'throws if there are fewer than 2 players',
        () {
          expect(
            () => GameController(players: [alice]),
            throwsArgumentError,
          );
        },
      );

      test(
        'throws if there are more than 4 players',
        () {
          expect(
            () => GameController(
              players: [
                for (var i = 0; i < 5; i++) Player(name: 'Player $i'),
              ],
            ),
            throwsArgumentError,
          );
        },
      );
    },
  );
}
