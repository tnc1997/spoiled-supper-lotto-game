import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Card;

import 'card.dart';
import 'card_aspect_ratio.dart';

/// Shows a [card] with a subtle shadow and a thin outline, so that its edge
/// stands out from the board behind it, even when its colour is close to
/// the board's. The outline keeps the edge visible on a dark board, where
/// the shadow barely shows. Its corners are square, like the physical
/// cards'. Use this wherever a card is shown on the board, e.g. on a plate
/// or a pile.
///
/// A `PlaceholderCard` and the player's own image of the card are framed
/// alike, so swapping one for the other doesn't change the card's look.
///
/// The card keeps its shape, [cardAspectRatio], and fills as much of the
/// space its parent allows as it can.
class FramedCard extends StatelessWidget {
  /// The card to show.
  final engine.Card card;

  /// Shows [card].
  const FramedCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: cardAspectRatio,
      // Casts the shadow behind the card.
      child: DecoratedBox(
        decoration: BoxDecoration(boxShadow: kElevationToShadow[2]),
        // Draws the outline over the card, which would otherwise hide it.
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Card(card: card),
        ),
      ),
    );
  }
}
