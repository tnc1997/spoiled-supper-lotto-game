import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:spoiled_supper_lotto_game/card_images.dart';
import 'package:spoiled_supper_lotto_game/card_images_data.dart';

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
    'CardImages',
    () {
      /// The widget below the [CardImages], from which to look it up.
      const child = SizedBox();

      /// Shows a [CardImages] with [child] below it.
      Future<void> pumpCardImages(WidgetTester tester) {
        return tester.pumpWidget(const CardImages(child: child));
      }

      /// Returns the state of the [CardImages] above [child].
      CardImagesState stateOf(WidgetTester tester) {
        return CardImages.of(tester.element(find.byWidget(child)));
      }

      testWidgets(
        'holds no card images to start with',
        (tester) async {
          await pumpCardImages(tester);

          expect(stateOf(tester).images, same(CardImagesData.empty));
        },
      );

      testWidgets(
        'holds the card images it is given',
        (tester) async {
          final images = await loadImages(tester);
          await pumpCardImages(tester);
          stateOf(tester).images = images;

          expect(stateOf(tester).images, same(images));
        },
      );

      testWidgets(
        'rebuilds its dependents when its card images are replaced',
        (tester) async {
          final images = await loadImages(tester);
          final found = <CardImagesData>[];
          await tester.pumpWidget(
            CardImages(
              child: Builder(
                builder: (context) {
                  found.add(CardImages.of(context).images);
                  return const SizedBox();
                },
              ),
            ),
          );
          CardImages.of(tester.element(find.byType(SizedBox))).images = images;
          await tester.pump();

          expect(found, [same(CardImagesData.empty), same(images)]);
        },
      );

      testWidgets(
        'disposes of the card images it replaces',
        (tester) async {
          final oldImages = await loadImages(tester);
          final newImages = await loadImages(tester);
          await pumpCardImages(tester);
          stateOf(tester).images = oldImages;
          stateOf(tester).images = newImages;

          expect(oldImages[fishBone]!.debugDisposed, isTrue);
          expect(newImages[fishBone]!.debugDisposed, isFalse);
        },
      );

      testWidgets(
        'keeps the card images it is given again',
        (tester) async {
          final images = await loadImages(tester);
          await pumpCardImages(tester);
          stateOf(tester).images = images;
          stateOf(tester).images = images;

          expect(images[fishBone]!.debugDisposed, isFalse);
        },
      );

      testWidgets(
        'disposes of its card images when removed',
        (tester) async {
          final images = await loadImages(tester);
          await pumpCardImages(tester);
          stateOf(tester).images = images;
          await tester.pumpWidget(const SizedBox());

          expect(images[fishBone]!.debugDisposed, isTrue);
        },
      );

      testWidgets(
        'of throws without a CardImages',
        (tester) async {
          await tester.pumpWidget(child);

          expect(
            () => CardImages.of(tester.element(find.byWidget(child))),
            throwsFlutterError,
          );
        },
      );

      testWidgets(
        'maybeOf returns null without a CardImages',
        (tester) async {
          await tester.pumpWidget(child);

          expect(
            CardImages.maybeOf(tester.element(find.byWidget(child))),
            isNull,
          );
        },
      );
    },
  );
}
