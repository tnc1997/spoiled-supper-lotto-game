import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Card;
import 'package:spoiled_supper_lotto_game/card.dart';
import 'package:spoiled_supper_lotto_game/card_back.dart';
import 'package:spoiled_supper_lotto_game/drawn_card.dart';
import 'package:spoiled_supper_lotto_game/game_notifier.dart';
import 'package:spoiled_supper_lotto_game/game_scope.dart';

void main() {
  group(
    'DrawnCard',
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
      const fishBone = engine.Card(
        id: '3',
        type: engine.CardType.spoiled,
        category: engine.Category.main,
        name: 'Fish Bone',
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

      /// Shows the drawn card of the game of [notifier].
      Future<void> pumpDrawnCard(
        WidgetTester tester,
        GameNotifier notifier, {
        bool disableAnimations = false,
      }) {
        return tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: disableAnimations),
              child: GameScope(
                notifier: notifier,
                child: const Center(child: DrawnCard()),
              ),
            ),
          ),
        );
      }

      testWidgets(
        'shows no card until one is drawn',
        (tester) async {
          await pumpDrawnCard(tester, notifierWith(drawn: sausages));

          expect(find.byType(Card), findsNothing);
          expect(find.byType(CardBack), findsNothing);
        },
      );

      testWidgets(
        'turns the drawn card face up',
        (tester) async {
          final notifier = notifierWith(
            drawn: sausages,
            plate: [fishFingers],
          );
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pump();

          expect(find.byType(CardBack), findsOneWidget);
          expect(find.byType(Card), findsNothing);

          await tester.pump(DrawnCard.flipDuration);

          expect(find.byType(CardBack), findsNothing);
          expect(tester.widget<Card>(find.byType(Card)).card, sausages);
        },
      );

      testWidgets(
        'announces the drawn card once it is face up',
        (tester) async {
          final notifier = notifierWith(
            drawn: sausages,
            plate: [fishFingers],
          );
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pump();

          expect(
            find.bySemanticsLabel('Drawn card'),
            findsOneWidget,
          );

          await tester.pump(DrawnCard.flipDuration);

          expect(
            tester.getSemantics(
              find.bySemanticsLabel('Drawn card, Sausages, Main'),
            ),
            isSemantics(isLiveRegion: true),
          );
        },
      );

      testWidgets(
        'shows the drawn card face up straight away if animations are '
        'disabled',
        (tester) async {
          final notifier = notifierWith(
            drawn: sausages,
            plate: [fishFingers],
          );
          await pumpDrawnCard(tester, notifier, disableAnimations: true);

          notifier.drawFromDrawPile();
          await tester.pump();

          expect(find.byType(CardBack), findsNothing);
          expect(find.byType(Card), findsOneWidget);
        },
      );

      testWidgets(
        'holds a card the player has no choice about only for a moment if '
        'animations are disabled',
        (tester) async {
          final notifier = notifierWith(drawn: sausages);
          await pumpDrawnCard(tester, notifier, disableAnimations: true);

          notifier.drawFromDrawPile();
          await tester.pump();
          await tester.pump(DrawnCard.holdDuration);
          await tester.pump(const Duration(milliseconds: 1));

          expect(notifier.game.drawnCard, isNull);
        },
      );

      testWidgets(
        'places a card whose slot is empty once it has been face up for a '
        'moment',
        (tester) async {
          final notifier = notifierWith(drawn: sausages);
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pump();
          await tester.pump(DrawnCard.flipDuration);

          expect(notifier.game.drawnCard, sausages);

          await tester.pumpAndSettle();

          expect(notifier.game.drawnCard, isNull);
          expect(notifier.game.plateOf(alice)[engine.Category.main], sausages);
          expect(find.byType(Card), findsNothing);
        },
      );

      testWidgets(
        'discards a spoiled card whose slot is filled once it has been face '
        'up for a moment',
        (tester) async {
          final notifier = notifierWith(
            drawn: fishBone,
            plate: [fishFingers],
          );
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pumpAndSettle();

          expect(notifier.game.drawnCard, isNull);
          expect(notifier.game.discardPile, [fishBone]);
          expect(
            notifier.game.plateOf(alice)[engine.Category.main],
            fishFingers,
          );
        },
      );

      testWidgets(
        'waits for the player to choose for a standard card whose slot is '
        'filled',
        (tester) async {
          final notifier = notifierWith(
            drawn: sausages,
            plate: [fishFingers],
          );
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pumpAndSettle();

          expect(notifier.game.drawnCard, sausages);
          expect(tester.widget<Card>(find.byType(Card)).card, sausages);
        },
      );

      testWidgets(
        'keeps its space on the table while no card is drawn',
        (tester) async {
          final notifier = notifierWith(drawn: sausages);
          await pumpDrawnCard(tester, notifier);

          final emptySize = tester.getSize(find.byType(DrawnCard));

          notifier.drawFromDrawPile();
          await tester.pump();

          expect(tester.getSize(find.byType(DrawnCard)), emptySize);
        },
      );
    },
  );
}
