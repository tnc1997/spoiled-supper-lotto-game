import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Card;
import 'package:spoiled_supper_lotto_game/card.dart';
import 'package:spoiled_supper_lotto_game/card_back.dart';
import 'package:spoiled_supper_lotto_game/drawn_card.dart';
import 'package:spoiled_supper_lotto_game/flipping_card.dart';
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
        'calls out a spoiled card once it is face up',
        (tester) async {
          final notifier = notifierWith(drawn: fishBone);
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pump();

          expect(find.text('Spoiled!'), findsNothing);

          await tester.pump(DrawnCard.flipDuration);

          expect(find.text('Spoiled!'), findsOneWidget);
          expect(
            tester.widget<Text>(find.text('Spoiled!')).style?.fontSize,
            Theme.of(
              tester.element(find.byType(DrawnCard)),
            ).textTheme.displaySmall?.fontSize,
          );

          await tester.pumpAndSettle();

          expect(find.text('Spoiled!'), findsNothing);
        },
      );

      testWidgets(
        'does not call out a standard card',
        (tester) async {
          final notifier = notifierWith(
            drawn: sausages,
            plate: [fishFingers],
          );
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pumpAndSettle();

          expect(find.text('Spoiled!'), findsNothing);
        },
      );

      testWidgets(
        'shakes a spoiled card while it is held face up',
        (tester) async {
          final notifier = notifierWith(drawn: fishBone);
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pump();
          await tester.pump(DrawnCard.flipDuration);

          final restingLeft = tester.getTopLeft(find.byType(DrawnCard)).dx;

          await tester.pump(DrawnCard.holdDuration ~/ 16);

          expect(
            tester.getTopLeft(find.byType(FlippingCard)).dx,
            isNot(moreOrLessEquals(restingLeft)),
          );
        },
      );

      testWidgets(
        'does not shake a standard card',
        (tester) async {
          final notifier = notifierWith(drawn: sausages);
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pump();
          await tester.pump(DrawnCard.flipDuration);
          await tester.pump(DrawnCard.holdDuration ~/ 16);

          expect(
            tester.getTopLeft(find.byType(FlippingCard)).dx,
            moreOrLessEquals(tester.getTopLeft(find.byType(DrawnCard)).dx),
          );
        },
      );

      testWidgets(
        'calls out a spoiled card without shaking it if animations are '
        'disabled',
        (tester) async {
          final notifier = notifierWith(drawn: fishBone);
          await pumpDrawnCard(tester, notifier, disableAnimations: true);

          notifier.drawFromDrawPile();
          await tester.pump();

          expect(find.text('Spoiled!'), findsOneWidget);

          await tester.pump(DrawnCard.holdDuration ~/ 16);

          expect(
            tester.getTopLeft(find.byType(FlippingCard)).dx,
            moreOrLessEquals(tester.getTopLeft(find.byType(DrawnCard)).dx),
          );
        },
      );

      testWidgets(
        'neither calls out nor shakes a spoiled card drawn from the discard '
        'pile',
        (tester) async {
          final notifier = notifierWith(drawn: fishBone, onDiscardPile: true);
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDiscardPile();
          await tester.pump();
          await tester.pump(DrawnCard.holdDuration ~/ 16);

          expect(find.text('Spoiled!'), findsNothing);
          expect(
            tester.getTopLeft(find.byType(FlippingCard)).dx,
            moreOrLessEquals(tester.getTopLeft(find.byType(DrawnCard)).dx),
          );
        },
      );

      testWidgets(
        'keeps the callout the same size with a larger text size',
        (tester) async {
          final notifier = notifierWith(drawn: fishBone);
          await pumpDrawnCard(tester, notifier, disableAnimations: true);

          notifier.drawFromDrawPile();
          await tester.pump();

          final size = tester.getSize(find.text('Spoiled!'));

          await tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: const MediaQueryData(
                  disableAnimations: true,
                  textScaler: TextScaler.linear(2),
                ),
                child: GameScope(
                  notifier: notifier,
                  child: const Center(child: DrawnCard()),
                ),
              ),
            ),
          );

          expect(tester.getSize(find.text('Spoiled!')), size);
        },
      );

      testWidgets(
        'leaves the callout out of the semantics tree',
        (tester) async {
          final notifier = notifierWith(drawn: fishBone);
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pump();
          await tester.pump(DrawnCard.flipDuration);

          expect(find.bySemanticsLabel('Spoiled!'), findsNothing);
          expect(
            find.bySemanticsLabel('Drawn card, Fish Bone, Main, Spoiled'),
            findsOneWidget,
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
