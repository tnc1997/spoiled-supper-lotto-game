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
///
/// A typical lifecycle:
///
/// 1. The player chooses their files, and [pick] loads them, or a test
///    loads its own files with [load].
/// 2. The resulting [CardImagesData] is given to a `CardImages` widget with
///    `CardImages.of(context).images = data`, so that every `Card`
///    widget below it can look up its image with `images[card]`. The
///    widget owns them from then on.
/// 3. When the player chooses other images, the widget replaces the old
///    [CardImagesData] with them and then [dispose]s of the old ones.
class CardImagesData {
  /// The extensions, without a dot, that a player's own card images can
  /// have, in the order they are tried.
  ///
  /// If a player has more than one image of a card, e.g. `fish-fingers.png`
  /// and `fish-fingers.jpg`, the one whose extension comes first is used.
  ///
  /// This is also the filter the file picker in [pick] offers, so the player
  /// can only choose files with these extensions.
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

  /// No images, so that every card is shown as a `PlaceholderCard`, e.g.
  /// before the player has chosen theirs.
  ///
  /// It holds nothing to free, so disposing of it does nothing.
  static const empty = CardImagesData._({});

  /// The images, keyed by [engine.Card.id].
  ///
  /// A card without an image has no entry, rather than a `null` one, so
  /// looking it up with `images[card]` returns `null`.
  final Map<String, ui.Image> _imagesById;

  /// Creates images from [_imagesById].
  ///
  /// Private, so that the only way to create [CardImagesData] is with [load] or
  /// [pick], which decode the images that this then owns and disposes of.
  const CardImagesData._(this._imagesById);

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
  ///
  /// How it works:
  ///
  /// 1. Indexes [files] by their lowercased names, e.g. `fish-fingers.png`,
  ///    so that each card's file can be found with a single lookup.
  /// 2. For each card in [cardImageNames], finds its file with [_fileOf],
  ///    and if there is one, starts loading it with [_load]. Every load is
  ///    started before any is waited for, so they run at the same time.
  /// 3. Waits for every load to finish, drops the ones that failed, and
  ///    keeps the rest, keyed by card ID.
  static Future<CardImagesData> load(Iterable<XFile> files) async {
    // Step 1: index the files by their lowercased names, so that a lookup
    // ignores case. putIfAbsent keeps the first of several files whose
    // names differ only in case, e.g. `Milk.png` and `milk.png` on Linux.
    final filesByName = <String, XFile>{};
    for (final file in files) {
      filesByName.putIfAbsent(file.name.toLowerCase(), () => file);
    }

    // Step 2: start loading each card's file, if it has one. Calling _load
    // starts the work straight away and returns a Future for its result,
    // so this list holds one running load per card with a file. A card
    // without a file adds nothing, so its file is never read.
    final loads = <Future<MapEntry<String, ui.Image>?>>[
      for (final MapEntry(key: id, value: imageName) in cardImageNames.entries)
        if (_fileOf(imageName, filesByName) case final file?) _load(id, file),
    ];

    // Step 3: wait for every load at once. Each gives either an entry from
    // the card's ID to its image, or null if it failed, so nonNulls drops
    // the failures and Map.fromEntries builds the map from the rest.
    return CardImagesData._(
      Map.fromEntries((await Future.wait(loads)).nonNulls),
    );
  }

  /// Returns the file in [filesByName] that holds the image named
  /// [imageName], trying each of the [imageExtensions] in order, or
  /// `null` if there isn't one.
  ///
  /// [filesByName] is keyed by lowercased file name, and [imageName] is
  /// always lowercase, so this finds a file whatever the case of its name.
  ///
  /// For example, for `fish-fingers` it looks up `fish-fingers.png`, then
  /// `fish-fingers.jpg`, then `fish-fingers.jpeg`, then `fish-fingers.webp`,
  /// and returns the first that exists.
  static XFile? _fileOf(
    String imageName,
    Map<String, XFile> filesByName,
  ) {
    for (final extension in imageExtensions) {
      // Returns as soon as one is found, so an earlier extension wins.
      if (filesByName['$imageName.$extension'] case final file?) {
        return file;
      }
    }

    return null;
  }

