import 'package:flutter/widgets.dart';

import 'card_images.dart';

/// Holds the player's own [CardImages] for as long as it's shown, e.g. for
/// the whole session above the app's navigator, and exposes them to the
/// widgets below it, such as the `Card` widget, rebuilding the ones that
/// depend on them whenever they change.
///
/// Read them with `CardImagesScope.of(context).images`, and choose others
/// with `CardImagesScope.of(context).replace(images)`.
class CardImagesScope extends StatefulWidget {
  /// The widget below this in the tree.
  final Widget child;

  /// Holds the player's card images for [child], starting with
  /// [CardImages.empty].
  const CardImagesScope({super.key, required this.child});

  /// Returns the state of the closest [CardImagesScope] above [context],
  /// holding its images, and rebuilds [context] whenever they change.
  ///
  /// Throws a [FlutterError] if there is no [CardImagesScope] above
  /// [context].
  static CardImagesScopeState of(BuildContext context) {
    final scope = maybeOf(context);

    if (scope == null) {
      throw FlutterError(
        'CardImagesScope.of() called with a context that does not contain a CardImagesScope.',
      );
    }

    return scope;
  }

  /// Returns the state of the closest [CardImagesScope] above [context],
  /// holding its images, or `null` if there isn't one, and rebuilds
  /// [context] whenever they change.
  static CardImagesScopeState? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_CardImagesInheritedScope>()
        ?.scope;
  }

  @override
  State<CardImagesScope> createState() => CardImagesScopeState();
}

/// The state of a [CardImagesScope], owning the player's card images.
class CardImagesScopeState extends State<CardImagesScope> {
  CardImages _images = CardImages.empty;

  /// The player's own card images, or [CardImages.empty] until they choose
  /// some.
  CardImages get images => _images;

  @override
  void dispose() {
    _images.dispose();

    super.dispose();
  }

  /// Uses [images] in place of the ones used before, disposing of those.
  ///
  /// The scope then owns [images], and disposes of them in turn once
  /// they're replaced or it's removed.
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
    // Only the inherited scope is rebuilt when the images change; the child
    // is the same widget, so only the widgets that depend on it rebuild.
    return _CardImagesInheritedScope(
      scope: this,
      images: _images,
      child: widget.child,
    );
  }
}

/// Exposes a [CardImagesScopeState] to the widgets below it, notifying the
/// ones that depend on it whenever its images change.
class _CardImagesInheritedScope extends InheritedWidget {
  /// The scope whose images are exposed.
  final CardImagesScopeState scope;

  /// The scope's images when this was built, to tell when they change, since
  /// [scope] is the same object either way.
  final CardImages images;

  const _CardImagesInheritedScope({
    required this.scope,
    required this.images,
    required super.child,
  });

  @override
  bool updateShouldNotify(_CardImagesInheritedScope oldWidget) {
    return images != oldWidget.images;
  }
}
