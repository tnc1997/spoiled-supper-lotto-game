import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/category_color.dart';
import 'package:spoiled_supper_lotto_game/placeholder_card.dart';

void main() {
  group(
    'PlaceholderCard',
    () {
      const sausages = engine.Card(
        id: '1',
        type: engine.CardType.standard,
        category: engine.Category.main,
        name: 'Sausages',
      );
      const fishBone = engine.Card(
        id: '2',
        type: engine.CardType.spoiled,
        category: engine.Category.main,
        name: 'Fish Bone',
      );

      /// Shows [card] in a slot [width] logical pixels wide, with a text
      /// theme in the Fredoka font family.
      Future<void> pumpCard(
        WidgetTester tester,
        engine.Card card, {
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
      Future<Map<engine.Category, Color>> backgroundsOf(
        WidgetTester tester,
        engine.CardType type,
      ) async {
        final backgrounds = <engine.Category, Color>{};
        for (final category in engine.Category.values) {
          await pumpCard(
            tester,
            engine.Card(id: '1', type: type, category: category, name: 'X'),
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
        'centres the letters of the Spoiled tag on the card',
        (tester) async {
          await pumpCard(tester, fishBone);

          final tag = find.text('SPOILED');
          final spacing = tester.widget<Text>(tag).style!.letterSpacing!;
          final rect = tester.getRect(tag);

          // The text box includes the spacing after the last letter.
          expect(
            rect.left + (rect.width - spacing) / 2,
            closeTo(tester.getCenter(find.byType(PlaceholderCard)).dx, 0.01),
          );
        },
      );

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
            engine.CardType.standard,
          );

          expect(
            backgrounds.values.toSet(),
            hasLength(engine.Category.values.length),
          );
        },
      );

      testWidgets(
        'keeps the colour of a Spoiled card closest to its own category',
        (tester) async {
          final standard = await backgroundsOf(
            tester,
            engine.CardType.standard,
          );
          final spoiled = await backgroundsOf(
            tester,
            engine.CardType.spoiled,
          );

          final closest = {
            for (final MapEntry(key: category, value: color) in spoiled.entries)
              category: engine.Category.values.reduce(
                (a, b) => distanceBetween(color, standard[a]!) <=
                        distanceBetween(color, standard[b]!)
                    ? a
                    : b,
              ),
          };

          expect(closest, {
            for (final category in engine.Category.values) category: category,
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
            const engine.Card(
              id: '3',
              type: engine.CardType.spoiled,
              category: engine.Category.carbohydrate,
              name: 'Potato Peelings',
            ),
            width: 100,
          );

          expect(tester.takeException(), isNull);
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
        'scales the name with the width of the card',
        (tester) async {
          await pumpCard(tester, sausages, width: 100);
          final small = tester.getSize(find.text('Sausages')).height;

          await pumpCard(tester, sausages, width: 200);
          final large = tester.getSize(find.text('Sausages')).height;

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
            for (final category in engine.Category.values) category.color,
          };

          expect(colors, hasLength(engine.Category.values.length));
        },
      );
    },
  );
}
