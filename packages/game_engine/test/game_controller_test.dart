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
      const jelly = Card(
        id: '6',
        type: CardType.standard,
        category: Category.dessert,
        name: 'Jelly',
      );
      const peas = Card(
        id: '7',
        type: CardType.standard,
        category: Category.vegetable,
        name: 'Peas',
      );
      const chips = Card(
        id: '8',
        type: CardType.standard,
        category: Category.carbohydrate,
        name: 'Chips',
      );

      late Player alice;
      late Player bob;

      setUp(
        () {
          alice = Player(name: 'Alice');
          bob = Player(name: 'Bob');
        },
      );

      /// Fills every slot of [player]'s plate except the main with a food
      /// card.
      void fillAllButMain(Player player) {
        player.plate
          ..place(jelly)
          ..place(peas)
          ..place(chips)
          ..place(milk);
      }

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
            'reshuffles the discard pile into the draw pile if it is empty',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [sausages, milk, fishFingers],
              );

              controller.drawFromDrawPile();

              expect(controller.discardPile, isEmpty);
              expect(
                [...controller.drawPile, controller.drawnCard],
                unorderedEquals([sausages, milk, fishFingers]),
              );
              expect(controller.drawPile, hasLength(2));
            },
          );

          test(
            'reshuffles the discard pile with the given random',
            () {
              final deck = buildDeck();

              GameController reshuffle() {
                final controller = GameController(
                  players: [alice, bob],
                  drawPile: [],
                  discardPile: deck,
                  random: Random(42),
                );

                controller.drawFromDrawPile();

                return controller;
              }

              final controller = reshuffle();

              final expected = List.of(deck);
              shuffle(expected, Random(42));

              expect([...controller.drawPile, controller.drawnCard], expected);
              expect(expected, isNot(deck));
            },
          );

          test(
            'shares the random from start with reshuffles',
            () {
              // Every slot holds a spoiled card, so each drawn card can be
              // discarded and no player can complete a meal.
              Player withSpoiledPlate(String name) {
                final plate = Plate();

                for (final card in buildDeck()) {
                  if (card.type == CardType.spoiled) {
                    plate.place(card);
                  }
                }

                return Player(name: name, plate: plate);
              }

              final controller = GameController.start(
                [withSpoiledPlate('Alice'), withSpoiledPlate('Bob')],
                random: Random(42),
              );

              while (controller.drawPile.isNotEmpty) {
                controller.drawFromDrawPile();
                controller.discardDrawnCard();
              }

              controller.drawFromDrawPile();

              // The deal and the reshuffle draw from the same Random, so
              // replay both with a fresh Random(42).
              final random = Random(42);
              final dealt = buildDeck();
              shuffle(dealt, random);
              final expected = dealt.reversed.toList();
              shuffle(expected, random);

              expect([...controller.drawPile, controller.drawnCard], expected);
            },
          );

          test(
            'does not reshuffle if the draw pile has cards',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
                discardPile: [milk, fishFingers],
              );

              controller.drawFromDrawPile();

              expect(controller.drawPile, isEmpty);
              expect(controller.discardPile, [milk, fishFingers]);
            },
          );

          test(
            'throws if both the draw pile and the discard pile are empty',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
              );

              expect(controller.drawFromDrawPile, throwsStateError);
              expect(controller.drawnCard, isNull);
            },
          );

          test(
            'throws once a player has won',
            () {
              fillAllButMain(alice);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [fishFingers],
                drawnCard: sausages,
              );
              controller.placeDrawnCard();

              expect(controller.drawFromDrawPile, throwsStateError);
              expect(controller.drawnCard, isNull);
              expect(controller.drawPile, [fishFingers]);
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

          test(
            'throws once a player has won',
            () {
              fillAllButMain(alice);
              alice.plate.place(fishBone);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                drawnCard: sausages,
              );
              controller.placeDrawnCard();

              expect(controller.discardPile, [fishBone]);
              expect(controller.drawFromDiscardPile, throwsStateError);
              expect(controller.drawnCard, isNull);
              expect(controller.discardPile, [fishBone]);
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
            'does not change the draw pile',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [milk],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(controller.drawPile, [milk]);
            },
          );

          test(
            "ends the current player's turn",
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [milk],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(controller.currentPlayer, bob);
            },
          );

          test(
            "does not end the current player's turn if they win",
            () {
              fillAllButMain(alice);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [milk],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(controller.winner, alice);
              expect(controller.currentPlayer, alice);
            },
          );

          test(
            "does not end the current player's turn if it throws",
            () {
              alice.plate.place(fishFingers);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [milk],
                drawnCard: fishBone,
              );

              expect(controller.placeDrawnCard, throwsStateError);
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

          test(
            'throws once a player has won',
            () {
              fillAllButMain(bob);
              bob.plate.place(sausages);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                drawnCard: fishFingers,
              );

              expect(controller.placeDrawnCard, throwsStateError);
              expect(controller.drawnCard, fishFingers);
              expect(alice.plate[Category.main], isNull);
              expect(controller.winner, bob);
            },
          );

          test(
            'does not change the winner if another plate is filled after',
            () {
              fillAllButMain(alice);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                drawnCard: sausages,
              );
              controller.placeDrawnCard();

              fillAllButMain(bob);
              bob.plate.place(fishFingers);

              expect(controller.winner, alice);
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
            'does not change the draw pile',
            () {
              alice.plate.place(fishFingers);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [milk],
                drawnCard: sausages,
              );

              controller.discardDrawnCard();

              expect(controller.drawPile, [milk]);
            },
          );

          test(
            "ends the current player's turn",
            () {
              alice.plate.place(fishFingers);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [milk],
                drawnCard: sausages,
              );

              controller.discardDrawnCard();

              expect(controller.currentPlayer, bob);
            },
          );

          test(
            "does not end the current player's turn if it throws",
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [milk],
                drawnCard: sausages,
              );

              expect(controller.discardDrawnCard, throwsStateError);
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

          test(
            'throws once a player has won',
            () {
              fillAllButMain(bob);
              bob.plate.place(sausages);
              alice.plate.place(fishFingers);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                drawnCard: sausages,
              );

              expect(controller.discardDrawnCard, throwsStateError);
              expect(controller.drawnCard, sausages);
              expect(controller.discardPile, isEmpty);
            },
          );
        },
      );

      group(
        'canDrawFromDrawPile',
        () {
          test(
            'is true if the draw pile has cards',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
              );

              expect(controller.canDrawFromDrawPile, isTrue);
            },
          );

          test(
            'is true if only the discard pile has cards',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [milk],
              );

              expect(controller.canDrawFromDrawPile, isTrue);
            },
          );

          test(
            'is false if both the draw pile and the discard pile are empty',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
              );

              expect(controller.canDrawFromDrawPile, isFalse);
            },
          );

          test(
            'is false if a drawn card has not yet been played',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
                discardPile: [milk],
                drawnCard: fishFingers,
              );

              expect(controller.canDrawFromDrawPile, isFalse);
            },
          );

          test(
            'is false once a player has won',
            () {
              fillAllButMain(bob);
              bob.plate.place(sausages);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [fishFingers],
                discardPile: [milk],
              );

              expect(controller.canDrawFromDrawPile, isFalse);
            },
          );
        },
      );

      group(
        'canDrawFromDiscardPile',
        () {
          test(
            'is true if the discard pile has cards',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [milk],
              );

              expect(controller.canDrawFromDiscardPile, isTrue);
            },
          );

          test(
            'is false if the discard pile is empty',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
              );

              expect(controller.canDrawFromDiscardPile, isFalse);
            },
          );

          test(
            'is false if a drawn card has not yet been played',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [milk],
                drawnCard: fishFingers,
              );

              expect(controller.canDrawFromDiscardPile, isFalse);
            },
          );

          test(
            'is false once a player has won',
            () {
              fillAllButMain(bob);
              bob.plate.place(sausages);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [milk],
              );

              expect(controller.canDrawFromDiscardPile, isFalse);
            },
          );
        },
      );

      group(
        'turn order',
        () {
          /// Draws the top card of the draw pile and discards it, which every
          /// player can do while their plate holds a spoiled card in every
          /// slot.
          void takeTurn(GameController controller) {
            controller
              ..drawFromDrawPile()
              ..discardDrawnCard();
          }

          List<Player> spoiledPlayersOf(int count) => [
                for (var i = 0; i < count; i++)
                  Player(
                    name: 'Player $i',
                    plate: Plate(
                      dessert: fishBone,
                      vegetable: fishBone,
                      main: fishBone,
                      carbohydrate: fishBone,
                      drink: fishBone,
                    ),
                  ),
              ];

          for (final count in [
            GameController.minPlayers,
            3,
            GameController.maxPlayers,
          ]) {
            test(
              'passes the turn to each of $count players in order and '
              'back to the first',
              () {
                final players = spoiledPlayersOf(count);
                final controller = GameController(
                  players: players,
                  drawPile: List.filled(count + 1, leatherBoot),
                );

                final order = <Player>[controller.currentPlayer];

                for (var i = 0; i < count; i++) {
                  takeTurn(controller);
                  order.add(controller.currentPlayer);
                }

                expect(order, [...players, players.first]);
                expect(controller.currentPlayerIndex, 0);
              },
            );
          }

          test(
            'does not pass the turn when a card is drawn',
            () {
              alice.plate.place(fishFingers);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
                discardPile: [milk],
              );

              controller.drawFromDrawPile();
              expect(controller.currentPlayer, alice);

              controller.discardDrawnCard();
              controller.drawFromDiscardPile();
              expect(controller.currentPlayer, bob);
            },
          );

          test(
            "uses the next player's plate once the turn has passed",
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [fishFingers, sausages],
              );

              controller
                ..drawFromDrawPile()
                ..placeDrawnCard()
                ..drawFromDrawPile()
                ..placeDrawnCard();

              expect(alice.plate[Category.main], sausages);
              expect(bob.plate[Category.main], fishFingers);
              expect(controller.currentPlayer, alice);
            },
          );
        },
      );

      group(
        'winner',
        () {
          test(
            'is null at the start of a game',
            () {
              final controller = GameController.start(
                [alice, bob],
                random: Random(0),
              );

              expect(controller.winner, isNull);
              expect(controller.isGameOver, isFalse);
            },
          );

          test(
            'is null while a plate is missing a card',
            () {
              fillAllButMain(alice);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
              );

              expect(controller.winner, isNull);
              expect(controller.isGameOver, isFalse);
            },
          );

          test(
            'is null while a full plate has a spoiled card',
            () {
              fillAllButMain(alice);
              alice.plate.place(fishBone);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
              );

              expect(controller.winner, isNull);
              expect(controller.isGameOver, isFalse);
            },
          );

          test(
            'is the current player once placing a card completes their meal',
            () {
              fillAllButMain(alice);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [fishFingers],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(controller.winner, alice);
              expect(controller.isGameOver, isTrue);
            },
          );

          test(
            'is the current player once a food card replaces their last '
            'spoiled card',
            () {
              fillAllButMain(alice);
              alice.plate.place(fishBone);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [fishFingers],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(controller.winner, alice);
              expect(controller.discardPile, [fishBone]);
            },
          );

          test(
            'is null once a spoiled card fills the last empty slot',
            () {
              fillAllButMain(alice);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [fishFingers],
                drawnCard: fishBone,
              );

              controller.placeDrawnCard();

              expect(controller.winner, isNull);
              expect(controller.isGameOver, isFalse);
            },
          );

          test(
            'is null once a drawn card is discarded',
            () {
              fillAllButMain(alice);
              alice.plate.place(fishBone);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [fishFingers],
                drawnCard: leatherBoot,
              );

              controller.discardDrawnCard();

              expect(controller.winner, isNull);
              expect(controller.isGameOver, isFalse);
            },
          );

          test(
            'is a player other than the current one if their plate is full',
            () {
              fillAllButMain(bob);
              bob.plate.place(sausages);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [fishFingers],
              );

              expect(controller.winner, bob);
              expect(controller.isGameOver, isTrue);
            },
          );

          test(
            'throws an ArgumentError if more than one plate is full',
            () {
              fillAllButMain(alice);
              alice.plate.place(fishFingers);
              fillAllButMain(bob);
              bob.plate.place(sausages);

              expect(
                () => GameController(players: [alice, bob], drawPile: []),
                throwsArgumentError,
              );
            },
          );
        },
      );

      group(
        'canPlaceDrawnCard',
        () {
          GameController holding(Card drawnCard) => GameController(
                players: [alice, bob],
                drawPile: [],
                drawnCard: drawnCard,
              );

          test(
            'is false if no card has been drawn',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
              );

              expect(controller.canPlaceDrawnCard, isFalse);
            },
          );

          test(
            'is true for a food card if its slot is empty',
            () {
              expect(holding(sausages).canPlaceDrawnCard, isTrue);
            },
          );

          test(
            'is true for a food card if its slot is filled',
            () {
              alice.plate.place(fishFingers);

              expect(holding(sausages).canPlaceDrawnCard, isTrue);
            },
          );

          test(
            'is true for a food card if its slot has a spoiled card',
            () {
              alice.plate.place(leatherBoot);

              expect(holding(sausages).canPlaceDrawnCard, isTrue);
            },
          );

          test(
            'is true for a spoiled card if its slot is empty',
            () {
              expect(holding(fishBone).canPlaceDrawnCard, isTrue);
            },
          );

          test(
            'is false for a spoiled card if its slot has a food card',
            () {
              alice.plate.place(fishFingers);

              expect(holding(fishBone).canPlaceDrawnCard, isFalse);
            },
          );

          test(
            'is false for a spoiled card if its slot has a spoiled card',
            () {
              alice.plate.place(leatherBoot);

              expect(holding(fishBone).canPlaceDrawnCard, isFalse);
            },
          );

          test(
            "only uses the current player's plate",
            () {
              bob.plate.place(fishFingers);

              expect(holding(fishBone).canPlaceDrawnCard, isTrue);
            },
          );

          test(
            'is false once a player has won',
            () {
              fillAllButMain(bob);
              bob.plate.place(sausages);

              expect(holding(fishFingers).canPlaceDrawnCard, isFalse);
            },
          );
        },
      );

      group(
        'canDiscardDrawnCard',
        () {
          GameController holding(Card drawnCard) => GameController(
                players: [alice, bob],
                drawPile: [],
                drawnCard: drawnCard,
              );

          test(
            'is false if no card has been drawn',
            () {
              alice.plate.place(fishFingers);
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
              );

              expect(controller.canDiscardDrawnCard, isFalse);
            },
          );

          test(
            'is false for a food card if its slot is empty',
            () {
              expect(holding(sausages).canDiscardDrawnCard, isFalse);
            },
          );

          test(
            'is false for a spoiled card if its slot is empty',
            () {
              expect(holding(fishBone).canDiscardDrawnCard, isFalse);
            },
          );

          test(
            'is true for a food card if its slot is filled',
            () {
              alice.plate.place(fishFingers);

              expect(holding(sausages).canDiscardDrawnCard, isTrue);
            },
          );

          test(
            'is true for a food card if its slot has a spoiled card',
            () {
              alice.plate.place(leatherBoot);

              expect(holding(sausages).canDiscardDrawnCard, isTrue);
            },
          );

          test(
            'is true for a spoiled card if its slot is filled',
            () {
              alice.plate.place(fishFingers);

              expect(holding(fishBone).canDiscardDrawnCard, isTrue);
            },
          );

          test(
            "only uses the current player's plate",
            () {
              bob.plate.place(fishFingers);

              expect(holding(sausages).canDiscardDrawnCard, isFalse);
            },
          );

          test(
            'is false once a player has won',
            () {
              fillAllButMain(bob);
              bob.plate.place(sausages);
              alice.plate.place(fishFingers);

              expect(holding(sausages).canDiscardDrawnCard, isFalse);
            },
          );
        },
      );
    },
  );
}
