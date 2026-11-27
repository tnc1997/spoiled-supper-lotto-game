import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:spoiled_supper_lotto_game/game_notifier.dart';

void main() {
  group(
    'GameNotifier',
    () {
      const sausages = engine.Card(
        id: '1',
        type: engine.CardType.standard,
        category: engine.Category.main,
        name: 'Sausages',
      );
      const fishFingers = engine.Card(
        id: '2',
        type: engine.CardType.standard,
        category: engine.Category.main,
        name: 'Fish Fingers',
      );
      const milk = engine.Card(
        id: '3',
        type: engine.CardType.standard,
        category: engine.Category.drink,
        name: 'Milk',
      );
      const pie = engine.Card(
        id: '4',
        type: engine.CardType.standard,
        category: engine.Category.main,
        name: 'Pie',
      );

      late engine.Player alice;
      late engine.GameController controller;
      late GameNotifier notifier;
      late List<String> notifications;

      /// Sets up a game for Alice and Bob, with [alicesCards] already on
      /// Alice's plate, and a notifier that records each notification.
      void setUpGame({List<engine.Card> alicesCards = const []}) {
        alice = engine.Player(name: 'Alice');
        controller = engine.GameController(
          players: [alice, engine.Player(name: 'Bob')],
          plates: {alice: alicesCards},
          drawPile: [milk, sausages],
          discardPile: [fishFingers],
        );
        notifier = GameNotifier(controller);
        addTearDown(notifier.dispose);
        notifications = [];
        notifier.addListener(
          () => notifications.add(
            '${controller.currentPlayer.name}: '
            '${controller.drawnCard?.name}',
          ),
        );
      }

      setUp(setUpGame);

      test(
        'exposes the controller it was given as a read-only game',
        () {
          expect(notifier.game, same(controller));
        },
      );

      group(
        'drawFromDrawPile',
        () {
          test(
            'draws the top card, then notifies listeners once',
            () {
              notifier.drawFromDrawPile();

              expect(notifications, ['Alice: Sausages']);
            },
          );
        },
      );

      group(
        'drawFromDiscardPile',
        () {
          test(
            'draws the top discarded card, then notifies listeners once',
            () {
              notifier.drawFromDiscardPile();

              expect(notifications, ['Alice: Fish Fingers']);
            },
          );
        },
      );

      group(
        'startPlayingDrawnCard',
        () {
          test(
            'starts placing the drawn card, without placing it, then '
            'notifies listeners once',
            () {
              notifier.drawFromDrawPile();
              notifications.clear();

              notifier.startPlayingDrawnCard(DrawnCardPlay.place);

              expect(notifier.drawnCardPlay, DrawnCardPlay.place);
              expect(controller.drawnCard, sausages);
              expect(controller.plateOf(alice)[engine.Category.main], isNull);
              expect(notifications, ['Alice: Sausages']);
            },
          );

          test(
            'starts discarding the drawn card, without discarding it, then '
            'notifies listeners once',
            () {
              setUpGame(alicesCards: [pie]);
              notifier.drawFromDrawPile();
              notifications.clear();

              notifier.startPlayingDrawnCard(DrawnCardPlay.discard);

              expect(notifier.drawnCardPlay, DrawnCardPlay.discard);
              expect(controller.drawnCard, sausages);
              expect(controller.discardPile, [fishFingers]);
              expect(notifications, ['Alice: Sausages']);
            },
          );

          test(
            'does nothing once the drawn card is being played',
            () {
              setUpGame(alicesCards: [pie]);
              notifier
                ..drawFromDrawPile()
                ..startPlayingDrawnCard(DrawnCardPlay.place);
              notifications.clear();

              notifier.startPlayingDrawnCard(DrawnCardPlay.discard);

              expect(notifier.drawnCardPlay, DrawnCardPlay.place);
              expect(notifications, isEmpty);
            },
          );

          test(
            'stops playing the drawn card once it has been played',
            () {
              notifier
                ..drawFromDrawPile()
                ..startPlayingDrawnCard(DrawnCardPlay.place)
                ..placeDrawnCard();

              expect(notifier.drawnCardPlay, isNull);
            },
          );

          test(
            'throws without notifying listeners if the drawn card cannot be '
            'placed',
            () {
              expect(
                () => notifier.startPlayingDrawnCard(DrawnCardPlay.place),
                throwsStateError,
              );
              expect(notifier.drawnCardPlay, isNull);
              expect(notifications, isEmpty);
            },
          );

          test(
            'throws without notifying listeners if the drawn card cannot be '
            'discarded',
            () {
              notifier.drawFromDrawPile();
              notifications.clear();

              expect(
                () => notifier.startPlayingDrawnCard(DrawnCardPlay.discard),
                throwsStateError,
              );
              expect(notifier.drawnCardPlay, isNull);
              expect(notifications, isEmpty);
            },
          );
        },
      );

      group(
        'placeDrawnCard',
        () {
          test(
            'places the drawn card, then notifies listeners once',
            () {
              notifier.drawFromDrawPile();
              notifications.clear();

              notifier.placeDrawnCard();

              expect(controller.plateOf(alice)[engine.Category.main], sausages);
              expect(notifications, ['Bob: null']);
            },
          );

          test(
            'adds the card to the cards played',
            () {
              notifier
                ..drawFromDrawPile()
                ..placeDrawnCard();

              expect(
                [
                  for (final playedCard in notifier.playedCards)
                    (playedCard.player, playedCard.card, playedCard.play),
                ],
                [(alice, sausages, DrawnCardPlay.place)],
              );
            },
          );
        },
      );

      group(
        'discardDrawnCard',
        () {
          test(
            'discards the drawn card, then notifies listeners once',
            () {
              setUpGame(alicesCards: [pie]);
              notifier.drawFromDrawPile();
              notifications.clear();

              notifier.discardDrawnCard();

              expect(controller.discardPile.last, sausages);
              expect(notifications, ['Bob: null']);
            },
          );

          test(
            'adds the card to the cards played',
            () {
              setUpGame(alicesCards: [pie]);
              notifier
                ..drawFromDrawPile()
                ..discardDrawnCard();

              expect(
                [
                  for (final playedCard in notifier.playedCards)
                    (playedCard.player, playedCard.card, playedCard.play),
                ],
                [(alice, sausages, DrawnCardPlay.discard)],
              );
            },
          );
        },
      );

      test(
        'does not notify listeners or change the game if a move throws',
        () {
          notifier.drawFromDrawPile();
          notifications.clear();

          expect(notifier.drawFromDrawPile, throwsStateError);
          expect(notifier.drawFromDiscardPile, throwsStateError);
          expect(notifier.discardDrawnCard, throwsStateError);

          expect(notifications, isEmpty);
          expect(notifier.playedCards, isEmpty);
          expect(controller.drawnCard, sausages);
          expect(controller.drawPile, [milk]);
          expect(controller.discardPile, [fishFingers]);
          expect(controller.currentPlayerIndex, 0);
        },
      );

      test(
        'starts with no cards played',
        () {
          expect(notifier.playedCards, isEmpty);
        },
      );

      test(
        'throws before making a move once disposed',
        () {
          final notifier = GameNotifier(controller)..dispose();

          expect(notifier.drawFromDrawPile, throwsStateError);
          expect(controller.drawnCard, isNull);
          expect(controller.drawPile, [milk, sausages]);
        },
      );
    },
  );
}
