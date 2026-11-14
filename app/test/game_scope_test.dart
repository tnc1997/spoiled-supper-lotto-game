import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart';
import 'package:spoiled_supper_lotto_game/game_notifier.dart';
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

      late GameNotifier notifier;
      late int builds;
      late GameNotifier? found;
      late Widget dependent;

      /// Creates a notifier for a new game between [names], disposing of it
      /// once the test has finished.
      GameNotifier notifierFor(List<String> names) {
        final notifier = GameNotifier(
          GameController(
            players: [for (final name in names) Player(name: name)],
            drawPile: [milk, sausages],
          ),
        );
        addTearDown(notifier.dispose);

        return notifier;
      }

      setUp(
        () {
          notifier = notifierFor(['Alice', 'Bob']);
          builds = 0;
          found = null;
          dependent = Builder(
            builder: (context) {
              builds++;
              final game = (found = GameScope.of(context)).controller;

              return Text(
                '${game.currentPlayer.name}: ${game.drawnCard?.name}',
                textDirection: TextDirection.ltr,
              );
            },
          );
        },
      );

      /// Pumps a [GameScope] for [notifier] above a dependent that counts
      /// its builds, records the notifier it finds and shows the current
      /// player and their drawn card.
      ///
      /// The dependent is the same widget on every pump, so it only
      /// rebuilds when the scope notifies it.
      Future<void> pumpScope(WidgetTester tester, GameNotifier notifier) {
        return tester.pumpWidget(
          GameScope(notifier: notifier, child: dependent),
        );
      }

      group(
        'of',
        () {
          testWidgets(
            'returns the notifier of the closest GameScope',
            (tester) async {
              await tester.pumpWidget(
                GameScope(
                  notifier: notifierFor(['Carol', 'Dave']),
                  child: GameScope(notifier: notifier, child: dependent),
                ),
              );

              expect(found, same(notifier));
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
              GameNotifier? notifier;

              await tester.pumpWidget(
                Builder(
                  builder: (context) {
                    called = true;
                    notifier = GameScope.maybeOf(context);

                    return const SizedBox();
                  },
                ),
              );

              expect(called, isTrue);
              expect(notifier, isNull);
            },
          );
        },
      );

      testWidgets(
        'rebuilds dependents once after each move',
        (tester) async {
          await pumpScope(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pump();

          expect(find.text('Alice: Sausages'), findsOneWidget);
          expect(builds, 2);

          notifier.placeDrawnCard();
          await tester.pump();

          expect(find.text('Bob: null'), findsOneWidget);
          expect(builds, 3);
        },
      );

      testWidgets(
        'does not rebuild dependents if rebuilt with the same notifier',
        (tester) async {
          await pumpScope(tester, notifier);
          await pumpScope(tester, notifier);

          expect(builds, 1);
        },
      );

      testWidgets(
        'rebuilds dependents with a new notifier',
        (tester) async {
          await pumpScope(tester, notifier);
          final newNotifier = notifierFor(['Carol', 'Dave']);

          await pumpScope(tester, newNotifier);

          expect(found, same(newNotifier));
          expect(find.text('Carol: null'), findsOneWidget);
          expect(builds, 2);
        },
      );

      testWidgets(
        'stops listening to the old notifier once replaced',
        (tester) async {
          await pumpScope(tester, notifier);
          await pumpScope(tester, notifierFor(['Carol', 'Dave']));

          notifier.drawFromDrawPile();
          await tester.pump();

          expect(builds, 2);
        },
      );
    },
  );
}
