import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/player_count_selector.dart';
import 'package:spoiled_supper_lotto_game/player_name_field.dart';
import 'package:spoiled_supper_lotto_game/setup_screen.dart';

void main() {
  group(
    'SetupScreen',
    () {
      /// Returns the number of players chosen on the selector on screen.
      int playerCountOf(WidgetTester tester) {
        return tester
            .widget<PlayerCountSelector>(find.byType(PlayerCountSelector))
            .playerCount;
      }

      /// Returns the numbers of the players whose name fields are on screen.
      List<int> numbersOfNameFields(WidgetTester tester) {
        return tester
            .widgetList<PlayerNameField>(find.byType(PlayerNameField))
            .map((field) => field.number)
            .toList();
      }

      /// Finds the name field of the player numbered [number].
      Finder nameFieldOf(int number) {
        return find.byWidgetPredicate(
          (widget) => widget is PlayerNameField && widget.number == number,
        );
      }

      testWidgets(
        'shows that the game is Pass & Play',
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SetupScreen()));

          expect(find.text('Pass & Play'), findsOneWidget);
        },
      );

      testWidgets(
        'asks how many players there are as a header',
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SetupScreen()));

          expect(
            tester.getSemantics(find.text('How many players?')),
            matchesSemantics(label: 'How many players?', isHeader: true),
          );
        },
      );

      testWidgets(
        'chooses 2 players to start with',
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SetupScreen()));

          expect(playerCountOf(tester), 2);
        },
      );

      testWidgets(
        'chooses the number of players tapped',
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SetupScreen()));
          await tester.tap(find.text('3 players'));
          await tester.pump();

          expect(playerCountOf(tester), 3);
        },
      );

      testWidgets(
        "asks for the players' names as a header",
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SetupScreen()));

          expect(
            tester.getSemantics(find.text("What are the players' names?")),
            matchesSemantics(
              label: "What are the players' names?",
              isHeader: true,
            ),
          );
        },
      );

      testWidgets(
        'shows a name field for each player',
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SetupScreen()));

          expect(numbersOfNameFields(tester), [1, 2]);

          await tester.tap(find.text('4 players'));
          await tester.pump();

          expect(numbersOfNameFields(tester), [1, 2, 3, 4]);
        },
      );

      testWidgets(
        'keeps the names typed when the number of players changes',
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SetupScreen()));
          await tester.tap(find.text('3 players'));
          await tester.pump();
          await tester.enterText(nameFieldOf(3), 'Sam');
          await tester.tap(find.text('2 players'));
          await tester.pump();

          expect(numbersOfNameFields(tester), [1, 2]);

          await tester.tap(find.text('3 players'));
          await tester.pump();

          expect(
            find.descendant(of: nameFieldOf(3), matching: find.text('Sam')),
            findsOneWidget,
          );
        },
      );
    },
  );
}
