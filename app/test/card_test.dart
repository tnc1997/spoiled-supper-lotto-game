import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Card;
import 'package:spoiled_supper_lotto_game/card.dart';
import 'package:spoiled_supper_lotto_game/card_aspect_ratio.dart';
import 'package:spoiled_supper_lotto_game/card_images.dart';
import 'package:spoiled_supper_lotto_game/card_images_scope.dart';
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
  /// Once replaced in a [CardImagesScope], the images belong to it, which
  /// disposes of them when they're replaced or it's removed.
  Future<CardImages> loadImages(WidgetTester tester) async {
    return (await tester.runAsync(
      () => CardImages.load([
        XFile.fromData(png, name: 'fish-bone.png', path: 'fish-bone.png'),
      ]),
    ))!;
  }

  group(
    'Card',
    () {
      /// Shows Fish Bone with [images], or without a [CardImagesScope] if
      /// [images] is `null`, in a slot [width] logical pixels wide, or
      /// unbounded if [width] is `null`.
      Future<void> pumpCard(
        WidgetTester tester, {
        CardImages? images,
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
            home: images == null ? slot : CardImagesScope(child: slot),
          ),
        );

        if (images != null) {
          CardImagesScope.of(tester.element(find.byType(Card))).replace(images);
          await tester.pump();
        }
      }

      testWidgets(
        'shows a placeholder for a card without an image',
        (tester) async {
          final images = (await tester.runAsync(() => CardImages.load([])))!;
          await pumpCard(tester, images: images);

          expect(find.byType(PlaceholderCard), findsOneWidget);
        },
      );

      testWidgets(
        'shows a placeholder without a CardImagesScope',
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

  group(
    'CardImagesScope',
    () {
      /// The widget below the scope, from which to look it up.
      const child = SizedBox();

      /// Shows a scope with [child] below it.
      Future<void> pumpScope(WidgetTester tester) {
        return tester.pumpWidget(const CardImagesScope(child: child));
      }

      /// Returns the scope above [child].
      CardImagesScopeState scopeOf(WidgetTester tester) {
        return CardImagesScope.of(tester.element(find.byWidget(child)));
      }

      testWidgets(
        'holds no card images to start with',
        (tester) async {
          await pumpScope(tester);

          expect(scopeOf(tester).images, same(CardImages.empty));
        },
      );

      testWidgets(
        'holds the card images it is given',
        (tester) async {
          final images = await loadImages(tester);
          await pumpScope(tester);
          scopeOf(tester).replace(images);

          expect(scopeOf(tester).images, same(images));
        },
      );

      testWidgets(
        'rebuilds its dependents when its card images are replaced',
        (tester) async {
          final images = await loadImages(tester);
          final found = <CardImages>[];
          await tester.pumpWidget(
            CardImagesScope(
              child: Builder(
                builder: (context) {
                  found.add(CardImagesScope.of(context).images);
                  return const SizedBox();
                },
              ),
            ),
          );
          CardImagesScope.of(tester.element(find.byType(SizedBox)))
              .replace(images);
          await tester.pump();

          expect(found, [same(CardImages.empty), same(images)]);
        },
      );

      testWidgets(
        'disposes of the card images it replaces',
        (tester) async {
          final oldImages = await loadImages(tester);
          final newImages = await loadImages(tester);
          await pumpScope(tester);
          scopeOf(tester)
            ..replace(oldImages)
            ..replace(newImages);

          expect(oldImages[fishBone]!.debugDisposed, isTrue);
          expect(newImages[fishBone]!.debugDisposed, isFalse);
        },
      );

      testWidgets(
        'keeps the card images it is given again',
        (tester) async {
          final images = await loadImages(tester);
          await pumpScope(tester);
          scopeOf(tester)
            ..replace(images)
            ..replace(images);

          expect(images[fishBone]!.debugDisposed, isFalse);
        },
      );

      testWidgets(
        'disposes of its card images when removed',
        (tester) async {
          final images = await loadImages(tester);
          await pumpScope(tester);
          scopeOf(tester).replace(images);
          await tester.pumpWidget(const SizedBox());

          expect(images[fishBone]!.debugDisposed, isTrue);
        },
      );

      testWidgets(
        'of throws without a scope',
        (tester) async {
          await tester.pumpWidget(child);

          expect(
            () => CardImagesScope.of(tester.element(find.byWidget(child))),
            throwsFlutterError,
          );
        },
      );

      testWidgets(
        'maybeOf returns null without a scope',
        (tester) async {
          await tester.pumpWidget(child);

          expect(
            CardImagesScope.maybeOf(tester.element(find.byWidget(child))),
            isNull,
          );
        },
      );
    },
  );
}
