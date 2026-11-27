import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/action_log.dart';
import 'package:spoiled_supper_lotto_game/game_notifier.dart';
import 'package:spoiled_supper_lotto_game/game_scope.dart';

void main() {
  group(
    'ActionLog',
    () {
      const cards = [
        engine.Card(
          id: '1',
          type: engine.CardType.standard,
          category: engine.Category.main,
          name: 'Sausages',
        ),
        engine.Card(
          id: '2',
          type: engine.CardType.standard,
          category: engine.Category.drink,
          name: 'Milk',
        ),
        engine.Card(
          id: '3',
          type: engine.CardType.standard,
          category: engine.Category.dessert,
          name: 'Jelly',
        ),
        engine.Card(
          id: '4',
          type: engine.CardType.standard,
          category: engine.Category.vegetable,
          name: 'Peas',
        ),
      ];

      const bodyMedium = TextStyle(fontFamily: 'Fredoka');

      /// Returns a notifier for a game between Alice and Bob, with [cards]
      /// to draw, the first on top, disposed of after the test.
      GameNotifier newNotifier() {
        final notifier = GameNotifier(
          engine.GameController(
            players: [
              engine.Player(name: 'Alice'),
              engine.Player(name: 'Bob'),
            ],
            drawPile: cards.reversed.toList(),
          ),
        );
        addTearDown(notifier.dispose);

        return notifier;
      }

      /// Draws and places [count] cards in turn.
      void placeCards(GameNotifier notifier, int count) {
        for (var i = 0; i < count; i++) {
          notifier
            ..drawFromDrawPile()
            ..placeDrawnCard();
        }
      }

      /// Shows the action log of the game of [notifier], with a text theme
      /// whose `bodyMedium` style is [bodyMedium].
      Future<void> pumpLog(WidgetTester tester, GameNotifier notifier) {
        return tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              textTheme: const TextTheme(bodyMedium: bodyMedium),
            ),
            home: GameScope(
              notifier: notifier,
              child: const Center(child: ActionLog()),
            ),
          ),
        );
      }

      testWidgets(
        'shows the most recent cards played, newest first',
        (tester) async {
          final notifier = newNotifier();
          placeCards(notifier, 4);

          await pumpLog(tester, notifier);

          final lines = tester
              .widgetList<Text>(find.byType(Text))
              .map((text) => text.data)
              .toList();

          expect(
            lines,
            ['Bob placed Peas', 'Alice placed Jelly', 'Bob placed Milk'],
          );
        },
      );

      testWidgets(
        'shows each card as it is played',
        (tester) async {
          final notifier = newNotifier();
          await pumpLog(tester, notifier);

          placeCards(notifier, 1);
          await tester.pump();

          expect(find.text('Alice placed Sausages'), findsOneWidget);
        },
      );

      testWidgets(
        'keeps its space before any cards have been played',
        (tester) async {
          final notifier = newNotifier();
          await pumpLog(tester, notifier);
          final empty = tester.getSize(find.byType(ActionLog));

          placeCards(notifier, ActionLog.length);
          await tester.pump();

          expect(tester.getSize(find.byType(ActionLog)).height, empty.height);
        },
      );

      testWidgets(
        'shows the cards played in the bodyMedium text style',
        (tester) async {
          final notifier = newNotifier();
          placeCards(notifier, 1);

          await pumpLog(tester, notifier);

          final text = tester.widget<Text>(find.text('Alice placed Sausages'));

          expect(text.style?.fontFamily, 'Fredoka');
        },
      );
    },
  );
}
