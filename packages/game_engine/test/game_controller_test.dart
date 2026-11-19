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
      const water = Card(
        id: '9',
        type: CardType.standard,
        category: Category.drink,
        name: 'Water',
      );
      const pondWater = Card(
        id: '10',
        type: CardType.spoiled,
        category: Category.drink,
        name: 'Pond Water',
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

      /// A game in which [alice] has already won, by holding a full plate.
      GameController wonByAlice({
        List<Card> drawPile = const [fishFingers],
        List<Card> discardPile = const [milk],
        Card? drawnCard,
      }) =>
          GameController(
            players: [alice, bob],
            plates: {
              alice: [...allButMain, sausages],
            },
            drawPile: drawPile,
            discardPile: discardPile,
            drawnCard: drawnCard,
          );

      /// A game in which [alice] has drawn [drawnCard] and not yet played it.
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

      /// Makes [move], ignoring the [StateError] it throws, so that a test
      /// can check what a refused move leaves unchanged.
      void attempt(void Function() move) {
        try {
          move();
        } on StateError {
          // Whether it throws is checked by its own test.
        }
      }

      group(
        'GameController.new',
        () {
          test(
            'creates a controller that can be read as a Game',
            () {
              final Game game = GameController(
                players: [alice, bob],
                drawPile: [sausages],
              )..drawFromDrawPile();

              expect(game.drawnCard, sausages);
            },
          );

          test(
            'holds the players in turn order',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
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
                  GameController(players: playersOf(count), drawPile: [])
                      .players,
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
                    isA<ArgumentError>()
                        .having((e) => e.name, 'name', 'players'),
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
                throwsA(
                  isA<ArgumentError>().having((e) => e.name, 'name', 'players'),
                ),
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
            'is not affected by later changes to the given players',
            () {
              final players = [alice, bob];
              final controller = GameController(
                players: players,
                drawPile: [],
              );

              players.clear();

              expect(controller.players, [alice, bob]);
            },
          );

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

              expect(
                [controller.plateOf(alice), controller.plateOf(bob)],
                [
                  Plate([sausages, milk]),
                  Plate([jelly])
                ],
              );
            },
          );

          test(
            'defaults to an empty plate for every player',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
              );

              expect(
                [controller.plateOf(alice), controller.plateOf(bob)],
                [Plate(), Plate()],
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

              expect(
                [controller.plateOf(alice), controller.plateOf(twin)],
                [
                  Plate([sausages]),
                  Plate()
                ],
              );
            },
          );

          test(
            'is not affected by later changes to the given plates',
            () {
              final cards = [sausages];
              final controller = GameController(
                players: [alice, bob],
                plates: {alice: cards},
                drawPile: [],
              );

              cards.add(milk);

              expect(controller.plateOf(alice), Plate([sausages]));
            },
          );

          test(
            'throws if a key of plates is not one of the players',
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

          test(
            'throws if more than one plate is full',
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
                throwsA(
                  isA<ArgumentError>().having((e) => e.name, 'name', 'plates'),
                ),
              );
            },
          );

          test(
            'holds the given draw pile as-is',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [milk, sausages],
              );

              expect(controller.drawPile, [milk, sausages]);
            },
          );

          test(
            'is not affected by later changes to the given draw pile',
            () {
              final drawPile = [sausages];
              final controller = GameController(
                players: [alice, bob],
                drawPile: drawPile,
              );

              drawPile.clear();

              expect(controller.drawPile, [sausages]);
            },
          );

          test(
            'holds the given discard pile as-is',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [milk, sausages],
              );

              expect(controller.discardPile, [milk, sausages]);
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
            'is not affected by later changes to the given discard pile',
            () {
              final discardPile = [milk];
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: discardPile,
              );

              discardPile.clear();

              expect(controller.discardPile, [milk]);
            },
          );

          test(
            "defaults to the first player's turn",
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
              );

              expect(controller.currentPlayerIndex, 0);
            },
          );

          test(
            "starts with the given player's turn",
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
                currentPlayerIndex: 1,
              );

              expect(controller.currentPlayerIndex, 1);
            },
          );

          test(
            'throws if the given current player index is out of range',
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
            'records the player whose plate is full as the winner',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  bob: [...allButMain, sausages],
                },
                drawPile: [fishFingers],
              );

              expect(controller.winner, bob);
            },
          );

          test(
            "defaults to the winner's turn if a plate is full",
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  bob: [...allButMain, sausages],
                },
                drawPile: [fishFingers],
              );

              expect(controller.currentPlayerIndex, 1);
            },
          );

          test(
            "throws if the given current player index isn't the winner's",
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
                throwsA(
                  isA<ArgumentError>()
                      .having((e) => e.name, 'name', 'currentPlayerIndex'),
                ),
              );
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

          test(
            "starts with the first player's turn",
            () {
              final controller = GameController.start([alice, bob]);

              expect(controller.currentPlayer, alice);
            },
          );

          test(
            'gives every player an empty plate',
            () {
              final controller = GameController.start([alice, bob]);

              expect(
                [controller.plateOf(alice), controller.plateOf(bob)],
                [Plate(), Plate()],
              );
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
              final controller =
                  GameController.start([alice, bob], random: Random(42));

              final expected = buildDeck();
              shuffle(expected, Random(42));

              expect(controller.drawPile, expected);
            },
          );

          test(
            'does not leave the draw pile in deck order',
            () {
              final controller =
                  GameController.start([alice, bob], random: Random(42));

              expect(controller.drawPile, isNot(buildDeck()));
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
            'starts with no winner',
            () {
              final controller =
                  GameController.start([alice, bob], random: Random(0));

              expect(controller.winner, isNull);
            },
          );

          group(
            'deals a game that',
            () {
              /// Every card in [controller]'s game, wherever it is.
              List<Card> cardsIn(GameController controller) => [
                    ...controller.drawPile,
                    ...controller.discardPile,
                    for (final player in controller.players)
                      ...controller.plateOf(player).cards,
                    if (controller.drawnCard case final card?) card,
                  ];

              /// Plays a whole game seeded with [seed], choosing randomly
              /// whenever the rules give a choice, except that a food card
              /// always replaces a spoiled card, so that the game ends.
              ///
              /// Calls [onMove] after every draw and every play.
              GameController play(
                int seed, {
                required void Function(GameController controller) onMove,
              }) {
                final random = Random(seed);
                final playerCount = GameController.minPlayers +
                    seed %
                        (GameController.maxPlayers -
                            GameController.minPlayers +
                            1);
                final controller = GameController.start(
                  playersOf(playerCount),
                  random: random,
                );

                for (var turn = 0; !controller.isGameOver; turn++) {
                  if (turn == 10000) {
                    fail('The game with seed $seed did not end');
                  }

                  if (controller.canDrawFromDiscardPile && random.nextBool()) {
                    controller.drawFromDiscardPile();
                  } else {
                    controller.drawFromDrawPile();
                  }

                  onMove(controller);

                  final card = controller.drawnCard!;
                  final kept = controller
                      .plateOf(controller.currentPlayer)[card.category];

                  if (!controller.canDiscardDrawnCard) {
                    controller.placeDrawnCard();
                  } else if (!controller.canPlaceDrawnCard) {
                    controller.discardDrawnCard();
                  } else if (kept!.type == CardType.spoiled ||
                      random.nextBool()) {
                    controller.placeDrawnCard();
                  } else {
                    controller.discardDrawnCard();
                  }

                  onMove(controller);
                }

                return controller;
              }

              for (var seed = 0; seed < 20; seed++) {
                group(
                  'with seed $seed',
                  () {
                    /// The cards in play after each move of the game.
                    final snapshots = <List<Card>>[];
                    late GameController finished;

                    // Each game is played once, and its tests check what
                    // it recorded.
                    setUpAll(
                      () {
                        finished = play(
                          seed,
                          onMove: (controller) =>
                              snapshots.add(cardsIn(controller)),
                        );
                      },
                    );

                    test(
                      'keeps every card in play after every move',
                      () {
                        final deck = buildDeck();

                        expect(
                          snapshots,
                          everyElement(unorderedEquals(deck)),
                        );
                      },
                    );

                    test(
                      "ends with only the winner's plate full",
                      () {
                        expect(
                          [
                            for (final player in finished.players)
                              if (finished.plateOf(player).isFull) player,
                          ],
                          [finished.winner],
                        );
                      },
                    );
                  },
                );
              }
            },
          );
        },
      );

      group(
        'players',
        () {
          test(
            'cannot be modified',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
              );

              expect(
                  () => controller.players.add(alice), throwsUnsupportedError);
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

              controller.placeDrawnCard();

              expect(controller.plateOf(alice), Plate([milk, sausages]));
            },
          );

          test(
            'gives a plate that is not changed by later placements',
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

      group(
        'drawPile',
        () {
          test(
            'cannot be modified',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
              );

              expect(() => controller.drawPile.clear(), throwsUnsupportedError);
            },
          );
        },
      );

      group(
        'discardPile',
        () {
          test(
            'cannot be modified',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [milk],
              );

              expect(
                () => controller.discardPile.clear(),
                throwsUnsupportedError,
              );
            },
          );
        },
      );

      group(
        'currentPlayerIndex',
        () {
          test(
            "stays as the winner's index once the game is over",
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [...allButMain],
                },
                drawPile: [],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(controller.currentPlayerIndex, 0);
            },
          );
        },
      );

      group(
        'currentPlayer',
        () {
          test(
            'is the player at currentPlayerIndex',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
                currentPlayerIndex: 1,
              );

              expect(controller.currentPlayer, bob);
            },
          );

          for (final count in [
            GameController.minPlayers,
            3,
            GameController.maxPlayers,
          ]) {
            test(
              'passes through $count players and back to the first',
              () {
                final players = playersOf(count);
                // Every card drawn is a main, and every main slot holds a
                // spoiled card, so every drawn card can be discarded.
                final controller = GameController(
                  players: players,
                  plates: {
                    for (final player in players) player: [fishBone],
                  },
                  drawPile: List.filled(count, leatherBoot),
                );

                final order = <Player>[controller.currentPlayer];

                for (var i = 0; i < count; i++) {
                  controller
                    ..drawFromDrawPile()
                    ..discardDrawnCard();
                  order.add(controller.currentPlayer);
                }

                expect(order, [...players, players.first]);
              },
            );
          }
        },
      );

      group(
        'lastPlayerIndex',
        () {
          test(
            'is null before any card has been played',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
              );

              expect(controller.lastPlayerIndex, isNull);
            },
          );

          test(
            'is the index of the player who most recently played a card',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [fishFingers, milk],
                drawnCard: sausages,
              );

              controller
                ..placeDrawnCard()
                ..drawFromDrawPile()
                ..placeDrawnCard();

              expect(controller.lastPlayerIndex, 1);
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

              expect(controller.lastPlayer, alice);
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

              expect(controller.lastPlayer, alice);
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
              controller
                ..discardDrawnCard()
                ..drawFromDrawPile();

              attempt(controller.discardDrawnCard);

              expect(controller.lastPlayer, alice);
            },
          );
        },
      );

      group(
        'winnerIndex',
        () {
          test(
            'is null while no one has won',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
              );

              expect(controller.winnerIndex, isNull);
            },
          );

          test(
            'is the index of the player who won',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  bob: [...allButMain, sausages],
                },
                drawPile: [fishFingers],
              );

              expect(controller.winnerIndex, 1);
            },
          );
        },
      );

      group(
        'winner',
        () {
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

              expect(controller.winner, alice);
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
            },
          );

          test(
            'is the first player to fill their plate if two are a card short',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [...allButMain],
                  bob: [...allButMain],
                },
                drawPile: [fishFingers, sausages],
              );

              controller
                ..drawFromDrawPile()
                ..placeDrawnCard();

              expect(controller.winner, alice);
            },
          );

          test(
            'is the next player if they take a discarded card that fills '
            'their plate',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                  bob: [...allButMain],
                },
                drawPile: [sausages],
              );

              controller
                ..drawFromDrawPile()
                ..discardDrawnCard()
                ..drawFromDiscardPile()
                ..placeDrawnCard();

              expect(controller.winner, bob);
            },
          );
        },
      );

      group(
        'isGameOver',
        () {
          test(
            'is false while no one has won',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [...allButMain],
                },
                drawPile: [sausages],
              );

              expect(controller.isGameOver, isFalse);
            },
          );

          test(
            'is true once a player has won',
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

              expect(controller.isGameOver, isTrue);
            },
          );
        },
      );

      group(
        'canPlaceDrawnCard',
        () {
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
              final controller = wonByAlice(drawnCard: fishFingers);

              expect(controller.canPlaceDrawnCard, isFalse);
            },
          );
        },
      );

      group(
        'canDiscardDrawnCard',
        () {
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
              final controller = wonByAlice(drawnCard: sausages);

              expect(controller.canDiscardDrawnCard, isFalse);
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
            'is false if only the discard pile has cards',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [milk, sausages],
              );

              expect(controller.canDrawFromDrawPile, isFalse);
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
              expect(wonByAlice().canDrawFromDrawPile, isFalse);
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
              expect(wonByAlice().canDrawFromDiscardPile, isFalse);
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
            'empties the draw pile when drawing its last card',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
              );

              controller.drawFromDrawPile();

              expect(controller.drawPile, isEmpty);
            },
          );

          test(
            'does not change the discard pile if the draw pile has cards',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
                discardPile: [milk, fishFingers],
              );

              controller.drawFromDrawPile();

              expect(controller.discardPile, [milk, fishFingers]);
            },
          );

          test(
            'does not change the current player',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
              );

              controller.drawFromDrawPile();

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
            },
          );

          test(
            'throws if the draw pile is empty',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [sausages, milk],
              );

              expect(controller.drawFromDrawPile, throwsStateError);
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
            },
          );

          test(
            'throws if the last card was placed with the discard pile empty',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
              );

              controller
                ..drawFromDrawPile()
                ..placeDrawnCard();

              expect(controller.drawFromDrawPile, throwsStateError);
            },
          );

          test(
            'throws once a player has won',
            () {
              expect(wonByAlice().drawFromDrawPile, throwsStateError);
            },
          );

          test(
            'does not change the drawn card if it throws',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
                drawnCard: milk,
              );

              attempt(controller.drawFromDrawPile);

              expect(controller.drawnCard, milk);
            },
          );

          test(
            'does not change the draw pile if it throws',
            () {
              final controller = wonByAlice(drawPile: [fishFingers]);

              attempt(controller.drawFromDrawPile);

              expect(controller.drawPile, [fishFingers]);
            },
          );

          test(
            'does not refill the draw pile from the discard pile',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [sausages, milk],
              );

              attempt(controller.drawFromDrawPile);

              expect(controller.drawPile, isEmpty);
              expect(controller.discardPile, [sausages, milk]);
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
            'empties the discard pile when drawing its last card',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [sausages],
              );

              controller.drawFromDiscardPile();

              expect(controller.discardPile, isEmpty);
            },
          );

          test(
            'does not change the draw pile',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [milk],
                discardPile: [sausages],
              );

              controller.drawFromDiscardPile();

              expect(controller.drawPile, [milk]);
            },
          );

          test(
            'does not change the current player',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [milk],
                discardPile: [sausages],
              );

              controller.drawFromDiscardPile();

              expect(controller.currentPlayer, alice);
            },
          );

          test(
            'gives the next player the card that a swap replaced',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [milk],
                },
                drawPile: [water],
              );

              controller
                ..drawFromDrawPile()
                ..placeDrawnCard()
                ..drawFromDiscardPile();

              expect(controller.drawnCard, milk);
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
            },
          );

          test(
            'throws once a player has won',
            () {
              expect(wonByAlice().drawFromDiscardPile, throwsStateError);
            },
          );

          test(
            'does not change the drawn card if it throws',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [sausages],
                drawnCard: milk,
              );

              attempt(controller.drawFromDiscardPile);

              expect(controller.drawnCard, milk);
            },
          );

          test(
            'does not change the discard pile if it throws',
            () {
              final controller = wonByAlice(discardPile: [milk]);

              attempt(controller.drawFromDiscardPile);

              expect(controller.discardPile, [milk]);
            },
          );
        },
      );

      group(
        'placeDrawnCard',
        () {
          test(
            'places a food card on the plate if its slot is empty',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(controller.plateOf(alice)[Category.main], sausages);
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
            },
          );

          test(
            'does not discard anything if the slot is empty',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [milk],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(controller.discardPile, [milk]);
            },
          );

          test(
            'replaces the card in a filled slot',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(controller.plateOf(alice)[Category.main], sausages);
            },
          );

          test(
            'puts the replaced card on top of the discard pile',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [water],
                discardPile: [milk],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(controller.discardPile, [milk, fishFingers]);
            },
          );

          test(
            'replaces a spoiled card with a food card',
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
            },
          );

          test(
            'puts a replaced spoiled card on top of the discard pile',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishBone],
                },
                drawPile: [water],
                discardPile: [milk],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(controller.discardPile, [milk, fishBone]);
            },
          );

          test(
            'places a food card taken from the discard pile in its empty slot',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [fishFingers],
                discardPile: [sausages],
              );

              controller
                ..drawFromDiscardPile()
                ..placeDrawnCard();

              expect(controller.plateOf(alice)[Category.main], sausages);
            },
          );

          test(
            'places a spoiled card taken from the discard pile in its empty '
            'slot',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [fishFingers],
                discardPile: [pondWater],
              );

              controller
                ..drawFromDiscardPile()
                ..placeDrawnCard();

              expect(controller.plateOf(alice)[Category.drink], pondWater);
            },
          );

          test(
            'swaps a food card taken from the discard pile onto a filled slot',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [milk],
                },
                drawPile: [fishFingers],
                discardPile: [sausages, water],
              );

              controller
                ..drawFromDiscardPile()
                ..placeDrawnCard();

              expect(controller.plateOf(alice)[Category.drink], water);
            },
          );

          test(
            'puts the card a discard pile card replaced back on the discard '
            'pile',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [milk],
                },
                drawPile: [fishFingers],
                discardPile: [sausages, water],
              );

              controller
                ..drawFromDiscardPile()
                ..placeDrawnCard();

              expect(controller.discardPile, [sausages, milk]);
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

              expect(controller.plateOf(bob), Plate([fishFingers]));
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

              expect(controller.plateOf(bob)[Category.main], fishFingers);
            },
          );

          test(
            'no longer holds the drawn card',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                drawnCard: sausages,
              );

              controller.placeDrawnCard();

              expect(controller.drawnCard, isNull);
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

              expect(controller.currentPlayer, alice);
            },
          );

          test(
            'wins the game with a card from the discard pile',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [...allButMain],
                },
                drawPile: [fishFingers],
                discardPile: [sausages],
              );

              controller
                ..drawFromDiscardPile()
                ..placeDrawnCard();

              expect(controller.winner, alice);
            },
          );

          test(
            'wins the game with the last card of the draw pile',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [...allButMain],
                },
                drawPile: [sausages],
                discardPile: [fishFingers, fishBone],
              );

              controller
                ..drawFromDrawPile()
                ..placeDrawnCard();

              expect(controller.winner, alice);
            },
          );

          test(
            'does not reshuffle the discard pile after a winning last card',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [...allButMain],
                },
                drawPile: [sausages],
                discardPile: [fishFingers, fishBone],
              );

              controller
                ..drawFromDrawPile()
                ..placeDrawnCard();

              expect(controller.discardPile, [fishFingers, fishBone]);
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
            },
          );

          test(
            'throws once a player has won',
            () {
              final controller = wonByAlice(drawnCard: fishFingers);

              expect(controller.placeDrawnCard, throwsStateError);
            },
          );

          group(
            'if it throws',
            () {
              /// Alice holds a spoiled card whose slot has a food card, so
              /// placing it throws.
              GameController refused() => GameController(
                    players: [alice, bob],
                    plates: {
                      alice: [fishFingers],
                    },
                    drawPile: [milk],
                    drawnCard: fishBone,
                  );

              test(
                'does not change the drawn card',
                () {
                  final controller = refused();

                  attempt(controller.placeDrawnCard);

                  expect(controller.drawnCard, fishBone);
                },
              );

              test(
                "does not change the current player's plate",
                () {
                  final controller = refused();

                  attempt(controller.placeDrawnCard);

                  expect(controller.plateOf(alice), Plate([fishFingers]));
                },
              );

              test(
                'does not change the discard pile',
                () {
                  final controller = refused();

                  attempt(controller.placeDrawnCard);

                  expect(controller.discardPile, isEmpty);
                },
              );

              test(
                "does not end the current player's turn",
                () {
                  final controller = refused();

                  attempt(controller.placeDrawnCard);

                  expect(controller.currentPlayer, alice);
                },
              );
            },
          );
        },
      );

      group(
        'discardDrawnCard',
        () {
          test(
            'puts the drawn card on top of the discard pile',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [water],
                discardPile: [milk],
                drawnCard: sausages,
              );

              controller.discardDrawnCard();

              expect(controller.discardPile, [milk, sausages]);
            },
          );

          test(
            'keeps the card in the filled slot',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [],
                drawnCard: sausages,
              );

              controller.discardDrawnCard();

              expect(controller.plateOf(alice)[Category.main], fishFingers);
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
                drawPile: [water],
                discardPile: [milk],
                drawnCard: fishBone,
              );

              controller.discardDrawnCard();

              expect(controller.discardPile, [milk, fishBone]);
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

              expect(controller.discardPile, [fishBone]);
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
            },
          );

          test(
            'puts a food card taken from the discard pile back on it',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [milk],
                },
                drawPile: [fishFingers],
                discardPile: [sausages, water],
              );

              controller
                ..drawFromDiscardPile()
                ..discardDrawnCard();

              expect(controller.discardPile, [sausages, water]);
            },
          );

          test(
            'puts a spoiled card taken from the discard pile back on it',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [milk],
                },
                drawPile: [fishFingers],
                discardPile: [pondWater],
              );

              controller
                ..drawFromDiscardPile()
                ..discardDrawnCard();

              expect(controller.discardPile, [pondWater]);
            },
          );

          test(
            'no longer holds the drawn card',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [],
                drawnCard: sausages,
              );

              controller.discardDrawnCard();

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
            'throws for a food card if its slot is empty',
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
            },
          );

          test(
            'throws once a player has won',
            () {
              final controller = wonByAlice(drawnCard: sausages);

              expect(controller.discardDrawnCard, throwsStateError);
            },
          );

          group(
            'if it throws',
            () {
              /// Alice holds a food card whose slot is empty, so discarding
              /// it throws.
              GameController refused() => GameController(
                    players: [alice, bob],
                    plates: {
                      alice: [milk],
                    },
                    drawPile: [fishFingers],
                    drawnCard: sausages,
                  );

              test(
                'does not change the drawn card',
                () {
                  final controller = refused();

                  attempt(controller.discardDrawnCard);

                  expect(controller.drawnCard, sausages);
                },
              );

              test(
                "does not change the current player's plate",
                () {
                  final controller = refused();

                  attempt(controller.discardDrawnCard);

                  expect(controller.plateOf(alice), Plate([milk]));
                },
              );

              test(
                'does not change the discard pile',
                () {
                  final controller = refused();

                  attempt(controller.discardDrawnCard);

                  expect(controller.discardPile, isEmpty);
                },
              );

              test(
                "does not end the current player's turn",
                () {
                  final controller = refused();

                  attempt(controller.discardDrawnCard);

                  expect(controller.currentPlayer, alice);
                },
              );
            },
          );
        },
      );

      group(
        'refilling the draw pile',
        () {
          test(
            'shuffles every card under the top discard into the draw pile '
            'once a discard empties it',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [sausages],
                discardPile: [milk, water],
              );

              controller
                ..drawFromDrawPile()
                ..discardDrawnCard();

              expect(controller.drawPile, unorderedEquals([milk, water]));
            },
          );

          test(
            'leaves the discarded card face up on the discard pile',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [sausages],
                discardPile: [milk, water],
              );

              controller
                ..drawFromDrawPile()
                ..discardDrawnCard();

              expect(controller.discardPile, [sausages]);
            },
          );

          test(
            'leaves the replaced card face up once a placed card empties it',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishBone],
                },
                drawPile: [sausages],
                discardPile: [milk, water],
              );

              controller
                ..drawFromDrawPile()
                ..placeDrawnCard();

              expect(controller.drawPile, unorderedEquals([milk, water]));
              expect(controller.discardPile, [fishBone]);
            },
          );

          test(
            'leaves the top discard face up once a card is placed in an '
            'empty slot',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [sausages],
                discardPile: [milk, water],
              );

              controller
                ..drawFromDrawPile()
                ..placeDrawnCard();

              expect(controller.drawPile, [milk]);
              expect(controller.discardPile, [water]);
            },
          );

          test(
            'refills an empty draw pile at the end of a play from the '
            'discard pile',
            () {
              final controller = GameController(
                players: [alice, bob],
                drawPile: [],
                discardPile: [milk, water, sausages],
              );

              controller
                ..drawFromDiscardPile()
                ..placeDrawnCard();

              expect(controller.drawPile, [milk]);
              expect(controller.discardPile, [water]);
            },
          );

          test(
            'lets the next player draw from the refilled draw pile',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [sausages],
                discardPile: [milk, water],
              );

              controller
                ..drawFromDrawPile()
                ..discardDrawnCard();

              expect(controller.canDrawFromDrawPile, isTrue);
            },
          );

          test(
            'does not refill while the discard pile has only one card',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [sausages],
              );

              controller
                ..drawFromDrawPile()
                ..discardDrawnCard();

              expect(controller.drawPile, isEmpty);
              expect(controller.discardPile, [sausages]);
            },
          );

          test(
            'gives the next player only the discard pile to draw from while '
            'it has only one card',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [sausages],
              );

              controller
                ..drawFromDrawPile()
                ..discardDrawnCard();

              expect(controller.canDrawFromDrawPile, isFalse);
              expect(controller.canDrawFromDiscardPile, isTrue);
            },
          );

          test(
            'does not refill while the draw pile has cards',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [milk, sausages],
                discardPile: [water, jelly],
              );

              controller
                ..drawFromDrawPile()
                ..discardDrawnCard();

              expect(controller.drawPile, [milk]);
              expect(controller.discardPile, [water, jelly, sausages]);
            },
          );

          test(
            'does not refill once the game is over',
            () {
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [...allButMain],
                },
                drawPile: [sausages],
                discardPile: [water, peas],
              );

              controller
                ..drawFromDrawPile()
                ..placeDrawnCard();

              expect(controller.drawPile, isEmpty);
              expect(controller.discardPile, [water, peas]);
            },
          );

          test(
            'shuffles with the given random',
            () {
              final deck = buildDeck();
              final controller = GameController(
                players: [alice, bob],
                plates: {
                  alice: [fishFingers],
                },
                drawPile: [],
                discardPile: deck,
                drawnCard: sausages,
                random: Random(42),
              );

              controller.discardDrawnCard();

              final expected = List.of(deck);
              shuffle(expected, Random(42));

              expect(controller.drawPile, expected);
              expect(controller.discardPile, [sausages]);
            },
          );

          test(
            'shares the random from start',
            () {
              final controller = GameController.start(
                [alice, bob],
                random: Random(42),
              );

              // Whether anyone completes a meal before the draw pile first
              // runs out, and whether the discard pile then has enough
              // cards to refill it, depends on the seed. Random(42) happens
              // to refill it, which is checked so that a changed seed or
              // deck fails clearly.
              late final List<Card> refilled;

              while (true) {
                controller.drawFromDrawPile();

                final emptied = controller.drawPile.isEmpty;
                final discarding = controller.canDiscardDrawnCard;
                final discarded = List.of(controller.discardPile);

                if (discarding) {
                  controller.discardDrawnCard();
                } else {
                  controller.placeDrawnCard();
                }

                if (controller.isGameOver) {
                  fail('The seed must not let anyone win before a refill');
                }

                if (emptied) {
                  if (controller.drawPile.isEmpty) {
                    fail('The seed must refill the draw pile when it runs out');
                  }

                  // A discarded card goes on top, so every card that was
                  // already discarded is under it. Otherwise, the top card
                  // stays where it was.
                  refilled = discarding
                      ? discarded
                      : discarded.sublist(0, discarded.length - 1);
                  break;
                }
              }

              // The deal and the refill draw from the same Random, so
              // replay both with a fresh Random(42).
              final random = Random(42);
              shuffle(buildDeck(), random);
              final expected = refilled;
              shuffle(expected, random);

              expect(controller.drawPile, expected);
            },
          );
        },
      );
    },
  );
}
