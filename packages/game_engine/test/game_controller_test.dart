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
      const fishFingers = Card(
        id: '3',
        type: CardType.standard,
        category: Category.main,
        name: 'Fish Fingers',
      );
      const fishBone = Card(
        id: '4',
        type: CardType.spoiled,
        category: Category.main,
        name: 'Fish Bone',
      );
      const leatherBoot = Card(
        id: '5',
        type: CardType.spoiled,
        category: Category.main,
        name: 'Leather Boot',
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
        'defaults to no drawn card',
        () {
          final controller = GameController(
            players: [alice, bob],
            drawPile: [sausages],
          );

          expect(controller.drawnCard, isNull);
        },
      );

      test(
        'holds the given drawn card as-is',
        () {
          final controller = GameController(
            players: [alice, bob],
            drawPile: [sausages],
            drawnCard: milk,
          );

          expect(controller.drawnCard, milk);
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

      group(
        'start',
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
              final first =
                  GameController.start([alice, bob], random: Random(42));
              final second =
                  GameController.start([alice, bob], random: Random(42));

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
            'starts with no drawn card',
            () {
              final controller = GameController.start([alice, bob]);

              expect(controller.drawnCard, isNull);
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

      group(
        'drawFromDrawPile',
        () {
          test(
            'holds the top card of the draw pile as the drawn card',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [milk, sausages],
              );

              controller.drawFromDrawPile();

              expect(controller.drawnCard, sausages);
            },
          );

          test(
            'removes the drawn card from the draw pile',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [milk, sausages],
              );

              controller.drawFromDrawPile();

              expect(controller.drawPile, [milk]);
            },
          );

          test(
            'can draw the last card of the draw pile',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
              );

              controller.drawFromDrawPile();

              expect(controller.drawnCard, sausages);
              expect(controller.drawPile, isEmpty);
            },
          );

          test(
            'does not change the discard pile or the current player',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
                discardPile: [milk],
              );

              controller.drawFromDrawPile();

              expect(controller.discardPile, [milk]);
              expect(controller.currentPlayer, alice);
            },
          );

          test(
            'throws if a drawn card has not yet been played',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
                drawnCard: milk,
              );

              expect(controller.drawFromDrawPile, throwsStateError);
              expect(controller.drawnCard, milk);
              expect(controller.drawPile, [sausages]);
            },
          );

          test(
            'throws if the draw pile is empty',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
              );

              expect(controller.drawFromDrawPile, throwsStateError);
              expect(controller.drawnCard, isNull);
            },
          );
        },
      );

      group(
        'drawFromDiscardPile',
        () {
          test(
            'holds the top card of the discard pile as the drawn card',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [milk, sausages],
              );

              controller.drawFromDiscardPile();

              expect(controller.drawnCard, sausages);
            },
          );

          test(
            'removes the drawn card from the discard pile',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [milk, sausages],
              );

              controller.drawFromDiscardPile();

              expect(controller.discardPile, [milk]);
            },
          );

          test(
            'can draw the last card of the discard pile',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [sausages],
              );

              controller.drawFromDiscardPile();

              expect(controller.drawnCard, sausages);
              expect(controller.discardPile, isEmpty);
            },
          );

          test(
            'does not change the draw pile or the current player',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [milk],
                discardPile: [sausages],
              );

              controller.drawFromDiscardPile();

              expect(controller.drawPile, [milk]);
              expect(controller.currentPlayer, alice);
            },
          );

          test(
            'throws if a drawn card has not yet been played',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [sausages],
                drawnCard: milk,
              );

              expect(controller.drawFromDiscardPile, throwsStateError);
              expect(controller.drawnCard, milk);
              expect(controller.discardPile, [sausages]);
            },
          );

          test(
            'throws if the discard pile is empty',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
              );

              expect(controller.drawFromDiscardPile, throwsStateError);
              expect(controller.drawnCard, isNull);
              expect(controller.drawPile, [sausages]);
            },
          );
        },
      );

      group(
        'placeDrawnCard',
        () {
          test(
            'places the drawn card on the plate if its slot is empty',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(alice.plate[Category.main], sausages);
              expect(controller.discardPile, isEmpty);
              expect(controller.drawnCard, isNull);
            },
          );

          test(
            'replaces the card in a filled slot and discards it',
            () {
              alice.plate.place(fishFingers);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [milk],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(alice.plate[Category.main], sausages);
              expect(controller.discardPile, [milk, fishFingers]);
              expect(controller.drawnCard, isNull);
            },
          );

          test(
            "only uses the current player's plate",
            () {
              bob.plate.place(fishFingers);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(alice.plate[Category.main], sausages);
              expect(bob.plate[Category.main], fishFingers);
              expect(controller.discardPile, isEmpty);
            },
          );

          test(
            'does not change the draw pile or the current player',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [milk],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(controller.drawPile, [milk]);
              expect(controller.currentPlayer, alice);
            },
          );

          test(
            'places a spoiled card on the plate if its slot is empty',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                drawnCard: fishBone,
              );

              controller.placeDrawnCard();

              expect(alice.plate[Category.main], fishBone);
              expect(controller.discardPile, isEmpty);
              expect(controller.drawnCard, isNull);
            },
          );

          test(
            'replaces a spoiled card on the plate and discards it',
            () {
              alice.plate.place(fishBone);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(alice.plate[Category.main], sausages);
              expect(controller.discardPile, [fishBone]);
              expect(controller.drawnCard, isNull);
            },
          );

          test(
            'throws for a spoiled card if its slot has a food card',
            () {
              alice.plate.place(fishFingers);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                drawnCard: fishBone,
              );

              expect(controller.placeDrawnCard, throwsStateError);
              expect(controller.drawnCard, fishBone);
              expect(alice.plate[Category.main], fishFingers);
              expect(controller.discardPile, isEmpty);
            },
          );

          test(
            'throws for a spoiled card if its slot has a spoiled card',
            () {
              alice.plate.place(leatherBoot);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                drawnCard: fishBone,
              );

              expect(controller.placeDrawnCard, throwsStateError);
              expect(controller.drawnCard, fishBone);
              expect(alice.plate[Category.main], leatherBoot);
              expect(controller.discardPile, isEmpty);
            },
          );

          test(
            'throws if no card has been drawn',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
              );

              expect(controller.placeDrawnCard, throwsStateError);
              expect(alice.plate[Category.main], isNull);
              expect(controller.discardPile, isEmpty);
            },
          );
        },
      );

      group(
        'discardDrawnCard',
        () {
          test(
            'discards the drawn card and keeps the card in a filled slot',
            () {
              alice.plate.place(fishFingers);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [milk],
                drawnCard: sausages,
              );

              controller.discardDrawnCard();

              expect(alice.plate[Category.main], fishFingers);
              expect(controller.discardPile, [milk, sausages]);
              expect(controller.drawnCard, isNull);
            },
          );

          test(
            'does not change the draw pile or the current player',
            () {
              alice.plate.place(fishFingers);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [milk],
                drawnCard: sausages,
              );

              controller.discardDrawnCard();

              expect(controller.drawPile, [milk]);
              expect(controller.currentPlayer, alice);
            },
          );

          test(
            'throws if the slot for the drawn card is empty',
            () {
              alice.plate.place(milk);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                drawnCard: sausages,
              );

              expect(controller.discardDrawnCard, throwsStateError);
              expect(controller.drawnCard, sausages);
              expect(alice.plate[Category.main], isNull);
              expect(controller.discardPile, isEmpty);
            },
          );

          test(
            "only uses the current player's plate",
            () {
              bob.plate.place(fishFingers);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                drawnCard: sausages,
              );

              expect(controller.discardDrawnCard, throwsStateError);
              expect(controller.drawnCard, sausages);
            },
          );

          test(
            'discards a spoiled card if its slot has a food card',
            () {
              alice.plate.place(fishFingers);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [milk],
                drawnCard: fishBone,
              );

              controller.discardDrawnCard();

              expect(alice.plate[Category.main], fishFingers);
              expect(controller.discardPile, [milk, fishBone]);
              expect(controller.drawnCard, isNull);
            },
          );

          test(
            'discards a spoiled card if its slot has a spoiled card',
            () {
              alice.plate.place(leatherBoot);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                drawnCard: fishBone,
              );

              controller.discardDrawnCard();

              expect(alice.plate[Category.main], leatherBoot);
              expect(controller.discardPile, [fishBone]);
              expect(controller.drawnCard, isNull);
            },
          );

          test(
            'throws for a spoiled card if its slot is empty',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                drawnCard: fishBone,
              );

              expect(controller.discardDrawnCard, throwsStateError);
              expect(controller.drawnCard, fishBone);
              expect(alice.plate[Category.main], isNull);
              expect(controller.discardPile, isEmpty);
            },
          );

          test(
            'lets the player keep a spoiled card over a food card',
            () {
              alice.plate.place(fishBone);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                drawnCard: sausages,
              );

              controller.discardDrawnCard();

              expect(alice.plate[Category.main], fishBone);
              expect(controller.discardPile, [sausages]);
              expect(controller.drawnCard, isNull);
            },
          );

          test(
            'throws if no card has been drawn',
            () {
              alice.plate.place(fishFingers);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
              );

              expect(controller.discardDrawnCard, throwsStateError);
              expect(controller.discardPile, isEmpty);
            },
          );
        },
      );
    },
  );
}
