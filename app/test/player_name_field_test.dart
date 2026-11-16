import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/player_name_field.dart';

void main() {
  group(
    'PlayerNameField',
    () {
      /// Shows a [PlayerNameField] for the player numbered [number],
      /// doing [textInputAction], and returns its controller.
      Future<TextEditingController> pumpField(
        WidgetTester tester, {
        int number = 1,
        TextInputAction textInputAction = TextInputAction.next,
      }) async {
        final controller = TextEditingController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PlayerNameField(
                number: number,
                controller: controller,
                textInputAction: textInputAction,
              ),
            ),
          ),
        );

        return controller;
      }

      /// Returns the text field of the name field on screen.
      TextField textFieldOf(WidgetTester tester) {
        return tester.widget<TextField>(find.byType(TextField));
      }

      group(
        'defaultNameOf',
        () {
          test(
            'names the player by their number',
            () {
              expect(PlayerNameField.defaultNameOf(1), 'Player 1');
              expect(PlayerNameField.defaultNameOf(4), 'Player 4');
            },
          );
        },
      );

      group(
        'nameOf',
        () {
          test(
            'returns the name typed',
            () {
              expect(PlayerNameField.nameOf(1, 'Alex'), 'Alex');
            },
          );

          test(
            'trims whitespace around the name typed',
            () {
              expect(PlayerNameField.nameOf(1, '  Alex  '), 'Alex');
            },
          );

          test(
            'returns the default name when nothing is typed',
            () {
              expect(PlayerNameField.nameOf(2, ''), 'Player 2');
            },
          );

          test(
            'returns the default name when only whitespace is typed',
            () {
              expect(PlayerNameField.nameOf(3, '   '), 'Player 3');
            },
          );

          test(
            'returns the default name when only invisible characters are typed',
            () {
              expect(
                PlayerNameField.nameOf(4, '\u200B \u2060\uFEFF'),
                'Player 4',
              );
            },
          );

          test(
            'trims invisible characters around the name typed',
            () {
              expect(PlayerNameField.nameOf(1, '\u200BAlex\u200B'), 'Alex');
            },
          );

          test(
            'keeps invisible characters inside the name typed',
            () {
              const family = '\u{1F468}\u200D\u{1F469}\u200D\u{1F467}';

              expect(PlayerNameField.nameOf(1, family), family);
            },
          );
        },
      );

      testWidgets(
        'labels the field with the player number',
        (tester) async {
          await pumpField(tester, number: 2);

          expect(find.text('Player 2 name'), findsOneWidget);
        },
      );

      testWidgets(
        'shows the default name as a hint',
        (tester) async {
          await pumpField(tester, number: 3);

          expect(textFieldOf(tester).decoration?.hintText, 'Player 3');
        },
      );

      testWidgets(
        'says the name is optional',
        (tester) async {
          await pumpField(tester);

          expect(find.text('Optional'), findsOneWidget);
        },
      );

      testWidgets(
        'puts the name typed in the controller',
        (tester) async {
          final controller = await pumpField(tester);
          await tester.enterText(find.byType(TextField), 'Alex');

          expect(controller.text, 'Alex');
        },
      );

      testWidgets(
        'limits the name to maxLength characters',
        (tester) async {
          final controller = await pumpField(tester);
          await tester.enterText(
            find.byType(TextField),
            'A' * (PlayerNameField.maxLength + 5),
          );

          expect(controller.text, hasLength(PlayerNameField.maxLength));
        },
      );

      testWidgets(
        'moves to the next field from the keyboard by default',
        (tester) async {
          await pumpField(tester);

          expect(textFieldOf(tester).textInputAction, TextInputAction.next);
        },
      );

      testWidgets(
        'does the keyboard action given',
        (tester) async {
          await pumpField(tester, textInputAction: TextInputAction.done);

          expect(textFieldOf(tester).textInputAction, TextInputAction.done);
        },
      );
    },
  );
}
