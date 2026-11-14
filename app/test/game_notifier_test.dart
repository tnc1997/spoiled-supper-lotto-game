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

      late GameController controller;
      late GameNotifier notifier;
      late List<String> notifications;

      setUp(
        () {
          controller = GameController(
            players: [Player(name: 'Alice'), Player(name: 'Bob')],
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
        },
      );

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

              expect(controller.players[0].plate[Category.main], sausages);
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
              controller.players[0].plate.place(fishFingers);
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
