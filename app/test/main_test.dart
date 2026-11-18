import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
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

      final fishBone = engine.buildDeck().singleWhere(
            (card) => card.id == '22407c27-1682-4fca-b9b9-015208b86f18',
          );

      // A 1x1px PNG.
      final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
      );

      /// Loads an image of Fish Bone.
      ///
      /// Once chosen, the images belong to the app, which disposes of them
      /// when they're replaced or it's removed at the end of the test.
      Future<CardImages> loadImages(WidgetTester tester) async {
        return (await tester.runAsync(
          () => CardImages.load([
            XFile.fromData(png, name: 'fish-bone.png', path: 'fish-bone.png'),
          ]),
        ))!;
      }

      /// Returns the card images exposed to the screen of type [screen].
      CardImages cardImagesOf(WidgetTester tester, Type screen) {
        return CardImagesScope.of(tester.element(find.byType(screen)));
      }

      /// Presses [button], scrolling it into view first.
      Future<void> tapButton(WidgetTester tester, Finder button) async {
        await tester.ensureVisible(button);
        await tester.pumpAndSettle();
        await tester.tap(button);
        await tester.pumpAndSettle();
      }

      /// Opens the setup screen from the home screen.
      Future<void> openSetupScreen(WidgetTester tester) {
        return tapButton(tester, find.widgetWithText(FilledButton, 'Play'));
      }

      /// Presses the button to choose card images on the setup screen.
      Future<void> chooseCardImages(WidgetTester tester) {
        return tapButton(tester, find.text('Choose card images'));
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
        'exposes no card images until the player chooses some',
        (tester) async {
          await tester.pumpWidget(const MyApp());
          await openSetupScreen(tester);

          expect(cardImagesOf(tester, SetupScreen), same(CardImages.empty));
        },
      );

      testWidgets(
        'exposes the card images chosen to the setup and game screens',
        (tester) async {
          final images = await loadImages(tester);
          await tester.pumpWidget(MyApp(pickCardImages: () async => images));
          await openSetupScreen(tester);
          await chooseCardImages(tester);

          expect(cardImagesOf(tester, SetupScreen), same(images));
          expect(find.text('Using your image of 1 card.'), findsOneWidget);

          // Waits for the message to go, so that it doesn't cover Start.
          await tester.pump(const Duration(seconds: 5));
          await tester.pumpAndSettle();

          await tapButton(tester, find.widgetWithText(FilledButton, 'Start'));

          expect(cardImagesOf(tester, GameScreen), same(images));
        },
      );

      testWidgets(
        'keeps the card images exposed when the player cancels',
        (tester) async {
          final images = await loadImages(tester);
          final picks = [images, null];
          await tester.pumpWidget(
            MyApp(pickCardImages: () async => picks.removeAt(0)),
          );
          await openSetupScreen(tester);
          await chooseCardImages(tester);
          await chooseCardImages(tester);

          expect(cardImagesOf(tester, SetupScreen), same(images));
          expect(images[fishBone]!.debugDisposed, isFalse);
        },
      );

      testWidgets(
        'disposes of the card images replaced by the ones chosen',
        (tester) async {
          final oldImages = await loadImages(tester);
          final newImages = await loadImages(tester);
          final picks = [oldImages, newImages];
          await tester.pumpWidget(
            MyApp(pickCardImages: () async => picks.removeAt(0)),
          );
          await openSetupScreen(tester);
          await chooseCardImages(tester);
          await chooseCardImages(tester);

          expect(cardImagesOf(tester, SetupScreen), same(newImages));
          expect(oldImages[fishBone]!.debugDisposed, isTrue);
          expect(newImages[fishBone]!.debugDisposed, isFalse);
        },
      );

      testWidgets(
        'keeps the card images exposed when no file is named after a card',
        (tester) async {
          final images = await loadImages(tester);
          final noImages = (await tester.runAsync(
            () => CardImages.load([
              XFile.fromData(png, name: 'holiday.png', path: 'holiday.png'),
            ]),
          ))!;
          final picks = [images, noImages];
          await tester.pumpWidget(
            MyApp(pickCardImages: () async => picks.removeAt(0)),
          );
          await openSetupScreen(tester);
          await chooseCardImages(tester);
          await chooseCardImages(tester);

          expect(cardImagesOf(tester, SetupScreen), same(images));
          expect(images[fishBone]!.debugDisposed, isFalse);
          expect(
            find.text(
              'None of the files you chose are named after a card, so your '
              'card images are unchanged.',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'keeps the card images exposed and reports the error when choosing '
        'them fails',
        (tester) async {
          final images = await loadImages(tester);
          final picks = <Future<CardImages?> Function()>[
            () async => images,
            () => Future.error(StateError('failed')),
          ];
          await tester.pumpWidget(
            MyApp(pickCardImages: () => picks.removeAt(0)()),
          );
          await openSetupScreen(tester);
          await chooseCardImages(tester);
          await chooseCardImages(tester);

          expect(tester.takeException(), isStateError);
          expect(cardImagesOf(tester, SetupScreen), same(images));
          expect(
            find.text("Your card images couldn't be opened. Please try again."),
            findsOneWidget,
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
