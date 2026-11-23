import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/drawn_card_actions.dart';
import 'package:spoiled_supper_lotto_game/game_notifier.dart';
import 'package:spoiled_supper_lotto_game/game_scope.dart';

void main() {
  group(
    'DrawnCardActions',
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
      const peas = engine.Card(
        id: '4',
        type: engine.CardType.standard,
        category: engine.Category.vegetable,
        name: 'Peas',
      );

      late engine.Player alice;

      setUp(() => alice = engine.Player(name: 'Alice'));

      /// Returns a notifier for a game between Alice, with [plate] on her
      /// plate, and Bob, in which Alice is about to draw [drawn] from the
      /// draw pile, disposed of after the test.
      GameNotifier notifierWith({
        required engine.Card drawn,
        List<engine.Card> plate = const [],
      }) {
        final notifier = GameNotifier(
          engine.GameController(
            players: [alice, engine.Player(name: 'Bob')],
            plates: {alice: plate},
            drawPile: [peas, drawn],
          ),
        );
        addTearDown(notifier.dispose);

        return notifier;
      }

      /// Shows the drawn card's actions in the game of [notifier].
      Future<void> pumpActions(WidgetTester tester, GameNotifier notifier) {
        return tester.pumpWidget(
          MaterialApp(
            home: GameScope(
              notifier: notifier,
              child: const Center(child: DrawnCardActions()),
            ),
          ),
        );
      }

      testWidgets(
        'shows once a card is drawn, if the player has a choice',
        (tester) async {
          final notifier = notifierWith(
            drawn: sausages,
            plate: [fishFingers],
          );
          await pumpActions(tester, notifier);

          expect(find.text('Place').hitTestable(), findsNothing);
          expect(find.text('Discard').hitTestable(), findsNothing);

          notifier.drawFromDrawPile();
          await tester.pump();

          expect(find.text('Place').hitTestable(), findsOneWidget);
          expect(find.text('Discard').hitTestable(), findsOneWidget);
        },
      );

      testWidgets(
        'stays hidden if the player has no choice',
        (tester) async {
          final notifier = notifierWith(drawn: sausages);
          await pumpActions(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pump();

          expect(find.text('Place').hitTestable(), findsNothing);
          expect(find.text('Discard').hitTestable(), findsNothing);
        },
      );

      testWidgets(
        'starts placing the card, and hides, when Place is tapped',
        (tester) async {
          final notifier = notifierWith(
            drawn: sausages,
            plate: [fishFingers],
          );
          await pumpActions(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pump();
          await tester.tap(find.text('Place').hitTestable());
          await tester.pump();

          expect(notifier.isPlacingDrawnCard, isTrue);
          expect(notifier.game.drawnCard, sausages);
          expect(find.text('Place').hitTestable(), findsNothing);
          expect(find.text('Discard').hitTestable(), findsNothing);
        },
      );

      testWidgets(
        'discards the card when Discard is tapped',
        (tester) async {
          final notifier = notifierWith(
            drawn: sausages,
            plate: [fishFingers],
          );
          await pumpActions(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pump();
          await tester.tap(find.text('Discard').hitTestable());
          await tester.pump();

          expect(
            notifier.game.plateOf(alice)[engine.Category.main],
            fishFingers,
          );
          expect(notifier.game.discardPile, [sausages]);
          expect(find.text('Discard').hitTestable(), findsNothing);
        },
      );

      testWidgets(
        'keeps its space while hidden',
        (tester) async {
          final notifier = notifierWith(
            drawn: sausages,
            plate: [fishFingers],
          );
          await pumpActions(tester, notifier);

          final hiddenSize = tester.getSize(find.byType(DrawnCardActions));

          notifier.drawFromDrawPile();
          await tester.pump();

          expect(find.text('Place').hitTestable(), findsOneWidget);
          expect(tester.getSize(find.byType(DrawnCardActions)), hiddenSize);
        },
      );

      testWidgets(
        'disables the actions while they are hidden',
        (tester) async {
          await pumpActions(tester, notifierWith(drawn: sausages));

          expect(
            tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
            isNull,
          );
          expect(
            tester
                .widget<OutlinedButton>(find.byType(OutlinedButton))
                .onPressed,
            isNull,
          );
        },
      );
    },
  );
}
