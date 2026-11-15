import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart';
import 'package:spoiled_supper_lotto_game/card_images.dart';

void main() {
  group(
    'CardImages',
    () {
      final fishFingers = buildDeck().singleWhere(
        (card) => card.id == '0d78745d-a48f-4412-a32e-d81e2911ae8b',
      );

      /// A file named [name] holding [bytes].
      CardImageFile fileOf(String name, [List<int> bytes = const [1]]) {
        return (
          name: name,
          readAsBytes: () async => Uint8List.fromList(bytes),
        );
      }

      test(
        'shows every card as a placeholder when empty',
        () {
          expect(CardImages.empty.of(fishFingers), isNull);
        },
      );

      group(
        'load',
        () {
          test(
            'finds the image of a card by its name',
            () async {
              final images = await CardImages.load([
                fileOf('fish-fingers.png', [1, 2, 3]),
              ]);

              expect(images.of(fishFingers), [1, 2, 3]);
            },
          );

          test(
            'finds an image with each of the extensions',
            () async {
              final found = <String, bool>{};
              for (final extension in cardImageExtensions) {
                final images = await CardImages.load([
                  fileOf('fish-fingers.$extension'),
                ]);
                found[extension] = images.of(fishFingers) != null;
              }

              expect(found, {
                for (final extension in cardImageExtensions) extension: true,
              });
            },
          );

          test(
            'tries the extensions in order',
            () async {
              final images = await CardImages.load([
                fileOf('fish-fingers.webp', [4]),
                fileOf('fish-fingers.jpeg', [3]),
                fileOf('fish-fingers.jpg', [2]),
                fileOf('fish-fingers.png', [1]),
              ]);

              expect(images.of(fishFingers), [1]);
            },
          );

          test(
            'tries the extensions in the order png, jpg, jpeg, webp',
            () {
              expect(cardImageExtensions, ['png', 'jpg', 'jpeg', 'webp']);
            },
          );

          test(
            'matches the name case-insensitively',
            () async {
              final images = await CardImages.load([
                fileOf('Fish-Fingers.PNG'),
              ]);

              expect(images.of(fishFingers), isNotNull);
            },
          );

          test(
            'uses the first of several files with the same name in any case',
            () async {
              final images = await CardImages.load([
                fileOf('Fish-Fingers.png', [1]),
                fileOf('fish-fingers.png', [2]),
              ]);

              expect(images.of(fishFingers), [1]);
            },
          );

          test(
            'ignores a file with another extension',
            () async {
              final images = await CardImages.load([
                fileOf('fish-fingers.gif'),
              ]);

              expect(images.isEmpty, isTrue);
            },
          );

          test(
            'ignores a file that is not named after a card',
            () async {
              final images = await CardImages.load([
                fileOf('fish fingers.png'),
              ]);

              expect(images.isEmpty, isTrue);
            },
          );

          test(
            'only reads the files that are used',
            () async {
              final read = <String>[];
              CardImageFile trackedFileOf(String name) {
                return (
                  name: name,
                  readAsBytes: () async {
                    read.add(name);
                    return Uint8List(1);
                  },
                );
              }

              await CardImages.load([
                trackedFileOf('fish-fingers.jpg'),
                trackedFileOf('fish-fingers.png'),
                trackedFileOf('holiday.png'),
              ]);

              expect(read, ['fish-fingers.png']);
            },
          );

          test(
            'shows a card without a file as a placeholder',
            () async {
              final images = await CardImages.load([
                fileOf('sausages.png'),
              ]);

              expect(images.of(fishFingers), isNull);
            },
          );
        },
      );
    },
  );
}
