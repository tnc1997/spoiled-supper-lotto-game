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

      /// Returns the text of each line of the log, newest first.
      List<String?> linesOf(WidgetTester tester) {
        return tester
            .widgetList<Text>(find.byType(Text))
            .map((text) => text.data)
            .toList();
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

          expect(
            linesOf(tester),
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
        'keeps a long card played to one line, announcing it in full',
        (tester) async {
          tester.view
            ..physicalSize = const Size(200, 600)
            ..devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final notifier = GameNotifier(
            engine.GameController(
              players: [
                engine.Player(name: 'Alexandra Montgomery'),
                engine.Player(name: 'Bob'),
              ],
              drawPile: [cards[1], cards[0]],
            ),
          );
          addTearDown(notifier.dispose);
          await pumpLog(tester, notifier);
          // Played before Bob's card, so that it isn't the newest, which
          // is left out of the semantics tree.
          const line = 'Alexandra Montgomery placed Sausages';

          placeCards(notifier, 2);
          await tester.pump();

          expect(
            tester.getSize(find.text(line)).height,
            tester.getSize(find.text('Bob placed Milk')).height,
          );
          expect(
            tester.getSemantics(find.text(line)),
            matchesSemantics(label: line),
          );
        },
      );

      testWidgets(
        'leaves the newest card played out of the semantics tree',
        (tester) async {
          final handle = tester.ensureSemantics();
          final notifier = newNotifier();
          placeCards(notifier, 2);

          await pumpLog(tester, notifier);

          expect(find.semantics.byLabel('Bob placed Milk'), findsNothing);
          expect(
            find.semantics.byLabel('Alice placed Sausages'),
            findsOneWidget,
          );
          handle.dispose();
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
