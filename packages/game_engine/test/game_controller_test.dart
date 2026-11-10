import 'dart:math';

import 'package:game_engine/game_engine.dart';
import 'package:test/test.dart';

void main() {
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

  List<Player> playersOf(int count) => [
        for (var i = 0; i < count; i++) Player(name: 'Player $i'),
      ];

  group(
    'GameController',
    () {
      test(
        'holds the players in turn order',
        () {
          final controller = GameController(
            players: [alice, bob],
            drawPile: [sausages],
          );

          expect(controller.players, [alice, bob]);
        },
      );

      test(
        'starts with the first player taking the first turn',
        () {
          final controller = GameController(
            players: [alice, bob],
            drawPile: [sausages],
          );

          expect(controller.currentPlayerIndex, 0);
          expect(controller.currentPlayer, alice);
        },
      );

      test(
        'holds the given draw and discard piles as-is',
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
        'defaults to an empty discard pile',
        () {
          final controller = GameController(
            players: [alice, bob],
            drawPile: [sausages],
          );

          expect(controller.discardPile, isEmpty);
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
    },
  );

  group(
    'GameController.start',
    () {
      test(
        'holds the players in turn order',
        () {
          final controller = GameController.start([alice, bob]);

          expect(controller.players, [alice, bob]);
        },
      );

      test(
        'starts with the first player taking the first turn',
        () {
          final controller = GameController.start([alice, bob]);

          expect(controller.currentPlayer, alice);
        },
      );

      test(
        'puts the full deck into the draw pile',
        () {
          final controller = GameController.start([alice, bob]);

          expect(controller.drawPile, unorderedEquals(buildDeck()));
        },
      );

      test(
        'shuffles the draw pile with the given random',
        () {
          final first = GameController.start([alice, bob], random: Random(42));
          final second = GameController.start([alice, bob], random: Random(42));

          expect(first.drawPile, second.drawPile);
          expect(first.drawPile, isNot(buildDeck()));
        },
      );

      test(
        'starts with an empty discard pile',
        () {
          final controller = GameController.start([alice, bob]);

          expect(controller.discardPile, isEmpty);
        },
      );

      test(
        'accepts between minPlayers and maxPlayers players',
        () {
          for (var count = GameController.minPlayers;
              count <= GameController.maxPlayers;
              count++) {
            expect(
              GameController.start(playersOf(count)).players,
              hasLength(count),
            );
          }
        },
      );

      test(
        'throws if there are fewer than minPlayers players',
        () {
          expect(
            () => GameController.start(
              playersOf(GameController.minPlayers - 1),
            ),
            throwsArgumentError,
          );
        },
      );

      test(
        'throws if there are more than maxPlayers players',
        () {
          expect(
            () => GameController.start(
              playersOf(GameController.maxPlayers + 1),
            ),
            throwsArgumentError,
          );
        },
      );
    },
  );
}
