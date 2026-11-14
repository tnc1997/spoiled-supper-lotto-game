import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart';
import 'package:spoiled_supper_lotto_game/game_scope.dart';

void main() {
  group(
    'GameScope',
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

      late GameController controller;
      late int builds;
      late GameController? found;
      late Widget dependent;

      setUp(
        () {
          controller = GameController(
            players: [Player(name: 'Alice'), Player(name: 'Bob')],
            drawPile: [milk, sausages],
          );
          builds = 0;
          found = null;
          dependent = Builder(
            builder: (context) {
              builds++;
              final game = found = GameScope.of(context);

              return Text(
                '${game.currentPlayer.name}: ${game.drawnCard?.name}',
                textDirection: TextDirection.ltr,
              );
            },
          );
        },
      );

      /// Pumps a [GameScope] for [controller] above a dependent that counts
      /// its builds, records the game it finds and shows the current player
      /// and their drawn card.
      ///
      /// The dependent is the same widget on every pump, so it only
      /// rebuilds when the scope notifies it.
      Future<void> pumpScope(
        WidgetTester tester,
        GameController controller,
      ) {
        return tester.pumpWidget(
          GameScope(controller: controller, child: dependent),
        );
      }

      group(
        'of',
        () {
          testWidgets(
            'returns the controller of the closest GameScope',
            (tester) async {
              final outer = GameController(
                players: [Player(name: 'Carol'), Player(name: 'Dave')],
                drawPile: [milk],
              );

              await tester.pumpWidget(
                GameScope(
                  controller: outer,
                  child: GameScope(controller: controller, child: dependent),
                ),
              );

              expect(found, same(controller));
              expect(find.text('Alice: null'), findsOneWidget);
            },
          );

          testWidgets(
            'throws if there is no GameScope above the context',
            (tester) async {
              late Object error;

              await tester.pumpWidget(
                Builder(
                  builder: (context) {
                    try {
                      GameScope.of(context);
                    } catch (e) {
                      error = e;
                    }

                    return const SizedBox();
                  },
                ),
              );

              expect(error, isA<FlutterError>());
            },
          );
        },
      );

      group(
        'maybeOf',
        () {
          testWidgets(
            'returns null if there is no GameScope above the context',
            (tester) async {
              var called = false;
              GameController? controller;

              await tester.pumpWidget(
                Builder(
                  builder: (context) {
                    called = true;
                    controller = GameScope.maybeOf(context);

                    return const SizedBox();
                  },
                ),
              );

              expect(called, isTrue);
              expect(controller, isNull);
            },
          );
        },
      );

      testWidgets(
        'rebuilds dependents once after each move',
        (tester) async {
          await pumpScope(tester, controller);

          controller.drawFromDrawPile();
          await tester.pump();

          expect(find.text('Alice: Sausages'), findsOneWidget);
          expect(builds, 2);

          controller.placeDrawnCard();
          await tester.pump();

          expect(find.text('Bob: null'), findsOneWidget);
          expect(builds, 3);
        },
      );

      testWidgets(
        'rebuilds dependents when a card is placed directly on a plate',
        (tester) async {
          await pumpScope(tester, controller);

          controller.players[1].plate.place(milk);
          await tester.pump();

          expect(builds, 2);
        },
      );

      testWidgets(
        'does not rebuild dependents if a move throws',
        (tester) async {
          await pumpScope(tester, controller);

          expect(controller.placeDrawnCard, throwsStateError);
          await tester.pump();

          expect(builds, 1);
        },
      );

      testWidgets(
        'does not rebuild dependents if rebuilt with the same controller',
        (tester) async {
          await pumpScope(tester, controller);
          await pumpScope(tester, controller);

          expect(builds, 1);
        },
      );

      testWidgets(
        'rebuilds dependents with a new controller',
        (tester) async {
          await pumpScope(tester, controller);
          final newController = GameController(
            players: [Player(name: 'Carol'), Player(name: 'Dave')],
            drawPile: [milk],
          );

          await pumpScope(tester, newController);

          expect(found, same(newController));
          expect(find.text('Carol: null'), findsOneWidget);
          expect(builds, 2);
        },
      );

      testWidgets(
        'stops listening to the old controller once replaced',
        (tester) async {
          await pumpScope(tester, controller);
          await pumpScope(
            tester,
            GameController(
              players: [Player(name: 'Carol'), Player(name: 'Dave')],
              drawPile: [milk],
            ),
          );

          controller.drawFromDrawPile();
          await tester.pump();

          expect(builds, 2);
        },
      );

      testWidgets(
        'stops listening to the controller once removed from the tree',
        (tester) async {
          await pumpScope(tester, controller);
          await tester.pumpWidget(const SizedBox());

          expect(controller.drawFromDrawPile, returnsNormally);
          await tester.pump();

          expect(builds, 1);
        },
      );
    },
  );
}
