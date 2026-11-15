import 'dart:async';
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:spoiled_supper_lotto_game/card_images.dart';

/// Returns a PNG [width]x[height]px, made of [colors] in equal vertical
/// stripes from left to right.
Future<Uint8List> pngOf(
  List<ui.Color> colors, {
  int width = 10,
  int height = 16,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final stripe = width / colors.length;
  for (final (index, color) in colors.indexed) {
    canvas.drawRect(
      ui.Rect.fromLTWH(stripe * index, 0, stripe, height.toDouble()),
      ui.Paint()..color = color,
    );
  }

  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  picture.dispose();
  image.dispose();

  return data!.buffer.asUint8List();
}

/// Returns the colour of the pixel of [image] at ([x], [y]).
Future<ui.Color> colorOf(ui.Image image, int x, int y) async {
  final data = await image.toByteData();
  final offset = (y * image.width + x) * 4;

  return ui.Color.fromARGB(
    data!.getUint8(offset + 3),
    data.getUint8(offset),
    data.getUint8(offset + 1),
    data.getUint8(offset + 2),
  );
}

/// Matches a colour within a small distance of [expected] in each channel,
/// allowing for filtering when an image is scaled.
Matcher isCloseToColor(ui.Color expected) {
  return predicate<ui.Color>(
    (actual) =>
        (actual.r - expected.r).abs() < 0.05 &&
        (actual.g - expected.g).abs() < 0.05 &&
        (actual.b - expected.b).abs() < 0.05,
    'close to $expected',
  );
}

/// A file named [name] that reads its contents with [read].
class _FakeFile extends Fake implements XFile {
  @override
  final String name;

  final Future<Uint8List> Function() read;

  _FakeFile(this.name, this.read);

  @override
  Future<Uint8List> readAsBytes() => read();
}

void main() {
  group(
    'CardImages',
    () {
      const red = ui.Color(0xFFFF0000);
      const green = ui.Color(0xFF00FF00);
      const blue = ui.Color(0xFF0000FF);

      final deck = engine.buildDeck();
      final fishFingers = deck.singleWhere(
        (card) => card.id == '0d78745d-a48f-4412-a32e-d81e2911ae8b',
      );
      final sausages = deck.singleWhere(
        (card) => card.id == 'b2590d89-4580-40c7-8b33-3c92fc6b347d',
      );

      late Uint8List redPng;
      late Uint8List greenPng;

      setUpAll(() async {
        redPng = await pngOf([red]);
        greenPng = await pngOf([green]);
      });

      /// A file named [name] holding [bytes], or a red PNG.
      XFile fileOf(String name, [Uint8List? bytes]) {
        // Gives the name as the path too, since only the web takes the
        // name from the name.
        return XFile.fromData(bytes ?? redPng, name: name, path: name);
      }

      /// A file named [name] that can't be read, since it doesn't exist.
      XFile unreadableFileOf(String name) {
        return XFile('missing/$name');
      }

      /// Loads [files], disposing of the images after the test.
      Future<CardImages> load(Iterable<XFile> files) async {
        final images = await CardImages.load(files);
        addTearDown(images.dispose);

        return images;
      }

      /// Collects the errors reported to [FlutterError.onError] during the
      /// test, rather than printing them.
      List<FlutterErrorDetails> collectErrors() {
        final errors = <FlutterErrorDetails>[];
        final onError = FlutterError.onError;
        FlutterError.onError = errors.add;
        addTearDown(() => FlutterError.onError = onError);

        return errors;
      }

      test(
        'shows every card as a placeholder when empty',
        () {
          expect(CardImages.empty.of(fishFingers), isNull);
        },
      );

      test(
        'scales every image to twice the card template',
        () {
          expect(CardImages.imageSize, const ui.Size(520, 832));
        },
      );

      group(
        'load',
        () {
          test(
            'finds the image of a card by its name',
            () async {
              final images = await load([fileOf('fish-fingers.png')]);

              expect(images.of(fishFingers), isNotNull);
            },
          );

          test(
            'finds an image with each of the extensions',
            () async {
              final found = <String, bool>{};
              for (final extension in cardImageExtensions) {
                final images = await load([fileOf('fish-fingers.$extension')]);
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
              final images = await load([
                fileOf('fish-fingers.webp'),
                fileOf('fish-fingers.jpeg'),
                fileOf('fish-fingers.jpg'),
                fileOf('fish-fingers.png', greenPng),
              ]);

              expect(
                await colorOf(images.of(fishFingers)!, 0, 0),
                isCloseToColor(green),
              );
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
              final images = await load([fileOf('Fish-Fingers.PNG')]);

              expect(images.of(fishFingers), isNotNull);
            },
          );

          test(
            'uses the first of several files with the same name in any case',
            () async {
              final images = await load([
                fileOf('Fish-Fingers.png', greenPng),
                fileOf('fish-fingers.png'),
              ]);

              expect(
                await colorOf(images.of(fishFingers)!, 0, 0),
                isCloseToColor(green),
              );
            },
          );

          test(
            'ignores a file with another extension',
            () async {
              final images = await load([fileOf('fish-fingers.gif')]);

              expect(images.isEmpty, isTrue);
            },
          );

          test(
            'ignores a file that is not named after a card',
            () async {
              final images = await load([fileOf('fish fingers.png')]);

              expect(images.isEmpty, isTrue);
            },
          );

          test(
            'only reads the files that are used',
            () async {
              final read = <String>[];
              XFile trackedFileOf(String name) {
                return _FakeFile(name, () async {
                  read.add(name);
                  return redPng;
                });
              }

              await load([
                trackedFileOf('fish-fingers.jpg'),
                trackedFileOf('fish-fingers.png'),
                trackedFileOf('holiday.png'),
              ]);

              expect(read, ['fish-fingers.png']);
            },
          );

          test(
            'starts reading every file before any has been read',
            () async {
              final started = <String>[];
              final read = Completer<Uint8List>();
              XFile blockedFileOf(String name) {
                return _FakeFile(name, () {
                  started.add(name);
                  return read.future;
                });
              }

              final images = load([
                blockedFileOf('fish-fingers.png'),
                blockedFileOf('sausages.png'),
              ]);
              await Future<void>.delayed(Duration.zero);
              read.complete(redPng);
              await images;

              expect(
                started,
                unorderedEquals(['fish-fingers.png', 'sausages.png']),
              );
            },
          );

          test(
            'scales a small image up to the image size',
            () async {
              final images = await load([fileOf('fish-fingers.png')]);
              final image = images.of(fishFingers)!;

              expect(
                ui.Size(image.width.toDouble(), image.height.toDouble()),
                CardImages.imageSize,
              );
            },
          );

          test(
            'scales a large image down to the image size',
            () async {
              final images = await load([
                fileOf(
                  'fish-fingers.png',
                  await pngOf([red], width: 2000, height: 3200),
                ),
              ]);
              final image = images.of(fishFingers)!;

              expect(
                ui.Size(image.width.toDouble(), image.height.toDouble()),
                CardImages.imageSize,
              );
            },
          );

          test(
            'crops a wider image to the centre',
            () async {
              // Three times a card's width, so a card's shape from the
              // centre is all green.
              final images = await load([
                fileOf(
                  'fish-fingers.png',
                  await pngOf([red, green, blue], width: 30),
                ),
              ]);
              final image = images.of(fishFingers)!;

              expect(
                [
                  await colorOf(image, 26, 416),
                  await colorOf(image, 493, 416),
                ],
                everyElement(isCloseToColor(green)),
              );
            },
          );

          test(
            'shows a card whose file cannot be read as a placeholder',
            () async {
              collectErrors();
              final images = await load([unreadableFileOf('fish-fingers.png')]);

              expect(images.of(fishFingers), isNull);
            },
          );

          test(
            'shows a card whose file cannot be decoded as a placeholder',
            () async {
              collectErrors();
              final images = await load([
                fileOf('fish-fingers.png', Uint8List.fromList([1, 2, 3])),
              ]);

              expect(images.of(fishFingers), isNull);
            },
          );

          test(
            'reports a file that cannot be read',
            () async {
              final errors = collectErrors();
              await load([unreadableFileOf('fish-fingers.png')]);

              expect(
                errors.map((error) => error.context.toString()),
                ['while loading fish-fingers.png'],
              );
            },
          );

          test(
            'keeps the other images when a file cannot be read',
            () async {
              collectErrors();
              final images = await load([
                unreadableFileOf('fish-fingers.png'),
                fileOf('sausages.png'),
              ]);

              expect(images.of(sausages), isNotNull);
            },
          );

          test(
            'shows a card without a file as a placeholder',
            () async {
              final images = await load([fileOf('sausages.png')]);

              expect(images.of(fishFingers), isNull);
            },
          );
        },
      );
    },
  );
}
