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

      /// A food card for every slot of a plate except the main.
      const allButMain = [jelly, peas, chips, milk];

      List<Player> playersOf(int count) => [
            for (var i = 0; i < count; i++) Player(name: 'Player $i'),
          ];

      test(
        'can be read as a Game',
        () {
          final Game game = GameController(
            players: [alice, bob],
            drawPile: [sausages],
          )..drawFromDrawPile();

          expect(game.players, [alice, bob]);
          expect(game.drawnCard, sausages);
          expect(game.canPlaceDrawnCard, isTrue);
        },
      );

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
        'accepts between minPlayers and maxPlayers players',
        () {
          for (var count = GameController.minPlayers;
              count <= GameController.maxPlayers;
              count++) {
            expect(
              GameController(players: playersOf(count), drawPile: []).players,
              hasLength(count),
            );
          }
        },
      );

      test(
        'throws if there are fewer than minPlayers players',
        () {
          for (final count in [0, GameController.minPlayers - 1]) {
            expect(
              () => GameController(players: playersOf(count), drawPile: []),
              throwsA(
                isA<ArgumentError>().having((e) => e.name, 'name', 'players'),
              ),
            );
          }
        },
      );

      test(
        'throws if there are more than maxPlayers players',
        () {
          expect(
            () => GameController(
              players: playersOf(GameController.maxPlayers + 1),
              drawPile: [],
            ),
            throwsArgumentError,
          );
        },
      );

      test(
        'throws if the same player is in the game more than once',
        () {
          expect(
            () => GameController(players: [alice, alice], drawPile: []),
            throwsA(
              isA<ArgumentError>().having((e) => e.name, 'name', 'players'),
            ),
          );
        },
      );

      test(
        'tells apart players with the same name',
        () {
          final twin = Player(name: 'Alice');
          final controller = GameController(
            players: [alice, twin],
            plates: {
              alice: [sausages],
            },
            drawPile: [],
          );

          expect(controller.plateOf(alice)[Category.main], sausages);
          expect(controller.plateOf(twin)[Category.main], isNull);
        },
      );

      group(
        'plates',
        () {
          test(
            'gives each player their starting cards',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [sausages, milk],
                  bob: [jelly],
                },
                drawPile: [],
              );

              expect(controller.plateOf(alice)[Category.main], sausages);
              expect(controller.plateOf(alice)[Category.drink], milk);
              expect(controller.plateOf(bob)[Category.dessert], jelly);
              expect(controller.plateOf(bob)[Category.main], isNull);
            },
          );

          test(
            'defaults to an empty plate for every player',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
              );

              for (final player in [alice, bob]) {
                for (final category in Category.values) {
                  expect(controller.plateOf(player)[category], isNull);
                }
              }
            },
          );

          test(
            'are not changed by later changes to the given lists',
            () {
              final cards = [sausages];
              final controller = GameController(
                players: [alice, bob],
                plates: {alice: cards},
                drawPile: [],
              );

              cards.add(milk);

              expect(controller.plateOf(alice)[Category.drink], isNull);
            },
          );

          test(
            'throws if a key is not one of the players',
            () {
              expect(
                () => GameController(
                  players: [alice, bob],
                  plates: {
                    Player(name: 'Carol'): [sausages],
                  },
                  drawPile: [],
                ),
                throwsA(
                  isA<ArgumentError>().having((e) => e.name, 'name', 'plates'),
                ),
              );
            },
          );

          test(
            "throws if two of a player's cards share a category",
            () {
              expect(
                () => GameController(
                  players: [alice, bob],
                  plates: {
                    alice: [sausages, fishFingers],
                  },
                  drawPile: [],
                ),
                throwsArgumentError,
              );
            },
          );
        },
      );

      group(
        'plateOf',
        () {
          test(
            'gives the player a new plate when a card is placed',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [milk],
                },
                drawPile: [],
                drawnCard: sausages,
              );
              final before = controller.plateOf(alice);

              controller.placeDrawnCard();

              expect(controller.plateOf(alice), Plate([milk, sausages]));
              expect(before, Plate([milk]));
            },
          );

          test(
            "keeps the player's plate when their card is discarded",
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [],
                drawnCard: sausages,
              );
              final before = controller.plateOf(alice);

              controller.discardDrawnCard();

              expect(controller.plateOf(alice), same(before));
            },
          );

          test(
            'throws if the player is not in the game',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
              );

              expect(
                () => controller.plateOf(Player(name: 'Alice')),
                throwsA(
                  isA<ArgumentError>().having((e) => e.name, 'name', 'player'),
                ),
              );
            },
          );
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
              final controller = GameController.start(
                [alice, bob],
                random: Random(42),
              );

              // A drawn card has to be placed in an empty slot, so whether
              // anyone completes a meal before the draw pile runs out
              // depends on the seed. Random(42) happens not to, which is
              // checked so that a changed seed or deck fails clearly.
              while (controller.drawPile.isNotEmpty && !controller.isGameOver) {
                controller.drawFromDrawPile();

                if (controller.canDiscardDrawnCard) {
                  controller.discardDrawnCard();
                } else {
                  controller.placeDrawnCard();
                }
              }

              expect(
                controller.isGameOver,
                isFalse,
                reason: 'The seed must not let anyone win before a reshuffle',
              );

              final discarded = List.of(controller.discardPile);
              controller.drawFromDrawPile();

              // The deal and the reshuffle draw from the same Random, so
              // replay both with a fresh Random(42).
              final random = Random(42);
              shuffle(buildDeck(), random);
              final expected = discarded;
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
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [...allButMain],
                },
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
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [...allButMain, fishBone],
                },
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

              expect(controller.plateOf(alice)[Category.main], sausages);
              expect(controller.discardPile, isEmpty);
              expect(controller.drawnCard, isNull);
            },
          );

          test(
            'replaces the card in a filled slot and discards it',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [],
                discardPile: [milk],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(controller.plateOf(alice)[Category.main], sausages);
              expect(controller.discardPile, [milk, fishFingers]);
              expect(controller.drawnCard, isNull);
            },
          );

          test(
            "only uses the current player's plate",
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  bob: [fishFingers],
                },
                drawPile: [],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(controller.plateOf(alice)[Category.main], sausages);
              expect(controller.plateOf(bob)[Category.main], fishFingers);
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
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [...allButMain],
                },
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
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
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

              expect(controller.plateOf(alice)[Category.main], fishBone);
              expect(controller.discardPile, isEmpty);
              expect(controller.drawnCard, isNull);
            },
          );

          test(
            'replaces a spoiled card on the plate and discards it',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishBone],
                },
                drawPile: [],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(controller.plateOf(alice)[Category.main], sausages);
              expect(controller.discardPile, [fishBone]);
              expect(controller.drawnCard, isNull);
            },
          );

          test(
            'throws for a spoiled card if its slot has a food card',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [],
                drawnCard: fishBone,
              );

              expect(controller.placeDrawnCard, throwsStateError);
              expect(controller.drawnCard, fishBone);
              expect(controller.plateOf(alice)[Category.main], fishFingers);
              expect(controller.discardPile, isEmpty);
            },
          );

          test(
            'throws for a spoiled card if its slot has a spoiled card',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [leatherBoot],
                },
                drawPile: [],
                drawnCard: fishBone,
              );

              expect(controller.placeDrawnCard, throwsStateError);
              expect(controller.drawnCard, fishBone);
              expect(controller.plateOf(alice)[Category.main], leatherBoot);
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
              expect(controller.plateOf(alice)[Category.main], isNull);
              expect(controller.discardPile, isEmpty);
            },
          );

          test(
            'throws once a player has won',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  bob: [...allButMain, sausages],
                },
                drawPile: [],
                drawnCard: fishFingers,
              );

              expect(controller.placeDrawnCard, throwsStateError);
              expect(controller.drawnCard, fishFingers);
              expect(controller.plateOf(alice)[Category.main], isNull);
              expect(controller.winner, bob);
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
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [],
                discardPile: [milk],
                drawnCard: sausages,
              );

              controller.discardDrawnCard();

              expect(controller.plateOf(alice)[Category.main], fishFingers);
              expect(controller.discardPile, [milk, sausages]);
              expect(controller.drawnCard, isNull);
            },
          );

          test(
            'does not change the draw pile',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
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
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
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
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [milk],
                },
                drawPile: [],
                drawnCard: sausages,
              );

              expect(controller.discardDrawnCard, throwsStateError);
              expect(controller.drawnCard, sausages);
              expect(controller.plateOf(alice)[Category.main], isNull);
              expect(controller.discardPile, isEmpty);
            },
          );

          test(
            "only uses the current player's plate",
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  bob: [fishFingers],
                },
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
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [],
                discardPile: [milk],
                drawnCard: fishBone,
              );

              controller.discardDrawnCard();

              expect(controller.plateOf(alice)[Category.main], fishFingers);
              expect(controller.discardPile, [milk, fishBone]);
              expect(controller.drawnCard, isNull);
            },
          );

          test(
            'discards a spoiled card if its slot has a spoiled card',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [leatherBoot],
                },
                drawPile: [],
                drawnCard: fishBone,
              );

              controller.discardDrawnCard();

              expect(controller.plateOf(alice)[Category.main], leatherBoot);
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
              expect(controller.plateOf(alice)[Category.main], isNull);
              expect(controller.discardPile, isEmpty);
            },
          );

          test(
            'lets the player keep a spoiled card over a food card',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishBone],
                },
                drawPile: [],
                drawnCard: sausages,
              );

              controller.discardDrawnCard();

              expect(controller.plateOf(alice)[Category.main], fishBone);
              expect(controller.discardPile, [sausages]);
              expect(controller.drawnCard, isNull);
            },
          );

          test(
            'throws if no card has been drawn',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [sausages],
              );

              expect(controller.discardDrawnCard, throwsStateError);
              expect(controller.discardPile, isEmpty);
            },
          );

          test(
            'throws once a player has won',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  bob: [...allButMain, sausages],
                  alice: [fishFingers],
                },
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
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  bob: [...allButMain, sausages],
                },
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
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  bob: [...allButMain, sausages],
                },
                drawPile: [],
                discardPile: [milk],
              );

              expect(controller.canDrawFromDiscardPile, isFalse);
            },
          );
        },
      );

      group(
        'currentPlayer',
        () {
          /// Draws the top card of the draw pile and discards it, which every
          /// player can do while their main slot holds a spoiled card, since
          /// every card drawn is a main.
          void takeTurn(GameController controller) {
            controller
              ..drawFromDrawPile()
              ..discardDrawnCard();
          }

          test(
            'is the first player at the start of a game',
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
            'is the player at the given index',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
                currentPlayerIndex: 1,
              );

              expect(controller.currentPlayerIndex, 1);
              expect(controller.currentPlayer, bob);
            },
          );

          test(
            'throws if the given index is out of range',
            () {
              for (final index in [-1, 2]) {
                expect(
                  () => GameController(
                    players: [alice, bob],
                    drawPile: [sausages],
                    currentPlayerIndex: index,
                  ),
                  throwsRangeError,
                );
              }
            },
          );

          test(
            'is the winner if a plate is full when the game is set up',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  bob: [...allButMain, sausages],
                },
                drawPile: [fishFingers],
              );

              expect(controller.currentPlayerIndex, 1);
              expect(controller.currentPlayer, bob);
            },
          );

          test(
            "throws if the given index isn't the winner's",
            () {
              expect(
                () => GameController(
                  players: [alice, bob],
                  plates: {
                    bob: [...allButMain, sausages],
                  },
                  drawPile: [fishFingers],
                  currentPlayerIndex: 0,
                ),
                throwsArgumentError,
              );
            },
          );

          for (final count in [
            GameController.minPlayers,
            3,
            GameController.maxPlayers,
          ]) {
            test(
              'passes the turn through $count players and back to the first',
              () {
                final players = playersOf(count);
                final controller = GameController(
                  players: players,
                  plates: {
                    for (final player in players) player: [fishBone],
                  },
                  drawPile: List.filled(count, leatherBoot),
                );

                final order = <Player>[controller.currentPlayer];

                for (var i = 0; i < count; i++) {
                  takeTurn(controller);
                  order.add(controller.currentPlayer);
                }

                expect(order, [...players, players.first]);
              },
            );
          }

          test(
            'does not pass the turn when a card is drawn',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [sausages],
                discardPile: [milk],
              );

              controller.drawFromDrawPile();
              expect(controller.currentPlayer, alice);

              controller.discardDrawnCard();
              expect(controller.currentPlayer, bob);

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

              expect(controller.plateOf(alice)[Category.main], sausages);
              expect(controller.plateOf(bob)[Category.main], fishFingers);
              expect(controller.currentPlayer, alice);
            },
          );
        },
      );

      group(
        'lastPlayer',
        () {
          test(
            'is null before any card has been played',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
              );

              expect(controller.lastPlayerIndex, isNull);
              expect(controller.lastPlayer, isNull);
            },
          );

          test(
            'is not set by drawing a card',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
              );

              controller.drawFromDrawPile();

              expect(controller.lastPlayerIndex, isNull);
              expect(controller.lastPlayer, isNull);
            },
          );

          test(
            'is the player who placed a card once the turn has passed',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [milk],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(controller.lastPlayerIndex, 0);
              expect(controller.lastPlayer, alice);
              expect(controller.currentPlayer, bob);
            },
          );

          test(
            'is the player who discarded a card once the turn has passed',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [milk],
                drawnCard: sausages,
              );

              controller.discardDrawnCard();

              expect(controller.lastPlayerIndex, 0);
              expect(controller.lastPlayer, alice);
              expect(controller.currentPlayer, bob);
            },
          );

          test(
            'is the winner after a winning play',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  bob: [...allButMain],
                },
                drawPile: [fishFingers, sausages],
              );

              controller
                ..drawFromDrawPile()
                ..placeDrawnCard()
                ..drawFromDrawPile()
                ..placeDrawnCard();

              expect(controller.winner, bob);
              expect(controller.lastPlayerIndex, 1);
              expect(controller.lastPlayer, bob);
            },
          );

          test(
            'does not change if a move throws',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [milk],
                drawnCard: sausages,
              );
              controller.discardDrawnCard();
              controller.drawFromDrawPile();

              expect(controller.discardDrawnCard, throwsStateError);
              expect(controller.lastPlayerIndex, 0);
              expect(controller.lastPlayer, alice);
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

              expect(controller.winnerIndex, isNull);
              expect(controller.winner, isNull);
              expect(controller.isGameOver, isFalse);
            },
          );

          test(
            'is null while a plate is missing a card',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [...allButMain],
                },
                drawPile: [sausages],
              );

              expect(controller.winner, isNull);
              expect(controller.isGameOver, isFalse);
            },
          );

          test(
            'is null while a full plate has a spoiled card',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [...allButMain, fishBone],
                },
                drawPile: [sausages],
              );

              expect(controller.winner, isNull);
              expect(controller.isGameOver, isFalse);
            },
          );

          test(
            'is the current player once placing a card completes their meal',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [...allButMain],
                },
                drawPile: [fishFingers],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(controller.winnerIndex, 0);
              expect(controller.winner, alice);
              expect(controller.isGameOver, isTrue);
            },
          );

          test(
            'is the current player once a food card replaces a spoiled card',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [...allButMain, fishBone],
                },
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
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [...allButMain],
                },
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
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [...allButMain, fishBone],
                },
                drawPile: [fishFingers],
                drawnCard: leatherBoot,
              );

              controller.discardDrawnCard();

              expect(controller.winner, isNull);
              expect(controller.isGameOver, isFalse);
            },
          );

          test(
            'is the player whose plate is full when the game is set up',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  bob: [...allButMain, sausages],
                },
                drawPile: [fishFingers],
              );

              expect(controller.winnerIndex, 1);
              expect(controller.winner, bob);
              expect(controller.isGameOver, isTrue);
            },
          );

          test(
            'throws an ArgumentError if more than one plate is full',
            () {
              expect(
                () => GameController(
                  players: [alice, bob],
                  plates: {
                    alice: [...allButMain, fishFingers],
                    bob: [...allButMain, sausages],
                  },
                  drawPile: [],
                ),
                throwsArgumentError,
              );
            },
          );
        },
      );

      group(
        'canPlaceDrawnCard',
        () {
          GameController holding(
            Card drawnCard, {
            Map<Player, List<Card>> plates = const {},
          }) =>
              GameController(
                players: [alice, bob],
                plates: plates,
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
              final controller = holding(
                sausages,
                plates: {
                  alice: [fishFingers],
                },
              );

              expect(controller.canPlaceDrawnCard, isTrue);
            },
          );

          test(
            'is true for a food card if its slot has a spoiled card',
            () {
              final controller = holding(
                sausages,
                plates: {
                  alice: [leatherBoot],
                },
              );

              expect(controller.canPlaceDrawnCard, isTrue);
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
              final controller = holding(
                fishBone,
                plates: {
                  alice: [fishFingers],
                },
              );

              expect(controller.canPlaceDrawnCard, isFalse);
            },
          );

          test(
            'is false for a spoiled card if its slot has a spoiled card',
            () {
              final controller = holding(
                fishBone,
                plates: {
                  alice: [leatherBoot],
                },
              );

              expect(controller.canPlaceDrawnCard, isFalse);
            },
          );

          test(
            "only uses the current player's plate",
            () {
              final controller = holding(
                fishBone,
                plates: {
                  bob: [fishFingers],
                },
              );

              expect(controller.canPlaceDrawnCard, isTrue);
            },
          );

          test(
            'is false once a player has won',
            () {
              final controller = holding(
                fishFingers,
                plates: {
                  bob: [...allButMain, sausages],
                },
              );

              expect(controller.canPlaceDrawnCard, isFalse);
            },
          );
        },
      );

      group(
        'canDiscardDrawnCard',
        () {
          GameController holding(
            Card drawnCard, {
            Map<Player, List<Card>> plates = const {},
          }) =>
              GameController(
                players: [alice, bob],
                plates: plates,
                drawPile: [],
                drawnCard: drawnCard,
              );

          test(
            'is false if no card has been drawn',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
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
              final controller = holding(
                sausages,
                plates: {
                  alice: [fishFingers],
                },
              );

              expect(controller.canDiscardDrawnCard, isTrue);
            },
          );

          test(
            'is true for a food card if its slot has a spoiled card',
            () {
              final controller = holding(
                sausages,
                plates: {
                  alice: [leatherBoot],
                },
              );

              expect(controller.canDiscardDrawnCard, isTrue);
            },
          );

          test(
            'is true for a spoiled card if its slot is filled',
            () {
              final controller = holding(
                fishBone,
                plates: {
                  alice: [fishFingers],
                },
              );

              expect(controller.canDiscardDrawnCard, isTrue);
            },
          );

          test(
            "only uses the current player's plate",
            () {
              final controller = holding(
                sausages,
                plates: {
                  bob: [fishFingers],
                },
              );

              expect(controller.canDiscardDrawnCard, isFalse);
            },
          );

          test(
            'is false once a player has won',
            () {
              final controller = holding(
                sausages,
                plates: {
                  bob: [...allButMain, sausages],
                  alice: [fishFingers],
                },
              );

              expect(controller.canDiscardDrawnCard, isFalse);
            },
          );
        },
      );
    },
  );
}
