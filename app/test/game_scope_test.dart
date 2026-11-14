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
      late int builds;
      late Widget dependent;

      setUp(
        () {
          controller = GameController(
            players: [Player(name: 'Alice'), Player(name: 'Bob')],
            drawPile: [milk, sausages],
            discardPile: [fishFingers],
          );
          builds = 0;
          dependent = Builder(
            builder: (context) {
              builds++;
              final game = GameScope.of(context).controller;

              return Text(
                '${game.currentPlayer.name}: ${game.drawnCard?.name}',
                textDirection: TextDirection.ltr,
              );
            },
          );
        },
      );

      /// Pumps a [GameScope] for [controller] above a dependent that counts
      /// its builds and shows the current player and their drawn card.
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

      GameScopeState stateOf(WidgetTester tester) {
        return tester.state<GameScopeState>(find.byType(GameScope));
      }

      group(
        'of',
        () {
          testWidgets(
            'returns the state exposing the controller',
            (tester) async {
              await pumpScope(tester, controller);

              expect(stateOf(tester).controller, same(controller));
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
              GameScopeState? state;

              await tester.pumpWidget(
                Builder(
                  builder: (context) {
                    called = true;
                    state = GameScope.maybeOf(context);

                    return const SizedBox();
                  },
                ),
              );

              expect(called, isTrue);
              expect(state, isNull);
            },
          );
        },
      );

      group(
        'drawFromDrawPile',
        () {
          testWidgets(
            'draws the top card and rebuilds dependents',
            (tester) async {
              await pumpScope(tester, controller);

              stateOf(tester).drawFromDrawPile();
              await tester.pump();

              expect(controller.drawnCard, sausages);
              expect(find.text('Alice: Sausages'), findsOneWidget);
              expect(builds, 2);
            },
          );
        },
      );

      group(
        'drawFromDiscardPile',
        () {
          testWidgets(
            'draws the top discarded card and rebuilds dependents',
            (tester) async {
              await pumpScope(tester, controller);

              stateOf(tester).drawFromDiscardPile();
              await tester.pump();

              expect(controller.drawnCard, fishFingers);
              expect(find.text('Alice: Fish Fingers'), findsOneWidget);
              expect(builds, 2);
            },
          );
        },
      );

      group(
        'placeDrawnCard',
        () {
          testWidgets(
            'places the drawn card and rebuilds dependents',
            (tester) async {
              await pumpScope(tester, controller);
              final state = stateOf(tester);

              state.drawFromDrawPile();
              await tester.pump();
              state.placeDrawnCard();
              await tester.pump();

              expect(controller.players[0].plate[Category.main], sausages);
              expect(find.text('Bob: null'), findsOneWidget);
              expect(builds, 3);
            },
          );
        },
      );

      group(
        'discardDrawnCard',
        () {
          testWidgets(
            'discards the drawn card and rebuilds dependents',
            (tester) async {
              controller.players[0].plate.place(fishFingers);
              await pumpScope(tester, controller);
              final state = stateOf(tester);

              state.drawFromDrawPile();
              await tester.pump();
              state.discardDrawnCard();
              await tester.pump();

              expect(controller.discardPile.last, sausages);
              expect(find.text('Bob: null'), findsOneWidget);
              expect(builds, 3);
            },
          );
        },
      );

      testWidgets(
        'does not rebuild dependents if a move throws',
        (tester) async {
          await pumpScope(tester, controller);

          expect(() => stateOf(tester).placeDrawnCard(), throwsStateError);
          await tester.pump();

          expect(find.text('Alice: null'), findsOneWidget);
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

          expect(stateOf(tester).controller, same(newController));
          expect(find.text('Carol: null'), findsOneWidget);
          expect(builds, 2);
        },
      );
    },
  );
}
