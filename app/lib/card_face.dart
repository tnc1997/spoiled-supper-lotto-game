import 'dart:math';
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
///
/// Shows a [PlaceholderCard] while the image is decoded, or if it can't be.
class _ImageCard extends StatelessWidget {
  /// Rounds the height the image is decoded at up to a multiple of this,
  /// so that resizing the card only decodes it again at each step.
  static const _decodeStep = 64;

  final Card card;
  final Uint8List image;

  const _ImageCard({required this.card, required this.image});

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // The height the card is shown at, once scaled to fit, worked out
        // the same way as the FittedBox does.
        final height = constraints
            .constrainSizeAndAttemptToPreserveAspectRatio(PlaceholderCard.size)
            .height;

        // Scales the whole card to fit its parent, like a placeholder.
        return FittedBox(
          child: SizedBox.fromSize(
            size: PlaceholderCard.size,
            child: Image.memory(
              image,
              // Decodes the image at the size it is shown, rather than its
              // full size. Only the height is given, so that the image keeps
              // its shape; it is a card's shape, or close to it, so its
              // width is about what is needed too.
              cacheHeight:
                  max(1, (height * devicePixelRatio / _decodeStep).ceil()) *
                      _decodeStep,
              // Crops, rather than stretches, an image of a different shape.
              fit: BoxFit.cover,
              semanticLabel: card.semanticLabel,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                // Replaces the image's own semantics too, but the
                // placeholder announces the card the same way.
                if (frame == null) {
                  return PlaceholderCard(card: card);
                }

                return child;
              },
              errorBuilder: (context, error, stackTrace) {
                return PlaceholderCard(card: card);
              },
            ),
          ),
        );
      },
    );
  }
}
