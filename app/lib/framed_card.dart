import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Card;

import 'card.dart';
import 'card_aspect_ratio.dart';

/// Shows a [card] with rounded corners and a subtle shadow, so that its edge
/// stands out from the board behind it, even when its colour is close to
/// the board's. Use this wherever a card is shown on the board, e.g. on a
/// plate or a pile.
///
/// A `PlaceholderCard` and the player's own image of the card are framed
/// alike, so swapping one for the other doesn't change the card's look.
///
/// The card keeps its shape, [cardAspectRatio], and fills as much of the
/// space its parent allows as it can.
class FramedCard extends StatelessWidget {
  /// The rounding of a card's corners, which other card-shaped things on
  /// the board, such as an empty slot, should share.
  static const borderRadius = BorderRadius.all(Radius.circular(8));

  /// The card to show.
  final engine.Card card;

  /// Shows [card].
  const FramedCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: cardAspectRatio,
      child: PhysicalModel(
        color: Colors.transparent,
        elevation: 2,
        shadowColor: Theme.of(context).shadowColor,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: Card(card: card),
      ),
    );
  }
}