  /// Reads and decodes [file], the image of the card with the given [id],
  /// or returns `null` and reports the error if it can't be.
  ///
  /// Returns a [MapEntry] from [id] to the image, rather than just the
  /// image, so that [load] can build its map straight from the results of
  /// every load, without having to match each result back to its card.
  ///
  /// Never throws, so that one bad file can't make [load] fail for every
  /// card.
  static Future<MapEntry<String, ui.Image>?> _load(
    String id,
    XFile file,
  ) async {
    try {
      // Reads the whole file into memory, then decodes it. The bytes are
      // only needed until the image is decoded, so nothing keeps them.
      return MapEntry(id, await _decode(await file.readAsBytes()));
    } catch (exception, stack) {
      // Catches everything, since a failed read on the web throws a
      // JavaScript error rather than an Exception.
      //
      // Reports the error, rather than ignoring it, so that it shows in the
      // console and in error reporting, naming the file that failed, while
      // the card falls back to a placeholder.
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
  ///
  /// "Covers" means both its width and its height are at least those of
  /// [imageSize], like `BoxFit.cover`, so that when the `Card` widget crops
  /// it to a card's shape, it never has to scale it up. For example:
  ///
  /// * A 2080x3328px scan, a card's shape, is decoded at 520x832px.
  /// * A 2000x2000px photo, square, is decoded at 832x832px, since its
  ///   height must be at least 832px.
  /// * A 100x160px image, smaller than [imageSize], is decoded at its own
  ///   size, since scaling it up would use more memory without adding
  ///   detail.
  ///
  /// Decoding straight at the reduced size, rather than at full size and
  /// then scaling down, means the full-size image is never held in memory.
  static Future<ui.Image> _decode(Uint8List bytes) async {
    // Copies the bytes into a buffer that the engine can decode from.
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);

    // Creates a codec, which decodes the image. Once the codec has read the
    // image's header, it calls getTargetSize with the image's full size, and
    // decodes the image at whichever size that returns.
    final codec = await ui.instantiateImageCodecWithSize(
      buffer,
      getTargetSize: (width, height) {
        // The scale that makes the image just cover imageSize: the larger
        // of the scales that make its width and its height match, so that
        // neither ends up smaller than imageSize.
        final scale = max(
          imageSize.width / width,
          imageSize.height / height,
        );

        // A scale of 1 or more means the image is already no bigger than
        // it needs to be, so it is decoded at its own size.
        if (scale >= 1) {
          return ui.TargetImageSize();
        }

        // Otherwise, scales it down, rounding up so that it never ends up
        // a pixel short of imageSize.
        return ui.TargetImageSize(
          width: (width * scale).ceil(),
          height: (height * scale).ceil(),
        );
      },
    );

    try {
      // Decodes the first frame. A still image only has one; an animated
      // image, e.g. an animated WebP, is shown as its first frame.
      return (await codec.getNextFrame()).image;
    } finally {
      // Frees the codec whether or not decoding succeeded. The image it
      // decoded lives on, owned by this CardImagesData until dispose.
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
  ///
  /// The player can choose any number of files at once, but only files with
  /// one of the [imageExtensions]. On the web, where a folder can't be
  /// chosen, they can select every file in their folder instead.
  static Future<CardImagesData?> pick() async {
    // Opens the platform's file picker, and waits for the player to choose
    // files or cancel.
    final files = await FilePicker.pickFiles(
      dialogTitle: 'Choose your card images',
      type: FileType.custom,
      allowedExtensions: imageExtensions,
    );

    // The picker gives no files if the player cancels.
    if (files.isEmpty) {
      return null;
    }

    // The picker gives its own PlatformFile for each file, which can give
    // the cross-platform XFile that load takes.
    return load([for (final file in files) file.xFile]);
  }

  /// Frees the images. They mustn't be shown afterwards.
  ///
  /// Each image holds its decoded pixels, about 1.7 MB for a card's shape,
  /// outside of Dart's garbage collector, so they are only freed when they
  /// are disposed of.
  ///
  /// A `CardImages` widget calls this once these images are replaced in it,
  /// or it's removed, so that no `Card` widget is still showing them.
  void dispose() {
    for (final image in _imagesById.values) {
      image.dispose();
    }
  }

  /// The number of cards that have an image, or 0 if none of the files
  /// chosen are named after a card, or none of them could be loaded.
  int get length => _imagesById.length;

  /// Returns the player's own image of [card], decoded to cover [imageSize],
  /// or `null` if they don't have one.
  ///
  /// For example, `images[card]` returns `null` for a card whose file the
  /// player didn't choose, or whose file couldn't be loaded, so the `Card`
  /// widget shows a `PlaceholderCard` for it instead.
  ui.Image? operator [](engine.Card card) => _imagesById[card.id];
}
