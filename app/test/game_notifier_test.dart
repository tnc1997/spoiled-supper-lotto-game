import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart';
import 'package:spoiled_supper_lotto_game/game_notifier.dart';

void main() {
  group(
    'GameNotifier',
    () {
      const sausages = Card(
        id: '1',
        type: CardType.standard,
        category: Category.main,
        name: 'Sausages',
      );
      const fishFingers = Card(
        id: '2',
        type: CardType.standard,
        category: Category.main,
        name: 'Fish Fingers',
      );
      const milk = Card(
        id: '3',
        type: CardType.standard,
        category: Category.drink,
        name: 'Milk',
      );
      const pie = Card(
        id: '4',
        type: CardType.standard,
        category: Category.main,
        name: 'Pie',
      );

      late Player alice;
      late GameController controller;
      late GameNotifier notifier;
      late List<String> notifications;

      /// Sets up a game for Alice and Bob, with [alicesCards] already on
      /// Alice's plate, and a notifier that records each notification.
      void setUpGame({List<Card> alicesCards = const []}) {
        alice = Player(name: 'Alice');
        controller = GameController(
          players: [alice, Player(name: 'Bob')],
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
        'placeDrawnCard',
        () {
          test(
            'places the drawn card, then notifies listeners once',
            () {
              notifier.drawFromDrawPile();
              notifications.clear();

              notifier.placeDrawnCard();

              expect(controller.plateOf(alice)[Category.main], sausages);
              expect(notifications, ['Bob: null']);
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
          expect(controller.drawnCard, sausages);
          expect(controller.drawPile, [milk]);
          expect(controller.discardPile, [fishFingers]);
          expect(controller.currentPlayerIndex, 0);
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
