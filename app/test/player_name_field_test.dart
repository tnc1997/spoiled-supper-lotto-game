import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/player_name_field.dart';

void main() {
  group(
    'PlayerNameField',
    () {
      /// Shows a [PlayerNameField] for the player numbered [number],
      /// controlled by [controller].
      Future<void> pumpField(
        WidgetTester tester, {
        int number = 1,
        TextEditingController? controller,
      }) {
        return tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PlayerNameField(number: number, controller: controller),
            ),
          ),
        );
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

          final field = tester.widget<TextField>(find.byType(TextField));

          expect(field.decoration?.hintText, 'Player 3');
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
          final controller = TextEditingController();
          addTearDown(controller.dispose);

          await pumpField(tester, controller: controller);
          await tester.enterText(find.byType(TextField), 'Alex');

          expect(controller.text, 'Alex');
        },
      );

      testWidgets(
        'limits the name to maxLength characters',
        (tester) async {
          final controller = TextEditingController();
          addTearDown(controller.dispose);

          await pumpField(tester, controller: controller);
          await tester.enterText(
            find.byType(TextField),
            'A' * (PlayerNameField.maxLength + 5),
          );

          expect(controller.text, hasLength(PlayerNameField.maxLength));
        },
      );
    },
  );
}
