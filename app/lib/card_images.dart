import 'dart:math';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:game_engine/game_engine.dart' as engine;

import 'card_image_name.dart';
import 'card_image_picker_web_options.dart'
    if (dart.library.js_interop) 'card_image_picker_web_options_web.dart';
import 'card_size.dart';

/// The extensions, without a dot, that a player's own card images can have,
/// in the order they are tried.
///
/// If a player has more than one image of a card, e.g. `fish-fingers.png`
/// and `fish-fingers.jpg`, the one whose extension comes first is used.
const cardImageExtensions = ['png', 'jpg', 'jpeg', 'webp'];

/// A file that a player has offered as one of their own card images.
typedef CardImageFile = ({
  /// The file's name, with its extension, e.g. `fish-fingers.png`.
  String name,

  /// Reads the file's contents.
  Future<Uint8List> Function() readAsBytes,
});

/// The player's own images of the cards, loaded from files they chose.
///
/// Show a card with `CardFace`, which falls back to a `PlaceholderCard` for
/// a card without an image.
///
/// Call [dispose] once the images are no longer shown, e.g. when the player
/// chooses others.
class CardImages {
  /// No images, so every card is shown as a placeholder.
  static const empty = CardImages._({});

  /// The size, in pixels, that every image is cropped and scaled to.
  ///
  /// Twice the 260x416px card template, so that a card stays sharp up to
  /// 520 physical pixels wide, e.g. 260 logical pixels on a screen with a
  /// device pixel ratio of 2, while 30 images take about 50 MB.
  static const imageSize = Size(520, 520 / cardAspectRatio);

  final Map<String, ui.Image> _imagesByImageName;

  const CardImages._(this._imagesByImageName);

  /// Whether there are no images, so every card is shown as a placeholder.
  bool get isEmpty => _imagesByImageName.isEmpty;

  /// Loads the image of each card from [files], matching each file's name
  /// against the card's [CardImageName.imageName], e.g. `fish-fingers.png`
  /// for Fish Fingers.
  ///
  /// Names are matched case-insensitively, so `Fish-Fingers.PNG` is found on
  /// every platform. If more than one file matches a card, the one whose
  /// extension comes first in [cardImageExtensions] is used, then the first
  /// in [files]. Files that don't match a card are ignored.
  ///
  /// Only the files that are used are read, all at once. Each is cropped
  /// from its centre to a card's shape and scaled to [imageSize], so that
  /// every image is the same size however large its file, and the file
  /// itself isn't kept.
  ///
  /// A card whose file can't be read or decoded, e.g. because it was moved
  /// after it was chosen, is shown as a placeholder, without affecting the
  /// other cards. The error is reported to [FlutterError.onError].
  static Future<CardImages> load(Iterable<CardImageFile> files) async {
    final filesByName = <String, CardImageFile>{};
    for (final file in files) {
      filesByName.putIfAbsent(file.name.toLowerCase(), () => file);
    }

    final loads = <Future<MapEntry<String, ui.Image>?>>[
      for (final imageName in cardImageNames.values)
        if (_fileOf(imageName, filesByName) case final file?)
          _load(imageName, file),
    ];

    return CardImages._(
      Map.fromEntries((await Future.wait(loads)).nonNulls),
    );
  }

  /// Returns the file in [filesByName] that holds the image named
  /// [imageName], trying each of the [cardImageExtensions] in order, or
  /// `null` if there isn't one.
  static CardImageFile? _fileOf(
    String imageName,
    Map<String, CardImageFile> filesByName,
  ) {
    for (final extension in cardImageExtensions) {
      if (filesByName['$imageName.$extension'] case final file?) {
        return file;
      }
    }

    return null;
  }

  /// Reads and decodes [file], the image named [imageName], or returns
  /// `null` and reports the error if it can't be.
  static Future<MapEntry<String, ui.Image>?> _load(
    String imageName,
    CardImageFile file,
  ) async {
    try {
      return MapEntry(imageName, await _decode(await file.readAsBytes()));
    } catch (exception, stack) {
      // Catches everything, since a failed read on the web throws a
      // JavaScript error rather than an Exception.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'card images',
          context: ErrorDescription('while loading ${file.name}'),
        ),
      );

      return null;
    }
  }

  /// Decodes [bytes], cropped from the centre to a card's shape and scaled
  /// to [imageSize].
  static Future<ui.Image> _decode(Uint8List bytes) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);

    // Decodes at the smallest size that still covers imageSize, rather than
    // at the file's full size, but never larger than the file.
    final codec = await ui.instantiateImageCodecWithSize(
      buffer,
      getTargetSize: (width, height) {
        final scale = max(
          imageSize.width / width,
          imageSize.height / height,
        );

        if (scale >= 1) {
          return ui.TargetImageSize();
        }

        return ui.TargetImageSize(
          width: (width * scale).ceil(),
          height: (height * scale).ceil(),
        );
      },
    );

    final ui.Image decoded;
    try {
      decoded = (await codec.getNextFrame()).image;
    } finally {
      codec.dispose();
    }

    try {
      final source = Size(
        decoded.width.toDouble(),
        decoded.height.toDouble(),
      );
      final fitted = applyBoxFit(BoxFit.cover, source, imageSize);

      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawImageRect(
        decoded,
        Alignment.center.inscribe(fitted.source, Offset.zero & source),
        Offset.zero & imageSize,
        ui.Paint()..filterQuality = ui.FilterQuality.medium,
      );

      final picture = recorder.endRecording();
      try {
        return await picture.toImage(
          imageSize.width.toInt(),
          imageSize.height.toInt(),
        );
      } finally {
        picture.dispose();
      }
    } finally {
      decoded.dispose();
    }
  }

  /// Asks the player to choose their own card images, e.g. every file in
  /// the folder they keep them in, and loads them with [load].
  ///
  /// Returns `null` if the player cancels.
  static Future<CardImages?> pick() async {
    final files = await FilePicker.pickFiles(
      dialogTitle: 'Choose your card images',
      type: FileType.custom,
      allowedExtensions: cardImageExtensions,
      webOptions: cardImagePickerWebOptions,
    );

    if (files.isEmpty) {
      return null;
    }

    return load([
      for (final file in files)
        (name: file.name, readAsBytes: file.readAsBytes),
    ]);
  }

  /// Frees the images. They mustn't be shown afterwards.
  void dispose() {
    for (final image in _imagesByImageName.values) {
      image.dispose();
    }
  }

  /// Returns the player's own image of [card], at [imageSize], or `null` if
  /// they don't have one.
  ui.Image? of(engine.Card card) => _imagesByImageName[card.imageName];
}
