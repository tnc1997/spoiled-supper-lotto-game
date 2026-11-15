import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Card;
import 'package:spoiled_supper_lotto_game/card.dart';
import 'package:spoiled_supper_lotto_game/card_images.dart';
import 'package:spoiled_supper_lotto_game/card_images_scope.dart';
import 'package:spoiled_supper_lotto_game/card_size.dart';
import 'package:spoiled_supper_lotto_game/placeholder_card.dart';

void main() {
  final fishBone = engine.buildDeck().singleWhere(
        (card) => card.id == '22407c27-1682-4fca-b9b9-015208b86f18',
      );

  // A 1x1px PNG.
  final png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
  );

  /// Loads an image of Fish Bone, disposing of it after the test.
  Future<CardImages> loadImages(WidgetTester tester) async {
    final images = (await tester.runAsync(
      () => CardImages.load([
        (name: 'fish-bone.png', readAsBytes: () async => png),
      ]),
    ))!;
    addTearDown(images.dispose);

    return images;
  }

  group(
    'Card',
    () {
      /// Shows Fish Bone with [images] in a slot [width] logical pixels
      /// wide, or unbounded if [width] is `null`.
      Future<void> pumpCard(
        WidgetTester tester, {
        CardImages images = CardImages.empty,
        double? width = 200,
      }) {
        final card = Card(card: fishBone);

        return tester.pumpWidget(
          MaterialApp(
            home: CardImagesScope(
              images: images,
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
            images.of(fishBone),
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
      /// Builds [builder] below a [CardImagesScope] of [images], or without
      /// one if [images] is `null`.
      Future<void> pumpScope(
        WidgetTester tester,
        CardImages? images,
        void Function(BuildContext context) builder,
      ) {
        final child = Builder(
          builder: (context) {
            builder(context);
            return const SizedBox();
          },
        );

        return tester.pumpWidget(
          images == null
              ? child
              : CardImagesScope(images: images, child: child),
        );
      }

      testWidgets(
        'of returns the images of the scope',
        (tester) async {
          CardImages? found;
          await pumpScope(
            tester,
            CardImages.empty,
            (context) => found = CardImagesScope.of(context),
          );

          expect(found, same(CardImages.empty));
        },
      );

      testWidgets(
        'of throws without a scope',
        (tester) async {
          await pumpScope(tester, null, CardImagesScope.of);

          expect(tester.takeException(), isA<FlutterError>());
        },
      );

      testWidgets(
        'maybeOf returns null without a scope',
        (tester) async {
          CardImages? found = CardImages.empty;
          await pumpScope(
            tester,
            null,
            (context) => found = CardImagesScope.maybeOf(context),
          );

          expect(found, isNull);
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
