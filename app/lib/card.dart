import 'dart:ui' as ui;

import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Card;

import 'card_images_scope.dart';
import 'card_semantic_label.dart';
import 'placeholder_card.dart';

/// Shows a [card]. Use this wherever a card is shown, rather than a
/// [PlaceholderCard] or an image directly.
///
/// It shows the player's own image of the card, from the closest
/// `CardImagesScope`, or a [PlaceholderCard] if there isn't one. Either
/// way, the card has the same shape and size, is laid out and scaled like a
/// [PlaceholderCard], and is announced the same, so swapping one for the
/// other doesn't move anything.
class Card extends StatelessWidget {
  /// The card to show.
  final engine.Card card;

  /// Shows [card].
  const Card({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final image = CardImagesScope.maybeOf(context)?[card];

    if (image == null) {
      return PlaceholderCard(card: card);
    }

    return _ImageCard(card: card, image: image);
  }
}

/// The player's own [image] of [card], filling a card's shape.
///
/// The image is already decoded by `CardImages`, so it is painted straight
/// away, at any size, without decoding it again. An image of a different
/// shape is cropped from its centre to fill the card.
class _ImageCard extends StatelessWidget {
  final engine.Card card;
  final ui.Image image;

  const _ImageCard({required this.card, required this.image});

  @override
  Widget build(BuildContext context) {
    // Announces the card like a placeholder, rather than as an image.
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: card.semanticLabel,
      // Scales the whole card to fit its parent, like a placeholder.
      child: FittedBox(
        child: SizedBox.fromSize(
          size: PlaceholderCard.size,
          child: RawImage(
            image: image,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}
