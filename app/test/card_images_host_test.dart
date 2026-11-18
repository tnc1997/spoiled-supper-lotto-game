import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/card_images.dart';
import 'package:spoiled_supper_lotto_game/card_images_host.dart';
import 'package:spoiled_supper_lotto_game/card_images_scope.dart';

void main() {
  group(
    'CardImagesHost',
    () {
      final fishBone = engine.buildDeck().singleWhere(
            (card) => card.id == '22407c27-1682-4fca-b9b9-015208b86f18',
          );

      // A 1x1px PNG.
      final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
      );

      /// Loads an image of Fish Bone.
      ///
      /// Once replaced in the host, the images belong to it, which disposes
      /// of them when they're replaced or it's removed.
      Future<CardImages> loadImages(WidgetTester tester) async {
        return (await tester.runAsync(
          () => CardImages.load([
            XFile.fromData(png, name: 'fish-bone.png', path: 'fish-bone.png'),
          ]),
        ))!;
      }

      /// The widget below the host, from which to look it and its scope up.
      const child = SizedBox();

      /// Shows a host with [child] below it.
      Future<void> pumpHost(WidgetTester tester) {
        return tester.pumpWidget(const CardImagesHost(child: child));
      }

      /// Returns the host above [child].
      CardImagesHostState hostOf(WidgetTester tester) {
        return CardImagesHost.of(tester.element(find.byWidget(child)));
      }

      /// Returns the card images exposed to [child].
      CardImages cardImagesOf(WidgetTester tester) {
        return CardImagesScope.of(tester.element(find.byWidget(child)));
      }

      testWidgets(
        'exposes no card images to start with',
        (tester) async {
          await pumpHost(tester);

          expect(cardImagesOf(tester), same(CardImages.empty));
          expect(hostOf(tester).images, same(CardImages.empty));
        },
      );

      testWidgets(
        'exposes the card images it is given',
        (tester) async {
          final images = await loadImages(tester);
          await pumpHost(tester);
          hostOf(tester).replace(images);
          await tester.pump();

          expect(cardImagesOf(tester), same(images));
          expect(hostOf(tester).images, same(images));
        },
      );

      testWidgets(
        'disposes of the card images it replaces',
        (tester) async {
          final oldImages = await loadImages(tester);
          final newImages = await loadImages(tester);
          await pumpHost(tester);
          hostOf(tester).replace(oldImages);
          hostOf(tester).replace(newImages);
          await tester.pump();

          expect(oldImages[fishBone]!.debugDisposed, isTrue);
          expect(newImages[fishBone]!.debugDisposed, isFalse);
        },
      );

      testWidgets(
        'keeps the card images it is given again',
        (tester) async {
          final images = await loadImages(tester);
          await pumpHost(tester);
          hostOf(tester).replace(images);
          hostOf(tester).replace(images);
          await tester.pump();

          expect(images[fishBone]!.debugDisposed, isFalse);
        },
      );

      testWidgets(
        'disposes of its card images when removed',
        (tester) async {
          final images = await loadImages(tester);
          await pumpHost(tester);
          hostOf(tester).replace(images);
          await tester.pumpWidget(const SizedBox());

          expect(images[fishBone]!.debugDisposed, isTrue);
        },
      );

      testWidgets(
        'throws without a CardImagesHost',
        (tester) async {
          await tester.pumpWidget(child);

          expect(
            () => CardImagesHost.of(tester.element(find.byWidget(child))),
            throwsFlutterError,
          );
        },
      );
    },
  );
}
