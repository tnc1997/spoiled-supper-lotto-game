import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/card_aspect_ratio.dart';
import 'package:spoiled_supper_lotto_game/framed_card.dart';
import 'package:spoiled_supper_lotto_game/game_notifier.dart';
import 'package:spoiled_supper_lotto_game/game_scope.dart';
import 'package:spoiled_supper_lotto_game/plate.dart';

void main() {
  group(
    'Plate',
    () {
      const sausages = engine.Card(
        id: '1',
        type: engine.CardType.standard,
        category: engine.Category.main,
        name: 'Sausages',
      );
      const pondWater = engine.Card(
        id: '2',
        type: engine.CardType.spoiled,
        category: engine.Category.drink,
        name: 'Pond Water',
      );
      const peas = engine.Card(
        id: '3',
        type: engine.CardType.standard,
        category: engine.Category.vegetable,
        name: 'Peas',
      );

      late engine.Player alice;
      late engine.Player bob;
      late GameNotifier notifier;

      setUp(
        () {
          alice = engine.Player(name: 'Alice');
          bob = engine.Player(name: 'Bob');
          notifier = GameNotifier(
            engine.GameController(
              players: [alice, bob],
              plates: {
                alice: [sausages, pondWater],
              },
              drawPile: [peas],
            ),
          );
          addTearDown(notifier.dispose);
        },
      );

      /// Shows [player]'s plate in the game of [notifier].
      Future<void> pumpPlate(WidgetTester tester, engine.Player player) {
        return tester.pumpWidget(
          MaterialApp(
            home: GameScope(
              notifier: notifier,
              child: Center(child: Plate(player: player)),
            ),
          ),
        );
      }

      /// Returns the centre of the slot announced as [label].
      Offset slotCentre(WidgetTester tester, String label) {
        return tester.getCenter(find.bySemanticsLabel(label));
      }

      testWidgets(
        'shows each card on the plate in a frame',
        (tester) async {
          await pumpPlate(tester, alice);

          expect(
            [
              for (final framed in tester.widgetList<FramedCard>(
                find.byType(FramedCard),
              ))
                framed.card,
            ],
            unorderedEquals([sausages, pondWater]),
          );
        },
      );

      testWidgets(
        'shows each empty slot with its category',
        (tester) async {
          await pumpPlate(tester, alice);

          expect(find.bySemanticsLabel('Vegetable, empty'), findsOneWidget);
          expect(find.bySemanticsLabel('Carbohydrate, empty'), findsOneWidget);
          expect(find.bySemanticsLabel('Dessert, empty'), findsOneWidget);
          expect(find.bySemanticsLabel('Main, empty'), findsNothing);
          expect(find.bySemanticsLabel('Drink, empty'), findsNothing);
          expect(find.text('Vegetable'), findsOneWidget);
        },
      );

      testWidgets(
        'shows an empty plate for a player with no cards',
        (tester) async {
          await pumpPlate(tester, bob);

          expect(find.byType(FramedCard), findsNothing);
          for (final category in [
            'Drink',
            'Dessert',
            'Vegetable',
            'Main',
            'Carbohydrate',
          ]) {
            expect(find.bySemanticsLabel('$category, empty'), findsOneWidget);
          }
        },
      );

      testWidgets(
        'lays out the slots in one row, like the physical board',
        (tester) async {
          await pumpPlate(tester, bob);

          final centres = [
            for (final category in [
              'Dessert',
              'Vegetable',
              'Main',
              'Carbohydrate',
              'Drink',
            ])
              slotCentre(tester, '$category, empty'),
          ];

          for (var i = 1; i < centres.length; i++) {
            expect(centres[i].dy, centres[0].dy);
            expect(centres[i].dx, greaterThan(centres[i - 1].dx));
          }
        },
      );

      testWidgets(
        'sizes every slot to a card of the width given',
        (tester) async {
          await pumpPlate(tester, alice);

          const size = Size(120, 120 / cardAspectRatio);
          expect(tester.getSize(find.bySemanticsLabel('Dessert, empty')), size);
          for (final framed in find.byType(FramedCard).evaluate()) {
            expect(framed.size, size);
          }
        },
      );

      testWidgets(
        "is announced as the player's plate",
        (tester) async {
          await pumpPlate(tester, alice);

          expect(find.bySemanticsLabel("Alice's plate"), findsOneWidget);
        },
      );

      testWidgets(
        'shows a card once it is placed',
        (tester) async {
          await pumpPlate(tester, alice);

          notifier.drawFromDrawPile();
          notifier.placeDrawnCard();
          await tester.pump();

          expect(find.bySemanticsLabel('Vegetable, empty'), findsNothing);
          expect(find.bySemanticsLabel('Peas, Vegetable'), findsOneWidget);
        },
      );
    },
  );
}
