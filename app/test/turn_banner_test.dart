import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/game_notifier.dart';
import 'package:spoiled_supper_lotto_game/game_scope.dart';
import 'package:spoiled_supper_lotto_game/turn_banner.dart';

void main() {
  group(
    'TurnBanner',
    () {
      const headlineSmall = TextStyle(fontFamily: 'Fredoka');

      const sausages = engine.Card(
        id: '1',
        type: engine.CardType.standard,
        category: engine.Category.main,
        name: 'Sausages',
      );

      /// Returns a notifier for a game between Sam, Alex and Jo, disposed of
      /// after the test.
      GameNotifier notifierFor() {
        final notifier = GameNotifier(
          engine.GameController(
            players: [
              engine.Player(name: 'Sam'),
              engine.Player(name: 'Alex'),
              engine.Player(name: 'Jo'),
            ],
            drawPile: [sausages, sausages, sausages],
          ),
        );
        addTearDown(notifier.dispose);

        return notifier;
      }

      /// Shows the turn banner of the game of [notifier], with a text theme
      /// whose `headlineSmall` style is [headlineSmall].
      Future<void> pumpBanner(WidgetTester tester, GameNotifier notifier) {
        return tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              textTheme: const TextTheme(headlineSmall: headlineSmall),
            ),
            home: GameScope(
              notifier: notifier,
              child: const Center(child: TurnBanner()),
            ),
          ),
        );
      }

      /// Expects [current]'s name to be highlighted, with a different fill,
      /// border and text colour from each of the [others], which all look the
      /// same.
      void expectHighlighted(
        WidgetTester tester,
        String current,
        List<String> others,
      ) {
        ({Color? fill, ShapeBorder border, Color? text}) lookOf(String name) {
          final decoration = tester
              .widget<DecoratedBox>(
                find.ancestor(
                  of: find.text(name),
                  matching: find.byType(DecoratedBox),
                ),
              )
              .decoration as ShapeDecoration;

          return (
            fill: decoration.color,
            border: decoration.shape,
            text: tester.widget<Text>(find.text(name)).style?.color,
          );
        }

        final highlighted = lookOf(current);

        for (final other in others) {
          final look = lookOf(other);

          expect(look, lookOf(others.first));
          expect(look.fill, isNot(highlighted.fill));
          expect(look.border, isNot(highlighted.border));
          expect(look.text, isNot(highlighted.text));
        }
      }

      testWidgets(
        'shows whose turn it is',
        (tester) async {
          await pumpBanner(tester, notifierFor());

          expect(find.text("Sam's turn"), findsOneWidget);
        },
      );

      testWidgets(
        'shows whose turn it is in the headlineSmall text style',
        (tester) async {
          await pumpBanner(tester, notifierFor());

          final text = tester.widget<Text>(find.text("Sam's turn"));

          expect(text.style?.fontFamily, headlineSmall.fontFamily);
        },
      );

      testWidgets(
        'announces whose turn it is as a header in a live region',
        (tester) async {
          await pumpBanner(tester, notifierFor());

          expect(
            tester.getSemantics(find.text("Sam's turn")),
            matchesSemantics(
              label: "Sam's turn",
              isHeader: true,
              isLiveRegion: true,
            ),
          );
        },
      );

      testWidgets(
        'shows every player in turn order',
        (tester) async {
          await pumpBanner(tester, notifierFor());

          final names = [
            for (final text in tester.widgetList<Text>(
              find.descendant(
                of: find.byType(Wrap),
                matching: find.byType(Text),
              ),
            ))
              text.data,
          ];

          expect(names, ['Sam', 'Alex', 'Jo']);
        },
      );

      testWidgets(
        'highlights the current player',
        (tester) async {
          await pumpBanner(tester, notifierFor());

          expectHighlighted(tester, 'Sam', ['Alex', 'Jo']);
        },
      );

      testWidgets(
        'announces only the current player as selected',
        (tester) async {
          await pumpBanner(tester, notifierFor());

          expect(
            tester.getSemantics(find.text('Sam')),
            matchesSemantics(
              label: 'Sam',
              hasSelectedState: true,
              isSelected: true,
            ),
          );
          expect(
            tester.getSemantics(find.text('Alex')),
            matchesSemantics(label: 'Alex'),
          );
        },
      );

      testWidgets(
        'moves on to the next player when the turn passes',
        (tester) async {
          final notifier = notifierFor();
          await pumpBanner(tester, notifier);

          notifier
            ..drawFromDrawPile()
            ..placeDrawnCard();
          await tester.pump();

          expect(find.text("Alex's turn"), findsOneWidget);
          expectHighlighted(tester, 'Alex', ['Sam', 'Jo']);
        },
      );
    },
  );
}
