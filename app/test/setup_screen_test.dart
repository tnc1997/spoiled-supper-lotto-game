import 'dart:async';
import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/card_images.dart';
import 'package:spoiled_supper_lotto_game/card_images_host.dart';
import 'package:spoiled_supper_lotto_game/card_images_scope.dart';
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

      /// Finds the start button.
      final startButton = find.widgetWithText(FilledButton, 'Start');

      /// Finds the button to choose card images.
      final chooseCardImagesButton = find.ancestor(
        of: find.text('Choose card images'),
        matching: find.bySubtype<ButtonStyleButton>(),
      );

      final fishBone = engine.buildDeck().singleWhere(
            (card) => card.id == '22407c27-1682-4fca-b9b9-015208b86f18',
          );

      // A 1x1px PNG.
      final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
      );

      /// Loads an image of Fish Bone.
      ///
      /// Once chosen, the images belong to the [CardImagesHost], which
      /// disposes of them when they're replaced or it's removed.
      Future<CardImages> loadImages(WidgetTester tester) async {
        return (await tester.runAsync(
          () => CardImages.load([
            XFile.fromData(png, name: 'fish-bone.png', path: 'fish-bone.png'),
          ]),
        ))!;
      }

      /// Shows the setup screen below a [CardImagesHost], choosing card
      /// images with each of [picks] in turn.
      Future<void> pumpWithPicks(
        WidgetTester tester,
        List<Future<CardImages?> Function()> picks,
      ) {
        return tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => CardImagesHost(child: child!),
            home: SetupScreen(pickCardImages: () => picks.removeAt(0)()),
          ),
        );
      }

      /// Returns the card images the setup screen on screen exposes.
      CardImages cardImagesOf(WidgetTester tester) {
        return CardImagesScope.of(
          tester.element(find.byType(PlayerCountSelector)),
        );
      }

      /// Presses the button to choose card images, scrolling it into view
      /// first.
      Future<void> tapChooseCardImages(WidgetTester tester) async {
        await tester.ensureVisible(chooseCardImagesButton);
        await tester.pumpAndSettle();
        await tester.tap(chooseCardImagesButton);
        await tester.pump();
      }

      /// Whether the button to choose card images on screen is enabled.
      bool isChooseCardImagesEnabledOf(WidgetTester tester) {
        return tester.widget<ButtonStyleButton>(chooseCardImagesButton).enabled;
      }

      /// Whether the start button on screen is enabled.
      bool isStartEnabledOf(WidgetTester tester) {
        return tester.widget<FilledButton>(startButton).enabled;
      }

      /// Shows the setup screen, returning the names it's started with each
      /// time the start button is pressed.
      Future<List<List<String>>> pumpSetupScreen(WidgetTester tester) async {
        final starts = <List<String>>[];

        await tester.pumpWidget(
          MaterialApp(
            home: SetupScreen(onStart: starts.add),
          ),
        );

        return starts;
      }

      /// Presses the start button, scrolling it into view first.
      Future<void> tapStart(WidgetTester tester) async {
        await tester.ensureVisible(startButton);
        await tester.pumpAndSettle();
        await tester.tap(startButton);
        await tester.pump();
      }

      /// Returns the errors shown on the name fields on screen, in turn
      /// order.
      List<String?> nameErrorsOf(WidgetTester tester) {
        return tester
            .widgetList<PlayerNameField>(find.byType(PlayerNameField))
            .map((field) => field.errorText)
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

      testWidgets(
        'moves to the next field from every name field but the last',
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SetupScreen()));
          await tester.tap(find.text('3 players'));
          await tester.pump();

          expect(
            tester
                .widgetList<PlayerNameField>(find.byType(PlayerNameField))
                .map((field) => field.textInputAction),
            [
              TextInputAction.next,
              TextInputAction.next,
              TextInputAction.done,
            ],
          );
        },
      );

      testWidgets(
        'starts with each player playing, with the default name if none is typed',
        (tester) async {
          final starts = await pumpSetupScreen(tester);
          await tester.tap(find.text('3 players'));
          await tester.pump();
          await tester.enterText(nameFieldOf(1), 'Alex');
          await tapStart(tester);

          expect(starts, [
            ['Alex', 'Player 2', 'Player 3'],
          ]);
        },
      );

      testWidgets(
        'starts without the players no longer playing',
        (tester) async {
          final starts = await pumpSetupScreen(tester);
          await tester.tap(find.text('3 players'));
          await tester.pump();
          await tester.enterText(nameFieldOf(3), 'Sam');
          await tester.tap(find.text('2 players'));
          await tester.pump();
          await tapStart(tester);

          expect(starts, [
            ['Player 1', 'Player 2'],
          ]);
        },
      );

      testWidgets(
        'shows no errors when every name is different',
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SetupScreen()));
          await tester.enterText(nameFieldOf(1), 'Sam');
          await tester.enterText(nameFieldOf(2), 'Alex');
          await tester.pump();

          expect(nameErrorsOf(tester), [null, null]);
        },
      );

      testWidgets(
        'asks both players with the same typed name to tell them apart',
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SetupScreen()));
          await tester.enterText(nameFieldOf(1), 'Sam');
          await tester.enterText(nameFieldOf(2), 'sam');
          await tester.pump();

          expect(nameErrorsOf(tester), [
            'Another player is called sam. Add an initial to tell them apart.',
            'Another player is called Sam. Add an initial to tell them apart.',
          ]);
        },
      );

      testWidgets(
        "asks only the player who typed another player's default name",
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SetupScreen()));
          await tester.enterText(nameFieldOf(1), 'Player 2');
          await tester.pump();

          expect(nameErrorsOf(tester), [
            'Another player is called Player 2. '
                'Add an initial to tell them apart.',
            null,
          ]);
        },
      );

      testWidgets(
        'clears the errors once the names are told apart',
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SetupScreen()));
          await tester.enterText(nameFieldOf(1), 'Sam');
          await tester.enterText(nameFieldOf(2), 'Sam');
          await tester.pump();
          await tester.enterText(nameFieldOf(2), 'Sam B');
          await tester.pump();

          expect(nameErrorsOf(tester), [null, null]);
        },
      );

      testWidgets(
        'ignores the names of players no longer playing',
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SetupScreen()));
          await tester.tap(find.text('3 players'));
          await tester.pump();
          await tester.enterText(nameFieldOf(1), 'Sam');
          await tester.enterText(nameFieldOf(3), 'Sam');
          await tester.tap(find.text('2 players'));
          await tester.pump();

          expect(nameErrorsOf(tester), [null, null]);
        },
      );

      testWidgets(
        'enables the start button when every name is different',
        (tester) async {
          await pumpSetupScreen(tester);

          expect(isStartEnabledOf(tester), isTrue);
        },
      );

      testWidgets(
        'disables the start button while two players have the same name',
        (tester) async {
          final starts = await pumpSetupScreen(tester);
          await tester.enterText(nameFieldOf(1), 'Sam');
          await tester.enterText(nameFieldOf(2), 'sam');
          await tester.pump();

          expect(isStartEnabledOf(tester), isFalse);

          await tapStart(tester);

          expect(starts, isEmpty);
        },
      );

      testWidgets(
        "disables the start button while a player types another's default name",
        (tester) async {
          await pumpSetupScreen(tester);
          await tester.enterText(nameFieldOf(1), 'player 2');
          await tester.pump();

          expect(isStartEnabledOf(tester), isFalse);
        },
      );

      testWidgets(
        'enables the start button once the names are told apart',
        (tester) async {
          await pumpSetupScreen(tester);
          await tester.enterText(nameFieldOf(1), 'Sam');
          await tester.enterText(nameFieldOf(2), 'Sam');
          await tester.pump();
          await tester.enterText(nameFieldOf(2), 'Sam B');
          await tester.pump();

          expect(isStartEnabledOf(tester), isTrue);
        },
      );

      testWidgets(
        'disables the start button without a callback',
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SetupScreen()));

          expect(isStartEnabledOf(tester), isFalse);
        },
      );

      testWidgets(
        'asks whether the players have their own card images as a header',
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SetupScreen()));

          expect(
            tester.getSemantics(
              find.text('Do you have your own card images?'),
            ),
            matchesSemantics(
              label: 'Do you have your own card images?',
              isHeader: true,
            ),
          );
        },
      );

      testWidgets(
        'uses the card images chosen for the session, saying how many cards',
        (tester) async {
          final images = await loadImages(tester);
          await pumpWithPicks(tester, [() async => images]);
          await tapChooseCardImages(tester);

          expect(cardImagesOf(tester), same(images));
          await tester.pumpAndSettle();

          expect(find.text('Using your image of 1 card.'), findsOneWidget);
        },
      );

      testWidgets(
        'keeps the card images chosen when the player cancels',
        (tester) async {
          final images = await loadImages(tester);
          await pumpWithPicks(tester, [() async => images, () async => null]);
          await tapChooseCardImages(tester);
          await tapChooseCardImages(tester);

          expect(cardImagesOf(tester), same(images));
          expect(images[fishBone]!.debugDisposed, isFalse);
        },
      );

      testWidgets(
        'keeps the card images chosen when no file is named after a card',
        (tester) async {
          final images = await loadImages(tester);
          final noImages = (await tester.runAsync(
            () => CardImages.load([
              XFile.fromData(png, name: 'holiday.png', path: 'holiday.png'),
            ]),
          ))!;
          await pumpWithPicks(
            tester,
            [() async => images, () async => noImages],
          );
          await tapChooseCardImages(tester);
          await tapChooseCardImages(tester);
          await tester.pumpAndSettle();

          expect(cardImagesOf(tester), same(images));
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
        'keeps the card images chosen, and reports the error, when choosing '
        'fails',
        (tester) async {
          final images = await loadImages(tester);
          await pumpWithPicks(
            tester,
            [() async => images, () => Future.error(StateError('failed'))],
          );
          await tapChooseCardImages(tester);
          await tapChooseCardImages(tester);
          await tester.pumpAndSettle();

          expect(tester.takeException(), isStateError);
          expect(cardImagesOf(tester), same(images));
          expect(
            find.text("Your card images couldn't be opened. Please try again."),
            findsOneWidget,
          );
          expect(isChooseCardImagesEnabledOf(tester), isTrue);
        },
      );

      testWidgets(
        'disables the button to choose card images until they are chosen',
        (tester) async {
          final pick = Completer<CardImages?>();
          await pumpWithPicks(tester, [() => pick.future]);
          await tapChooseCardImages(tester);

          expect(isChooseCardImagesEnabledOf(tester), isFalse);
          expect(find.byType(CircularProgressIndicator), findsOneWidget);

          pick.complete(null);
          await tester.pump();

          expect(isChooseCardImagesEnabledOf(tester), isTrue);
          expect(find.byType(CircularProgressIndicator), findsNothing);
        },
      );
    },
  );
}
