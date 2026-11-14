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
        'exposes the controller it was given',
        () {
          expect(notifier.controller, same(controller));
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
        'does not notify listeners if a move throws',
        () {
          expect(notifier.placeDrawnCard, throwsStateError);
          expect(notifications, isEmpty);
        },
      );

      test(
        'asserts before making a move once disposed',
        () {
          notifier.dispose();

          expect(notifier.drawFromDrawPile, throwsFlutterError);
          expect(controller.drawnCard, isNull);
          expect(controller.drawPile, [milk, sausages]);
        },
      );
    },
  );
}
