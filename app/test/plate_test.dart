import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Card;
import 'package:spoiled_supper_lotto_game/card.dart';
import 'package:spoiled_supper_lotto_game/card_aspect_ratio.dart';
import 'package:spoiled_supper_lotto_game/card_frame.dart';
import 'package:spoiled_supper_lotto_game/game_notifier.dart';
import 'package:spoiled_supper_lotto_game/game_scope.dart';
import 'package:spoiled_supper_lotto_game/plate.dart';
import 'package:spoiled_supper_lotto_game/plate_aspect_ratio.dart';

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

      testWidgets(
        'shows each card on the plate in a frame',
        (tester) async {
          await pumpPlate(tester, alice);

          expect(
            [
              for (final card in tester.widgetList<Card>(
                find.descendant(
                  of: find.byType(CardFrame),
                  matching: find.byType(Card),
                ),
              ))
                card.card,
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

          expect(find.byType(Card), findsNothing);
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
        'lays out the slots edge to edge in one row, like the physical board',
        (tester) async {
          await pumpPlate(tester, bob);

          final slots = [
            for (final category in [
              'Dessert',
              'Vegetable',
              'Main',
              'Carbohydrate',
              'Drink',
            ])
              tester.getRect(find.bySemanticsLabel('$category, empty')),
          ];

          for (var i = 1; i < slots.length; i++) {
            expect(slots[i].top, slots[0].top);
            // Split only by a hairline divider.
            expect(slots[i].left - slots[i - 1].right, 1);
          }
        },
      );

      testWidgets(
        'runs the slots across the full width of a 3:2 board, centred from '
        'top to bottom',
        (tester) async {
          await pumpPlate(tester, bob);

          final board = tester.getRect(find.byType(Plate));
          final dessert = tester.getRect(
            find.bySemanticsLabel('Dessert, empty'),
          );
          final drink = tester.getRect(find.bySemanticsLabel('Drink, empty'));

          expect(
            board.width / board.height,
            moreOrLessEquals(plateAspectRatio),
          );
          expect(dessert.left, board.left);
          expect(drink.right, board.right);
          expect(
            dessert.top - board.top,
            moreOrLessEquals(board.bottom - dessert.bottom),
          );
          expect(dessert.top, greaterThan(board.top));
        },
      );

      testWidgets(
        'sizes every slot to a card of the width given',
        (tester) async {
          await pumpPlate(tester, alice);

          const size = Size(120, 120 / cardAspectRatio);
          expect(tester.getSize(find.bySemanticsLabel('Dessert, empty')), size);
          for (final framed in find.byType(CardFrame).evaluate()) {
            expect(framed.size, size);
          }
        },
      );

      testWidgets(
        "shows each empty slot plain, in the theme's lowest container colour",
        (tester) async {
          await pumpPlate(tester, bob);

          final colorScheme = Theme.of(
            tester.element(find.byType(Plate)),
          ).colorScheme;

          for (final category in [
            'Dessert',
            'Vegetable',
            'Main',
            'Carbohydrate',
            'Drink',
          ]) {
            final box = tester.widget<ColoredBox>(
              find.descendant(
                of: find.bySemanticsLabel('$category, empty'),
                matching: find.byType(ColoredBox),
              ),
            );

            expect(box.color, colorScheme.surfaceContainerLowest);
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
