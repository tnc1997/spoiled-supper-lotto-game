import 'package:flutter/widgets.dart';

import 'card_images.dart';
import 'card_images_scope.dart';

/// Holds the player's own [CardImages] for as long as it's shown, e.g. for
/// the whole session above the app's navigator, and exposes them to the
/// widgets below it through a [CardImagesScope].
///
/// Choose other images with `CardImagesHost.of(context).replace(images)`.
class CardImagesHost extends StatefulWidget {
  /// The widget below this in the tree.
  final Widget child;

  /// Holds the player's card images for [child], starting with
  /// [CardImages.empty].
  const CardImagesHost({super.key, required this.child});

  /// Returns the state of the closest [CardImagesHost] above [context], to
  /// replace its images.
  ///
  /// Throws a [FlutterError] if there is no [CardImagesHost] above
  /// [context].
  static CardImagesHostState of(BuildContext context) {
    final host = context.findAncestorStateOfType<CardImagesHostState>();

    if (host == null) {
      throw FlutterError(
        'CardImagesHost.of() called with a context that does not contain a CardImagesHost.',
      );
    }

    return host;
  }

  @override
  State<CardImagesHost> createState() => CardImagesHostState();
}

/// The state of a [CardImagesHost], owning the player's card images.
class CardImagesHostState extends State<CardImagesHost> {
  CardImages _images = CardImages.empty;

  /// The player's own card images, or [CardImages.empty] until they choose
  /// some.
  ///
  /// To show them, read them with `CardImagesScope.of(context)` instead,
  /// which rebuilds whenever they change.
  CardImages get images => _images;

  @override
  void dispose() {
    _images.dispose();

    super.dispose();
  }

  /// Uses [images] in place of the ones used before, disposing of those.
  ///
  /// The host then owns [images], and disposes of them in turn once they're
  /// replaced or it's removed.
  void replace(CardImages images) {
    if (identical(images, _images)) {
      return;
    }

    final oldImages = _images;
    setState(() => _images = images);

    // The Card widgets showing the old images haven't rebuilt yet, but it's
    // safe to dispose of them straight away: each RawImage paints its own
    // clone of an image, which it disposes of itself once it's given
    // another.
    oldImages.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only the scope is rebuilt when the images change; the child is the
    // same widget, so only the widgets that depend on the scope rebuild.
    return CardImagesScope(images: _images, child: widget.child);
  }
}
