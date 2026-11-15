import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:game_engine/game_engine.dart';

import 'card_image_name.dart';
import 'card_image_picker_web_options.dart'
    if (dart.library.js_interop) 'card_image_picker_web_options_web.dart';

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
class CardImages {
  /// No images, so every card is shown as a placeholder.
  static const empty = CardImages._({});

  final Map<String, Uint8List> _bytesByImageName;

  const CardImages._(this._bytesByImageName);

  /// Whether there are no images, so every card is shown as a placeholder.
  bool get isEmpty => _bytesByImageName.isEmpty;

  /// Loads the image of each card from [files], matching each file's name
  /// against the card's [CardImageName.imageName], e.g. `fish-fingers.png`
  /// for Fish Fingers.
  ///
  /// Names are matched case-insensitively, so `Fish-Fingers.PNG` is found on
  /// every platform. If more than one file matches a card, the one whose
  /// extension comes first in [cardImageExtensions] is used, then the first
  /// in [files]. Files that don't match a card are ignored.
  ///
  /// Only the files that are used are read, all at once. A card whose file
  /// can't be read, e.g. because it was moved after it was chosen, is shown
  /// as a placeholder, without affecting the other cards.
  static Future<CardImages> load(Iterable<CardImageFile> files) async {
    final filesByName = <String, CardImageFile>{};
    for (final file in files) {
      filesByName.putIfAbsent(file.name.toLowerCase(), () => file);
    }

    final reads = <Future<MapEntry<String, Uint8List>?>>[
      for (final imageName in cardImageNames.values)
        if (_fileOf(imageName, filesByName) case final file?)
          _read(imageName, file),
    ];

    return CardImages._(
      Map.fromEntries((await Future.wait(reads)).nonNulls),
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

  /// Reads [file], the image named [imageName], or returns `null` if it
  /// can't be read.
  static Future<MapEntry<String, Uint8List>?> _read(
    String imageName,
    CardImageFile file,
  ) async {
    try {
      return MapEntry(imageName, await file.readAsBytes());
    } catch (_) {
      // Catches everything, since a failed read on the web throws a
      // JavaScript error rather than an Exception.
      return null;
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

  /// Returns the contents of the player's own image of [card], or `null` if
  /// they don't have one.
  Uint8List? of(Card card) => _bytesByImageName[card.imageName];
}
