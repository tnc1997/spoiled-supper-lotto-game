import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/player_name_field.dart';

void main() {
  group(
    'PlayerNameField',
    () {
      /// Shows a [PlayerNameField] for the player numbered [number],
      /// doing [textInputAction] and showing [errorText], and returns its
      /// controller.
      Future<TextEditingController> pumpField(
        WidgetTester tester, {
        int number = 1,
        TextInputAction textInputAction = TextInputAction.next,
        String? errorText,
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
                errorText: errorText,
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
        },
      );

      group(
        'isSameName',
        () {
          test(
            'matches the same name',
            () {
              expect(PlayerNameField.isSameName('Sam', 'Sam'), isTrue);
            },
          );

          test(
            'ignores differences in case',
            () {
              expect(PlayerNameField.isSameName('Sam', 'sAM'), isTrue);
            },
          );

          test(
            'ignores differences in the whitespace between words',
            () {
              expect(PlayerNameField.isSameName('Sam B', 'Sam  B'), isTrue);
              expect(PlayerNameField.isSameName('Sam B', 'Sam\tB'), isTrue);
            },
          );

          test(
            'tells different names apart',
            () {
              expect(PlayerNameField.isSameName('Sam', 'Sam B'), isFalse);
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

      testWidgets(
        'shows the error given instead of saying the name is optional',
        (tester) async {
          await pumpField(tester, errorText: 'Another player is called Sam.');

          expect(find.text('Another player is called Sam.'), findsOneWidget);
          expect(find.text('Optional'), findsNothing);
        },
      );
    },
  );
}
