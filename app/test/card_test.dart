import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Card;
import 'package:spoiled_supper_lotto_game/card.dart';
import 'package:spoiled_supper_lotto_game/card_aspect_ratio.dart';
import 'package:spoiled_supper_lotto_game/card_images.dart';
import 'package:spoiled_supper_lotto_game/card_images_data.dart';
import 'package:spoiled_supper_lotto_game/placeholder_card.dart';

void main() {
  final fishBone = engine.buildDeck().singleWhere(
        (card) => card.id == '22407c27-1682-4fca-b9b9-015208b86f18',
      );

  // A 1x1px PNG.
  final png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
  );

  /// Loads an image of Fish Bone.
  ///
  /// Once given to a [CardImages] widget, the images belong to it, which
  /// disposes of them when they're replaced or it's removed.
  Future<CardImagesData> loadImages(WidgetTester tester) async {
    return (await tester.runAsync(
      () => CardImagesData.load([
        XFile.fromData(png, name: 'fish-bone.png', path: 'fish-bone.png'),
      ]),
    ))!;
  }

  group(
    'Card',
    () {
      /// Shows Fish Bone with [images], or without a [CardImages] if
      /// [images] is `null`, in a slot [width] logical pixels wide, or
      /// unbounded if [width] is `null`.
      Future<void> pumpCard(
        WidgetTester tester, {
        CardImagesData? images,
        double? width = 200,
      }) async {
        final card = Card(card: fishBone);
        final slot = width == null
            ? UnconstrainedBox(child: card)
            : Align(
                alignment: Alignment.topLeft,
                child: SizedBox(width: width, child: card),
              );

        await tester.pumpWidget(
          MaterialApp(
            home: images == null ? slot : CardImages(child: slot),
          ),
        );

        if (images != null) {
          CardImages.of(tester.element(find.byType(Card))).images = images;
          await tester.pump();
        }
      }

      testWidgets(
        'shows a placeholder for a card without an image',
        (tester) async {
          final images =
              (await tester.runAsync(() => CardImagesData.load([])))!;
          await pumpCard(tester, images: images);

          expect(find.byType(PlaceholderCard), findsOneWidget);
        },
      );

      testWidgets(
        'shows a placeholder without a CardImages',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(home: Card(card: fishBone)),
          );

          expect(find.byType(PlaceholderCard), findsOneWidget);
        },
      );

      testWidgets(
        'shows the image of a card with one',
        (tester) async {
          final images = await loadImages(tester);
          await pumpCard(tester, images: images);

          expect(
            tester.widget<RawImage>(find.byType(RawImage)).image,
            images[fishBone],
          );
        },
      );

      testWidgets(
        'shows the image of a card with one straight away',
        (tester) async {
          await pumpCard(tester, images: await loadImages(tester));

          expect(find.byType(PlaceholderCard), findsNothing);
        },
      );

      testWidgets(
        'crops an image of another shape from its centre to fill the card',
        (tester) async {
          await pumpCard(tester, images: await loadImages(tester));

          final image = tester.widget<RawImage>(find.byType(RawImage));

          expect(
            (fit: image.fit, alignment: image.alignment),
            (fit: BoxFit.cover, alignment: Alignment.center),
          );
        },
      );

      testWidgets(
        'announces a card with an image like a placeholder',
        (tester) async {
          await pumpCard(tester, images: await loadImages(tester));

          expect(
            tester.getSemantics(find.byType(Card)),
            matchesSemantics(label: 'Fish Bone, Main, Spoiled'),
          );
        },
      );

      testWidgets(
        'fills the width of its parent with an image',
        (tester) async {
          await pumpCard(tester, images: await loadImages(tester), width: 150);

          expect(tester.getSize(find.byType(Card)).width, 150);
        },
      );

      testWidgets(
        'keeps the shape of a card with an image',
        (tester) async {
          await pumpCard(tester, images: await loadImages(tester), width: 150);

          expect(
            tester.getSize(find.byType(Card)).aspectRatio,
            cardAspectRatio,
          );
        },
      );

      testWidgets(
        'takes up the same space with an image as a placeholder',
        (tester) async {
          await pumpCard(tester, width: null);
          final placeholder = tester.getSize(find.byType(Card));

          await pumpCard(tester, images: await loadImages(tester), width: null);
          final image = tester.getSize(find.byType(Card));

          expect(image, placeholder);
        },
      );
    },
  );
}
