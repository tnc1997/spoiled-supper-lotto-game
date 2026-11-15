import 'dart:math';
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:game_engine/game_engine.dart' as engine;

import 'card_aspect_ratio.dart';
import 'card_image_name.dart';

/// The player's own images of the cards, loaded from files they chose.
///
/// Show a card with the `Card` widget, which falls back to a
/// `PlaceholderCard` for a card without an image.
///
/// Call [dispose] once the images are no longer shown, e.g. when the player
/// chooses others.
class CardImages {
  /// No images, so every card is shown as a placeholder.
  static const empty = CardImages._({});

  /// The extensions, without a dot, that a player's own card images can
  /// have, in the order they are tried.
  ///
  /// If a player has more than one image of a card, e.g. `fish-fingers.png`
  /// and `fish-fingers.jpg`, the one whose extension comes first is used.
  static const imageExtensions = ['png', 'jpg', 'jpeg', 'webp'];

  /// The size, in pixels, that every image is decoded to cover.
  ///
  /// Each image is decoded at the smallest size that covers this, keeping
  /// its shape, or at its own size if it is smaller, and cropped to a card's
  /// shape when it is shown.
  ///
  /// Twice the 260x416px card template, so that a card stays sharp up to
  /// 520 physical pixels wide, e.g. 260 logical pixels on a screen with a
  /// device pixel ratio of 2, while 30 images in a card's shape take about
  /// 50 MB.
  static const imageSize = ui.Size(520, 520 / cardAspectRatio);

  /// The images, keyed by [engine.Card.id].
  final Map<String, ui.Image> _imagesById;

  const CardImages._(this._imagesById);

  /// Whether there are no images, so every card is shown as a placeholder.
  bool get isEmpty => _imagesById.isEmpty;

  /// Loads the image of each card from [files], matching each file's name
  /// against the card's [CardImageName.imageName], e.g. `fish-fingers.png`
  /// for Fish Fingers.
  ///
  /// Names are matched case-insensitively, so `Fish-Fingers.PNG` is found on
  /// every platform. If more than one file matches a card, the one whose
  /// extension comes first in [imageExtensions] is used, then the first
  /// in [files]. Files that don't match a card are ignored.
  ///
  /// Only the files that are used are read, all at once. Each is decoded at
  /// no more than the size needed to cover [imageSize], so that an image
  /// takes about the same memory however large its file, and the file
  /// itself isn't kept.
  ///
  /// A card whose file can't be read or decoded, e.g. because it was moved
  /// after it was chosen, is shown as a placeholder, without affecting the
  /// other cards. The error is reported to [FlutterError.onError].
  static Future<CardImages> load(Iterable<XFile> files) async {
    final filesByName = <String, XFile>{};
    for (final file in files) {
      filesByName.putIfAbsent(file.name.toLowerCase(), () => file);
    }

    final loads = <Future<MapEntry<String, ui.Image>?>>[
      for (final MapEntry(key: id, value: imageName) in cardImageNames.entries)
        if (_fileOf(imageName, filesByName) case final file?) _load(id, file),
    ];

    return CardImages._(
      Map.fromEntries((await Future.wait(loads)).nonNulls),
    );
  }

  /// Returns the file in [filesByName] that holds the image named
  /// [imageName], trying each of the [imageExtensions] in order, or
  /// `null` if there isn't one.
  static XFile? _fileOf(
    String imageName,
    Map<String, XFile> filesByName,
  ) {
    for (final extension in imageExtensions) {
      if (filesByName['$imageName.$extension'] case final file?) {
        return file;
      }
    }

    return null;
  }

  /// Reads and decodes [file], the image of the card with the given [id],
  /// or returns `null` and reports the error if it can't be.
  static Future<MapEntry<String, ui.Image>?> _load(
    String id,
    XFile file,
  ) async {
    try {
      return MapEntry(id, await _decode(await file.readAsBytes()));
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

  /// Decodes [bytes] at the smallest size that covers [imageSize], keeping
  /// its shape, or at its own size if it is smaller.
  static Future<ui.Image> _decode(Uint8List bytes) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
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

    try {
      return (await codec.getNextFrame()).image;
    } finally {
      codec.dispose();
    }
  }

  /// Asks the player to choose their own card images, e.g. every file in
  /// the folder they keep them in, and loads them with [load].
  ///
  /// Returns `null` if the player cancels.
  ///
  /// On the web, the picker reads every chosen file before it returns, not
  /// just the ones [load] uses, but they are only held until [load] is done.
  static Future<CardImages?> pick() async {
    final files = await FilePicker.pickFiles(
      dialogTitle: 'Choose your card images',
      type: FileType.custom,
      allowedExtensions: imageExtensions,
    );

    if (files.isEmpty) {
      return null;
    }

    return load([for (final file in files) file.xFile]);
  }

  /// Frees the images. They mustn't be shown afterwards.
  void dispose() {
    for (final image in _imagesById.values) {
      image.dispose();
    }
  }

  /// Returns the player's own image of [card], decoded to cover [imageSize],
  /// or `null` if they don't have one.
  ui.Image? of(engine.Card card) => _imagesById[card.id];
}
