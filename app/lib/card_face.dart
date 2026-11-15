import 'dart:typed_data';

import 'package:game_engine/game_engine.dart';
import 'package:material_ui/material_ui.dart' hide Card;

import 'card_images_scope.dart';
import 'card_semantic_label.dart';
import 'placeholder_card.dart';

/// The face of a [card]: the player's own image of it, from the closest
/// `CardImagesScope`, or a [PlaceholderCard] if they don't have one or it
/// can't be shown.
///
/// Either way, the card has the same shape and size, and is laid out and
/// scaled like a [PlaceholderCard], so swapping one for the other doesn't
/// move anything.
class CardFace extends StatelessWidget {
  /// The card to show.
  final Card card;

  /// Shows [card].
  const CardFace({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final image = CardImagesScope.of(context).of(card);

    if (image == null) {
      return PlaceholderCard(card: card);
    }

    return _ImageCard(card: card, image: image);
  }
}

/// The player's own [image] of [card], filling a card's shape.
class _ImageCard extends StatelessWidget {
  final Card card;
  final Uint8List image;

  const _ImageCard({required this.card, required this.image});

  @override
  Widget build(BuildContext context) {
    // Scales the whole card to fit its parent, like a placeholder.
    return FittedBox(
      child: SizedBox.fromSize(
        size: PlaceholderCard.size,
        child: Image.memory(
          image,
          // Crops, rather than stretches, an image of a different shape.
          fit: BoxFit.cover,
          semanticLabel: card.semanticLabel,
          errorBuilder: (context, error, stackTrace) {
            return PlaceholderCard(card: card);
          },
        ),
      ),
    );
  }
}
