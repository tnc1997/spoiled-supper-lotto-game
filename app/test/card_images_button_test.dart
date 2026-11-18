import 'dart:async';
import 'dart:convert';

import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/card_images.dart';
import 'package:spoiled_supper_lotto_game/card_images_button.dart';
import 'package:spoiled_supper_lotto_game/card_images_data.dart';

import 'fake_file_picker.dart';

void main() {
  group(
    'CardImagesButton',
    () {
      /// Finds the button to choose card images, whether it's showing its
      /// label or progress.
      final chooseCardImagesButton = find.descendant(
        of: find.byType(CardImagesButton),
        matching: find.byType(OutlinedButton),
      );

      final fishBone = engine.buildDeck().singleWhere(
            (card) => card.id == '22407c27-1682-4fca-b9b9-015208b86f18',
          );

      // A 1x1px PNG.
      final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
      );

      /// An image of Fish Bone, as the player would choose it.
      final fishBoneFile = FakePlatformFile('fish-bone.png', png);

      /// A file that isn't named after a card.
      final holidayFile = FakePlatformFile('holiday.png', png);

      /// Shows the button below a [CardImages], with a fake file picker
      /// answering with each of [picks] in turn.
      Future<void> pumpWithPicks(
        WidgetTester tester,
        List<Future<List<PlatformFile>> Function()> picks,
      ) {
        FakeFilePicker.install(picks);

        return tester.pumpWidget(
          const CardImages(
            child: MaterialApp(
              home: Scaffold(body: Center(child: CardImagesButton())),
            ),
          ),
        );
      }

      /// Returns the card images the button has chosen, or
      /// [CardImagesData.empty] if it hasn't chosen any.
      CardImagesData cardImagesOf(WidgetTester tester) {
        return CardImages.of(
          tester.element(find.byType(CardImagesButton)),
        ).images;
      }

      /// Presses the button to choose card images.
      Future<void> tapChooseCardImages(WidgetTester tester) async {
        await tester.tap(chooseCardImagesButton);
        await tester.pump();
      }

      /// Presses the button to choose card images, and waits for the images
      /// chosen to load.
      ///
      /// Decoding the images only finishes outside of the test's fake
      /// clock, so the button is pressed with [WidgetTester.runAsync]. Use
      /// [tapChooseCardImages] when no images are loaded, e.g. when the
      /// player cancels.
      Future<void> chooseCardImages(WidgetTester tester) async {
        final oldImages = cardImagesOf(tester);
        await tester.runAsync(() async {
          tester.widget<ButtonStyleButton>(chooseCardImagesButton).onPressed!();

          for (var i = 0; identical(cardImagesOf(tester), oldImages); i++) {
            if (i == 500) {
              fail('The card images chosen did not load.');
            }

            await Future<void>.delayed(const Duration(milliseconds: 10));
          }
        });
        await tester.pump();
      }

      /// Whether the button to choose card images on screen is enabled.
      bool isChooseCardImagesEnabledOf(WidgetTester tester) {
        return tester.widget<ButtonStyleButton>(chooseCardImagesButton).enabled;
      }

      testWidgets(
        'uses the card images chosen for the session, saying how many cards',
        (tester) async {
          await pumpWithPicks(tester, [
            () async => [fishBoneFile]
          ]);
          await chooseCardImages(tester);
          await tester.pumpAndSettle();

          expect(cardImagesOf(tester)[fishBone], isNotNull);
          expect(find.text('Using your image of 1 card.'), findsOneWidget);
        },
      );

      testWidgets(
        'keeps the card images chosen when the player cancels',
        (tester) async {
          await pumpWithPicks(
            tester,
            [
              () async => [fishBoneFile],
              () async => []
            ],
          );
          await chooseCardImages(tester);
          final images = cardImagesOf(tester);
          await tapChooseCardImages(tester);

          expect(cardImagesOf(tester), same(images));
          expect(images[fishBone]!.debugDisposed, isFalse);
        },
      );

      testWidgets(
        'keeps the card images chosen when no file is named after a card',
        (tester) async {
          await pumpWithPicks(
            tester,
            [
              () async => [fishBoneFile],
              () async => [holidayFile]
            ],
          );
          await chooseCardImages(tester);
          final images = cardImagesOf(tester);
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
          await pumpWithPicks(
            tester,
            [
              () async => [fishBoneFile],
              () => Future.error(StateError('failed')),
            ],
          );
          await chooseCardImages(tester);
          final images = cardImagesOf(tester);
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
          final pick = Completer<List<PlatformFile>>();
          await pumpWithPicks(tester, [() => pick.future]);
          await tapChooseCardImages(tester);

          expect(isChooseCardImagesEnabledOf(tester), isFalse);
          expect(find.byType(CircularProgressIndicator), findsOneWidget);

          pick.complete([]);
          await tester.pump();

          expect(isChooseCardImagesEnabledOf(tester), isTrue);
          expect(find.byType(CircularProgressIndicator), findsNothing);
        },
      );

      testWidgets(
        'shrinks the button to choose card images until they are chosen, '
        'saying that they are loading',
        (tester) async {
          final pick = Completer<List<PlatformFile>>();
          await pumpWithPicks(tester, [() => pick.future]);
          final size = tester.getSize(chooseCardImagesButton);
          await tapChooseCardImages(tester);

          // Waits for the button to shrink. It can't settle, since the
          // progress indicator keeps spinning.
          await tester.pump(const Duration(milliseconds: 300));

          expect(
            tester.getSize(chooseCardImagesButton).width,
            lessThan(size.width),
          );
          expect(find.bySemanticsLabel('Loading card images'), findsOneWidget);
          expect(find.text('Choose card images'), findsNothing);

          pick.complete([]);
          await tester.pumpAndSettle();

          expect(tester.getSize(chooseCardImagesButton), size);
          expect(find.text('Choose card images'), findsOneWidget);
        },
      );
    },
  );
}
