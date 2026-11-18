import 'package:flutter/widgets.dart';

import 'card_images_data.dart';

/// Holds the player's own card images for as long as it's shown, e.g. for
/// the whole session above the app's navigator, and exposes them to the
/// widgets below it, such as the `Card` widget, rebuilding the ones that
/// depend on them whenever they change.
///
/// Read them with `CardImages.of(context).images`, and choose others with
/// `CardImages.of(context).images = data`.
class CardImages extends StatefulWidget {
  /// The widget below this in the tree.
  final Widget child;

  /// Holds the player's card images for [child], starting with
  /// [CardImagesData.empty].
  const CardImages({super.key, required this.child});

  /// Returns the state of the closest [CardImages] above [context], holding
  /// its images, and rebuilds [context] whenever they change.
  ///
  /// Throws a [FlutterError] if there is no [CardImages] above [context].
  static CardImagesState of(BuildContext context) {
    final state = maybeOf(context);

    if (state == null) {
      throw FlutterError(
        'CardImages.of() called with a context that does not contain a CardImages.',
      );
    }

    return state;
  }

  /// Returns the state of the closest [CardImages] above [context], holding
  /// its images, or `null` if there isn't one, and rebuilds [context]
  /// whenever they change.
  static CardImagesState? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_CardImagesScope>()
        ?.state;
  }

  @override
  State<CardImages> createState() => CardImagesState();
}

/// The state of a [CardImages], owning the player's card images.
class CardImagesState extends State<CardImages> {
  CardImagesData _images = CardImagesData.empty;

  /// The player's own card images, or [CardImagesData.empty] until they
  /// choose some.
  CardImagesData get images => _images;

  /// Uses [value] in place of the images used before, rebuilding the
  /// widgets that depend on them, and disposes of the images used before.
  ///
  /// This then owns [value], and disposes of it in turn once it's replaced
  /// or this is removed, so the caller mustn't dispose of it.
  set images(CardImagesData value) {
    if (identical(value, _images)) {
      return;
    }

    final oldImages = _images;
    setState(() => _images = value);

    // The Card widgets showing the old images haven't rebuilt yet, but it's
    // safe to dispose of them straight away: each RawImage paints its own
    // clone of an image, which it disposes of itself once it's given
    // another.
    oldImages.dispose();
  }

  @override
  void dispose() {
    _images.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only the scope is rebuilt when the images change; the child is the
    // same widget, so only the widgets that depend on the scope rebuild.
    return _CardImagesScope(
      state: this,
      images: _images,
      child: widget.child,
    );
  }
}

/// Exposes a [CardImagesState] to the widgets below it, notifying the ones
/// that depend on it whenever its images change.
class _CardImagesScope extends InheritedWidget {
  /// The state whose images are exposed.
  final CardImagesState state;

  /// The state's images when this was built, to tell when they change, since
  /// [state] is the same object either way.
  final CardImagesData images;

  const _CardImagesScope({
    required this.state,
    required this.images,
    required super.child,
  });

  @override
  bool updateShouldNotify(_CardImagesScope oldWidget) {
    return images != oldWidget.images;
  }
}
