import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart';
import 'package:material_ui/material_ui.dart' hide Card;
import 'package:spoiled_supper_lotto_game/category_color.dart';
import 'package:spoiled_supper_lotto_game/placeholder_card.dart';

void main() {
  group(
    'PlaceholderCard',
    () {
      const sausages = Card(
        id: '1',
        type: CardType.standard,
        category: Category.main,
        name: 'Sausages',
      );
      const fishBone = Card(
        id: '2',
        type: CardType.spoiled,
        category: Category.main,
        name: 'Fish Bone',
      );

      /// Shows [card] in a slot [width] logical pixels wide, with a text
      /// theme in the Fredoka font family.
      Future<void> pumpCard(
        WidgetTester tester,
        Card card, {
        double width = 200,
      }) {
        return tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              textTheme: const TextTheme(
                labelSmall: TextStyle(fontFamily: 'Fredoka'),
                titleMedium: TextStyle(fontFamily: 'Fredoka'),
              ),
            ),
            home: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: PlaceholderCard(card: card),
              ),
            ),
          ),
        );
      }

      /// Returns the background colour of the [PlaceholderCard] on screen.
      Color? backgroundOf(WidgetTester tester) {
        final box = tester.widget<DecoratedBox>(
          find.descendant(
            of: find.byType(PlaceholderCard),
            matching: find.byType(DecoratedBox),
          ),
        );

        return (box.decoration as BoxDecoration).color;
      }

      testWidgets(
        'shows the name of the card',
        (tester) async {
          await pumpCard(tester, sausages);

          expect(find.text('Sausages'), findsOneWidget);
        },
      );

      testWidgets(
        'shows the name of the card in Fredoka',
        (tester) async {
          await pumpCard(tester, sausages);

          final text = tester.widget<Text>(find.text('Sausages'));

          expect(text.style?.fontFamily, 'Fredoka');
        },
      );

      testWidgets(
        'does not tag a standard card as Spoiled',
        (tester) async {
          await pumpCard(tester, sausages);

          expect(find.text('SPOILED'), findsNothing);
        },
      );

      testWidgets(
        'tags a Spoiled card as Spoiled',
        (tester) async {
          await pumpCard(tester, fishBone);

          expect(find.text('SPOILED'), findsOneWidget);
        },
      );

      /// Returns the background colour of a card of each category, of the
      /// given [type].
      Future<Map<Category, Color>> backgroundsOf(
        WidgetTester tester,
        CardType type,
      ) async {
        final backgrounds = <Category, Color>{};
        for (final category in Category.values) {
          await pumpCard(
            tester,
            Card(id: '1', type: type, category: category, name: 'X'),
          );
          backgrounds[category] = backgroundOf(tester)!;
        }

        return backgrounds;
      }

      /// Returns the squared distance between [a] and [b] in RGB space.
      double distanceBetween(Color a, Color b) =>
          (a.r - b.r) * (a.r - b.r) +
          (a.g - b.g) * (a.g - b.g) +
          (a.b - b.b) * (a.b - b.b);

      testWidgets(
        'shows the category of the card',
        (tester) async {
          await pumpCard(tester, sausages);

          expect(find.text('Main'), findsOneWidget);
        },
      );

      testWidgets(
        'announces the name and category of a standard card together',
        (tester) async {
          await pumpCard(tester, sausages);

          expect(
            tester.getSemantics(find.byType(PlaceholderCard)),
            isSemantics(label: 'Sausages, Main'),
          );
        },
      );

      testWidgets(
        'announces the name and category of a Spoiled card together',
        (tester) async {
          await pumpCard(tester, fishBone);

          expect(
            tester.getSemantics(find.byType(PlaceholderCard)),
            isSemantics(label: 'Fish Bone, Main, Spoiled'),
          );
        },
      );

      testWidgets(
        'gives standard cards of each category a different colour',
        (tester) async {
          final backgrounds = await backgroundsOf(
            tester,
            CardType.standard,
          );

          expect(
            backgrounds.values.toSet(),
            hasLength(Category.values.length),
          );
        },
      );

      testWidgets(
        'keeps the colour of a Spoiled card closest to its own category',
        (tester) async {
          final standard = await backgroundsOf(
            tester,
            CardType.standard,
          );
          final spoiled = await backgroundsOf(
            tester,
            CardType.spoiled,
          );

          final closest = {
            for (final MapEntry(key: category, value: color) in spoiled.entries)
              category: Category.values.reduce(
                (a, b) => distanceBetween(color, standard[a]!) <=
                        distanceBetween(color, standard[b]!)
                    ? a
                    : b,
              ),
          };

          expect(closest, {
            for (final category in Category.values) category: category,
          });
        },
      );

      testWidgets(
        'fits a long name at a large text size',
        (tester) async {
          tester.platformDispatcher.textScaleFactorTestValue = 3;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          await pumpCard(
            tester,
            const Card(
              id: '3',
              type: CardType.spoiled,
              category: Category.carbohydrate,
              name: 'Potato Peelings',
            ),
            width: 100,
          );

          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'keeps a long name on the card at a large text size',
        (tester) async {
          tester.platformDispatcher.textScaleFactorTestValue = 3;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          await pumpCard(
            tester,
            const Card(
              id: '3',
              type: CardType.spoiled,
              category: Category.carbohydrate,
              name: 'Potato Peelings',
            ),
            width: 100,
          );

          final card = tester.getRect(find.byType(PlaceholderCard));
          final name = tester.getRect(find.text('Potato Peelings'));

          expect(card.expandToInclude(name), card);
        },
      );

      testWidgets(
        'follows the system text size while the name fits',
        (tester) async {
          const milk = Card(
            id: '4',
            type: CardType.standard,
            category: Category.drink,
            name: 'Milk',
          );

          await pumpCard(tester, milk);
          final normal = tester.getRect(find.text('Milk')).height;

          tester.platformDispatcher.textScaleFactorTestValue = 1.25;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await pumpCard(tester, milk);
          final larger = tester.getRect(find.text('Milk')).height;

          // The test font rounds line heights to whole pixels.
          expect(larger, closeTo(normal * 1.25, 1));
        },
      );

      testWidgets(
        'mutes the colour of a Spoiled card',
        (tester) async {
          await pumpCard(tester, sausages);
          final standard = backgroundOf(tester)!;

          await pumpCard(tester, fishBone);
          final spoiled = backgroundOf(tester)!;

          expect(
            HSLColor.fromColor(spoiled).saturation,
            lessThan(HSLColor.fromColor(standard).saturation),
          );
        },
      );

      testWidgets(
        'fills the width of its parent',
        (tester) async {
          await pumpCard(tester, sausages, width: 150);

          expect(tester.getSize(find.byType(PlaceholderCard)).width, 150);
        },
      );

      testWidgets(
        'keeps the shape of a playing card',
        (tester) async {
          await pumpCard(tester, sausages, width: 150);

          expect(tester.getSize(find.byType(PlaceholderCard)).height, 210);
        },
      );

      testWidgets(
        'shows at its own size in an unbounded parent',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: UnconstrainedBox(child: PlaceholderCard(card: sausages)),
            ),
          );

          expect(
            tester.getSize(find.byType(PlaceholderCard)),
            PlaceholderCard.size,
          );
        },
      );

      testWidgets(
        'scales the name with the width of the card',
        (tester) async {
          // Measure on screen, since the card is scaled after layout.
          await pumpCard(tester, sausages, width: 100);
          final small = tester.getRect(find.text('Sausages')).height;

          await pumpCard(tester, sausages, width: 200);
          final large = tester.getRect(find.text('Sausages')).height;

          expect(large, greaterThan(small));
        },
      );
    },
  );

  group(
    'CategoryColor',
    () {
      test(
        'gives every category a different colour',
        () {
          final colors = {
            for (final category in Category.values) category.color,
          };

          expect(colors, hasLength(Category.values.length));
        },
      );
    },
  );
}
