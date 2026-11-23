import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Card;
import 'package:spoiled_supper_lotto_game/card.dart';
import 'package:spoiled_supper_lotto_game/card_back.dart';
import 'package:spoiled_supper_lotto_game/drawn_card.dart';
import 'package:spoiled_supper_lotto_game/game_notifier.dart';
import 'package:spoiled_supper_lotto_game/game_scope.dart';
import 'package:spoiled_supper_lotto_game/placing_card.dart';
import 'package:spoiled_supper_lotto_game/spoiled_reveal.dart';

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
      /// top of the draw pile, or of the discard pile if [onDiscardPile],
      /// disposed of after the test.
      GameNotifier notifierWith({
        required engine.Card drawn,
        List<engine.Card> plate = const [],
        bool onDiscardPile = false,
      }) {
        final notifier = GameNotifier(
          engine.GameController(
            players: [alice, engine.Player(name: 'Bob')],
            plates: {alice: plate},
            drawPile: [peas, if (!onDiscardPile) drawn],
            discardPile: [if (onDiscardPile) drawn],
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
        'shows a card drawn from the discard pile face up straight away',
        (tester) async {
          final notifier = notifierWith(
            drawn: sausages,
            plate: [fishFingers],
            onDiscardPile: true,
          );
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDiscardPile();
          await tester.pump();

          expect(find.byType(CardBack), findsNothing);
          expect(tester.widget<Card>(find.byType(Card)).card, sausages);
        },
      );

      testWidgets(
        'announces a card drawn from the discard pile straight away',
        (tester) async {
          final notifier = notifierWith(
            drawn: sausages,
            plate: [fishFingers],
            onDiscardPile: true,
          );
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDiscardPile();
          await tester.pump();

          expect(find.bySemanticsLabel('Drawn card'), findsNothing);
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
          await tester.pump(DrawnCard.placeDuration);
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
        'places a card drawn from the discard pile whose slot is empty once '
        'it has been face up for a moment',
        (tester) async {
          final notifier = notifierWith(drawn: sausages, onDiscardPile: true);
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDiscardPile();
          await tester.pump();
          await tester.pump(
            DrawnCard.holdDuration - const Duration(milliseconds: 1),
          );

          expect(notifier.game.drawnCard, sausages);

          await tester.pump(const Duration(milliseconds: 2));

          expect(notifier.isPlacingDrawnCard, isTrue);

          await tester.pump(DrawnCard.placeDuration);
          await tester.pump(const Duration(milliseconds: 1));

          expect(notifier.game.drawnCard, isNull);
          expect(notifier.game.plateOf(alice)[engine.Category.main], sausages);
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
        'waits for the player to choose for a card drawn from the discard '
        'pile whose slot is filled',
        (tester) async {
          final notifier = notifierWith(
            drawn: sausages,
            plate: [fishFingers],
            onDiscardPile: true,
          );
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDiscardPile();
          await tester.pumpAndSettle();

          expect(notifier.game.drawnCard, sausages);
          expect(tester.widget<Card>(find.byType(Card)).card, sausages);
        },
      );

      testWidgets(
        'reveals a spoiled card once it is face up',
        (tester) async {
          final notifier = notifierWith(drawn: fishBone);
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pump();

          expect(find.byType(SpoiledReveal), findsNothing);

          await tester.pump(DrawnCard.flipDuration);

          expect(find.byType(SpoiledReveal), findsOneWidget);
          expect(
            tester.widget<SpoiledReveal>(find.byType(SpoiledReveal)).duration,
            DrawnCard.holdDuration,
          );
        },
      );

      testWidgets(
        'reveals a spoiled card straight away if animations are disabled',
        (tester) async {
          final notifier = notifierWith(drawn: fishBone);
          await pumpDrawnCard(tester, notifier, disableAnimations: true);

          notifier.drawFromDrawPile();
          await tester.pump();

          expect(find.byType(SpoiledReveal), findsOneWidget);
        },
      );

      testWidgets(
        'does not reveal a standard card',
        (tester) async {
          final notifier = notifierWith(
            drawn: sausages,
            plate: [fishFingers],
          );
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pumpAndSettle();

          expect(find.byType(SpoiledReveal), findsNothing);
        },
      );

      testWidgets(
        'does not reveal a spoiled card drawn from the discard pile',
        (tester) async {
          final notifier = notifierWith(drawn: fishBone, onDiscardPile: true);
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDiscardPile();
          await tester.pump();

          expect(find.byType(SpoiledReveal), findsNothing);
        },
      );

      testWidgets(
        'takes a card chosen to be placed to its slot, then places it',
        (tester) async {
          final notifier = notifierWith(
            drawn: sausages,
            plate: [fishFingers],
          );
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pumpAndSettle();
          notifier.startPlacingDrawnCard();
          await tester.pump();

          final placingCard = tester.widget<PlacingCard>(
            find.byType(PlacingCard),
          );
          expect(placingCard.category, engine.Category.main);
          expect(placingCard.duration, DrawnCard.placeDuration);

          await tester.pump(
            DrawnCard.placeDuration - const Duration(milliseconds: 1),
          );

          expect(notifier.game.drawnCard, sausages);

          await tester.pump(const Duration(milliseconds: 2));

          expect(notifier.game.drawnCard, isNull);
          expect(notifier.game.plateOf(alice)[engine.Category.main], sausages);
        },
      );

      testWidgets(
        'does not announce a card again as it starts going to its slot',
        (tester) async {
          final notifier = notifierWith(
            drawn: sausages,
            plate: [fishFingers],
          );
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pumpAndSettle();
          notifier.startPlacingDrawnCard();
          await tester.pump();

          expect(
            tester.getSemantics(
              find.bySemanticsLabel('Drawn card, Sausages, Main'),
            ),
            isSemantics(isLiveRegion: false),
          );
        },
      );

      testWidgets(
        'takes the callout on a revealed spoiled card with it to its slot',
        (tester) async {
          final notifier = notifierWith(drawn: fishBone);
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pump();
          await tester.pump(DrawnCard.flipDuration + DrawnCard.holdDuration);
          await tester.pump(const Duration(milliseconds: 1));

          expect(notifier.isPlacingDrawnCard, isTrue);
          expect(
            find.descendant(
              of: find.byType(PlacingCard),
              matching: find.text('Spoiled!'),
            ),
            findsOneWidget,
          );
          expect(
            tester.widget<SpoiledReveal>(find.byType(SpoiledReveal)).duration,
            Duration.zero,
          );
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
