import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/card_images_scope.dart';
import 'package:spoiled_supper_lotto_game/game_screen.dart';
import 'package:spoiled_supper_lotto_game/home_screen.dart';
import 'package:spoiled_supper_lotto_game/main.dart';
import 'package:spoiled_supper_lotto_game/setup_screen.dart';

void main() {
  group(
    'MyApp',
    () {
      /// Returns the text theme of the app on screen.
      TextTheme textThemeOf(WidgetTester tester) {
        return Theme.of(tester.element(find.byType(HomeScreen))).textTheme;
      }

      testWidgets(
        'shows the home screen',
        (tester) async {
          await tester.pumpWidget(const MyApp());

          expect(find.byType(HomeScreen), findsOneWidget);
        },
      );

      testWidgets(
        'shows the setup screen when the play button is pressed',
        (tester) async {
          await tester.pumpWidget(const MyApp());
          await tester.tap(find.widgetWithText(FilledButton, 'Play'));
          await tester.pumpAndSettle();

          expect(find.byType(SetupScreen), findsOneWidget);
        },
      );

      testWidgets(
        'shows the game screen when the start button is pressed',
        (tester) async {
          await tester.pumpWidget(const MyApp());
          await tester.tap(find.widgetWithText(FilledButton, 'Play'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byType(TextField).first, 'Sam');
          await tester
              .ensureVisible(find.widgetWithText(FilledButton, 'Start'));
          await tester.pumpAndSettle();
          await tester.tap(find.widgetWithText(FilledButton, 'Start'));
          await tester.pumpAndSettle();

          expect(
            tester.widget<GameScreen>(find.byType(GameScreen)).playerNames,
            ['Sam', 'Player 2'],
          );
        },
      );

      testWidgets(
        "starts the game with the setup screen's card images",
        (tester) async {
          await tester.pumpWidget(const MyApp());
          await tester.tap(find.widgetWithText(FilledButton, 'Play'));
          await tester.pumpAndSettle();
          await tester
              .ensureVisible(find.widgetWithText(FilledButton, 'Start'));
          await tester.pumpAndSettle();
          await tester.tap(find.widgetWithText(FilledButton, 'Start'));
          await tester.pumpAndSettle();

          // Below the setup screen's own CardImagesScope, now offstage.
          final setupScreenContent = find.descendant(
            of: find.byType(SetupScreen, skipOffstage: false),
            matching: find.byType(Scaffold, skipOffstage: false),
          );
          expect(
            tester.widget<GameScreen>(find.byType(GameScreen)).cardImages,
            same(CardImagesScope.of(tester.element(setupScreenContent))),
          );
        },
      );

      testWidgets(
        'sets the displayLarge text style in Caprasimo',
        (tester) async {
          await tester.pumpWidget(const MyApp());

          expect(
            textThemeOf(tester).displayLarge?.fontFamily,
            startsWith('Caprasimo'),
          );
        },
      );

      testWidgets(
        'sets the labelLarge text style in Fredoka',
        (tester) async {
          await tester.pumpWidget(const MyApp());

          expect(
            textThemeOf(tester).labelLarge?.fontFamily,
            startsWith('Fredoka'),
          );
        },
      );
    },
  );
}
