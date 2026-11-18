import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/card_images.dart';
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
        'keeps the card images chosen for the whole session',
        (tester) async {
          final images = (await tester.runAsync(() => CardImages.load([])))!;
          await tester.pumpWidget(const MyApp());
          await tester.tap(find.widgetWithText(FilledButton, 'Play'));
          await tester.pumpAndSettle();

          // Chooses the images as the setup screen does, without opening the
          // platform's file picker.
          CardImagesScope.of(tester.element(find.byType(SetupScreen)))
              .replace(images);

          // Goes back to the home screen, and then sets up and starts a game.
          await tester.pageBack();
          await tester.pumpAndSettle();
          await tester.tap(find.widgetWithText(FilledButton, 'Play'));
          await tester.pumpAndSettle();
          await tester
              .ensureVisible(find.widgetWithText(FilledButton, 'Start'));
          await tester.pumpAndSettle();
          await tester.tap(find.widgetWithText(FilledButton, 'Start'));
          await tester.pumpAndSettle();

          expect(
            CardImagesScope.of(tester.element(find.byType(GameScreen))).images,
            same(images),
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
