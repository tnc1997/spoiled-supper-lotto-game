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
                child: Center(
                  child: DrawnCard(
                    builder: (context, card, actions) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [card, actions],
                    ),
                  ),
                ),
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
          expect(find.text('Place').hitTestable(), findsOneWidget);
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

          expect(find.text('Place').hitTestable(), findsNothing);
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
          await tester.pump();

          expect(find.text('Place').hitTestable(), findsNothing);
          expect(find.text('Discard').hitTestable(), findsNothing);

          await tester.pumpAndSettle();

          expect(find.text('Place').hitTestable(), findsOneWidget);
          expect(find.text('Discard').hitTestable(), findsOneWidget);
          expect(notifier.game.drawnCard, sausages);
        },
      );

      testWidgets(
        'places the card, discarding the one it replaces, when Place is '
        'tapped',
        (tester) async {
          final notifier = notifierWith(
            drawn: sausages,
            plate: [fishFingers],
          );
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pumpAndSettle();
          await tester.tap(find.text('Place').hitTestable());
          await tester.pump();

          expect(notifier.game.plateOf(alice)[engine.Category.main], sausages);
          expect(notifier.game.discardPile, [fishFingers]);
          expect(find.text('Place').hitTestable(), findsNothing);
        },
      );

      testWidgets(
        'discards the card when Discard is tapped',
        (tester) async {
          final notifier = notifierWith(
            drawn: sausages,
            plate: [fishFingers],
          );
          await pumpDrawnCard(tester, notifier);

          notifier.drawFromDrawPile();
          await tester.pumpAndSettle();
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
        'keeps the space of the card and its actions while there is nothing '
        'to show in them',
        (tester) async {
          final notifier = notifierWith(
            drawn: sausages,
            plate: [fishFingers],
          );
          await pumpDrawnCard(tester, notifier);

          final emptySize = tester.getSize(find.byType(DrawnCard));

          notifier.drawFromDrawPile();
          await tester.pump();

          expect(tester.getSize(find.byType(DrawnCard)), emptySize);

          await tester.pumpAndSettle();

          expect(find.text('Place').hitTestable(), findsOneWidget);
          expect(tester.getSize(find.byType(DrawnCard)), emptySize);
        },
      );

      testWidgets(
        'disables its actions while they are hidden',
        (tester) async {
          await pumpDrawnCard(tester, notifierWith(drawn: sausages));

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
