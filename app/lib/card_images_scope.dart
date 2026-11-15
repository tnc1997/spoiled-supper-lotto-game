import 'package:flutter/widgets.dart';

import 'card_images.dart';

/// Exposes the player's own [CardImages] to the widgets below it, such as
/// `CardFace`, rebuilding the ones that depend on it whenever they change.
class CardImagesScope extends InheritedWidget {
  /// The player's own images of the cards.
  final CardImages images;

  /// Exposes [images] to [child].
  ///
  /// Pass different images, e.g. once the player has chosen theirs, and
  /// dependents rebuild with them.
  const CardImagesScope({
    super.key,
    required this.images,
    required super.child,
  });

  /// Returns the images of the closest [CardImagesScope] above [context],
  /// and rebuilds [context] whenever they change.
  ///
  /// Throws a [FlutterError] if there is no [CardImagesScope] above
  /// [context].
  static CardImages of(BuildContext context) {
    final images = maybeOf(context);

    if (images == null) {
      throw FlutterError(
        'CardImagesScope.of() called with a context that does not contain a CardImagesScope.',
      );
    }

    return images;
  }

  /// Returns the images of the closest [CardImagesScope] above [context],
  /// or `null` if there isn't one, and rebuilds [context] whenever they
  /// change.
  static CardImages? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CardImagesScope>()
        ?.images;
  }

  @override
  bool updateShouldNotify(CardImagesScope oldWidget) {
    return images != oldWidget.images;
  }
}
