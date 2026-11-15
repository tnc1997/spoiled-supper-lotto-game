import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:game_engine/game_engine.dart';

import 'card_image_name.dart';

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
  /// in [files]. Files that don't match a card are ignored, and only the
  /// files that are used are read.
  static Future<CardImages> load(Iterable<CardImageFile> files) async {
    final filesByName = <String, CardImageFile>{};
    for (final file in files) {
      filesByName.putIfAbsent(file.name.toLowerCase(), () => file);
    }

    final bytesByImageName = <String, Uint8List>{};
    for (final imageName in cardImageNames.values) {
      for (final extension in cardImageExtensions) {
        final file = filesByName['$imageName.$extension'];
        if (file != null) {
          bytesByImageName[imageName] = await file.readAsBytes();
          break;
        }
      }
    }

    return CardImages._(bytesByImageName);
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
