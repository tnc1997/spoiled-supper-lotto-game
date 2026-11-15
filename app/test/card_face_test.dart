import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart';
import 'package:material_ui/material_ui.dart' hide Card;
import 'package:spoiled_supper_lotto_game/card_face.dart';
import 'package:spoiled_supper_lotto_game/card_images.dart';
import 'package:spoiled_supper_lotto_game/card_images_scope.dart';
import 'package:spoiled_supper_lotto_game/card_size.dart';
import 'package:spoiled_supper_lotto_game/placeholder_card.dart';

void main() {
  group(
    'CardFace',
    () {
      final fishBone = buildDeck().singleWhere(
        (card) => card.id == '22407c27-1682-4fca-b9b9-015208b86f18',
      );

      // A 1x1px PNG.
      final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
      );

      /// Loads an image of Fish Bone holding a copy of [bytes].
      ///
      /// Each copy is a different image to the image cache, so an image
      /// decoded by one test isn't already decoded in the next.
      Future<CardImages> imagesOf(Uint8List bytes) {
        return CardImages.load([
          (
            name: 'fish-bone.png',
            readAsBytes: () async => Uint8List.fromList(bytes),
          ),
        ]);
      }

      /// Shows Fish Bone with [images] in a slot [width] logical pixels
      /// wide, or unbounded if [width] is `null`.
      Future<void> pumpCard(
        WidgetTester tester, {
        CardImages? images,
        double? width = 200,
      }) {
        final card = CardFace(card: fishBone);

        return tester.pumpWidget(
          MaterialApp(
            home: CardImagesScope(
              images: images ?? CardImages.empty,
              child: width == null
                  ? UnconstrainedBox(child: card)
                  : Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(width: width, child: card),
                    ),
            ),
          ),
        );
      }

      /// Waits for the image on screen to be decoded, or to fail to be.
      Future<void> decodeImage(WidgetTester tester) async {
        final finder = find.byType(Image);
        final image = tester.widget<Image>(finder);

        await tester.runAsync(
          () => precacheImage(
            image.image,
            tester.element(finder),
            onError: (error, stackTrace) {},
          ),
        );
        await tester.pump();
      }

      testWidgets(
        'shows a placeholder for a card without an image',
        (tester) async {
          await pumpCard(tester);

          expect(find.byType(PlaceholderCard), findsOneWidget);
        },
      );

      testWidgets(
        'shows a placeholder without a CardImagesScope',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(home: CardFace(card: fishBone)),
          );

          expect(find.byType(PlaceholderCard), findsOneWidget);
        },
      );

      testWidgets(
        'shows the image of a card with one',
        (tester) async {
          await pumpCard(tester, images: await imagesOf(png));

          expect(find.byType(Image), findsOneWidget);
        },
      );

      testWidgets(
        'shows a placeholder while the image is decoded',
        (tester) async {
          await pumpCard(tester, images: await imagesOf(png));

          expect(find.byType(PlaceholderCard), findsOneWidget);
        },
      );

      testWidgets(
        'does not show a placeholder once the image is decoded',
        (tester) async {
          await pumpCard(tester, images: await imagesOf(png));
          await decodeImage(tester);

          expect(find.byType(PlaceholderCard), findsNothing);
        },
      );

      testWidgets(
        'decodes the image at the height it is shown',
        (tester) async {
          await pumpCard(tester, images: await imagesOf(png), width: 150);

          final image = tester.widget<Image>(find.byType(Image));
          final shown = 240 * tester.view.devicePixelRatio;

          expect(
            (image.image as ResizeImage).height,
            inInclusiveRange(shown, shown + 63),
          );
        },
      );

      testWidgets(
        'shows a placeholder for an image that cannot be shown',
        (tester) async {
          await pumpCard(
            tester,
            images: await imagesOf(Uint8List.fromList([1, 2, 3])),
          );
          await decodeImage(tester);

          expect(find.byType(PlaceholderCard), findsOneWidget);
        },
      );

      testWidgets(
        'announces the name and category of a card with an image',
        (tester) async {
          await pumpCard(tester, images: await imagesOf(png));
          await decodeImage(tester);

          expect(
            tester.getSemantics(find.byType(Image)),
            isSemantics(label: 'Fish Bone, Main, Spoiled'),
          );
        },
      );

      testWidgets(
        'announces a card with an image only once while it is decoded',
        (tester) async {
          final semantics = tester.ensureSemantics();
          await pumpCard(tester, images: await imagesOf(png));
          final announced = find
              .bySemanticsLabel('Fish Bone, Main, Spoiled')
              .evaluate()
              .length;
          semantics.dispose();

          expect(announced, 1);
        },
      );

      testWidgets(
        'fills the width of its parent with an image',
        (tester) async {
          await pumpCard(tester, images: await imagesOf(png), width: 150);

          expect(tester.getSize(find.byType(CardFace)).width, 150);
        },
      );

      testWidgets(
        'keeps the shape of a card with an image',
        (tester) async {
          await pumpCard(tester, images: await imagesOf(png), width: 150);

          expect(
            tester.getSize(find.byType(CardFace)).aspectRatio,
            cardAspectRatio,
          );
        },
      );

      testWidgets(
        'takes up the same space with an image as a placeholder',
        (tester) async {
          await pumpCard(tester, width: null);
          final placeholder = tester.getSize(find.byType(CardFace));

          await pumpCard(tester, images: await imagesOf(png), width: null);
          final image = tester.getSize(find.byType(CardFace));

          expect(image, placeholder);
        },
      );
    },
  );

  group(
    'PlaceholderCard',
    () {
      test(
        'has the shape of every card',
        () {
          expect(PlaceholderCard.size.aspectRatio, cardAspectRatio);
        },
      );
    },
  );
}
