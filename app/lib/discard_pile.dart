import 'package:material_ui/material_ui.dart' hide Card;

import 'card.dart';
import 'card_semantic_label.dart';
import 'game_scope.dart';
import 'pile.dart';

/// Shows the discard pile, from the closest [GameScope], with its top card
/// face up and the number of cards in it below.
///
/// Tapping the pile takes its top card, while the current player can draw
/// from it. Once the pile is empty, it shows as a plain card-shaped area.
class DiscardPile extends StatelessWidget {
  /// The width of the pile, in logical pixels.
  final double cardWidth;

  /// The key of the area that the pile's top card is shown in, e.g. for a
  /// card to be discarded onto it.
  final GlobalKey? cardKey;

  /// Shows the discard pile, [cardWidth] logical pixels wide, with its top
  /// card's area keyed with [cardKey].
  const DiscardPile({super.key, this.cardWidth = 120, this.cardKey});

  @override
  Widget build(BuildContext context) {
    final notifier = GameScope.of(context);
    final game = notifier.game;
    final top = game.discardPile.lastOrNull;

    return Pile(
      label: 'Discard pile',
      count: game.discardPile.length,
      card: top == null
          ? null
          // Announces the card as part of the pile's button, rather than as
          // a container of its own.
          : Semantics(
              excludeSemantics: true,
              label: top.semanticLabel,
              child: Card(card: top),
            ),
      onTap: game.canDrawFromDiscardPile ? notifier.drawFromDiscardPile : null,
      cardWidth: cardWidth,
      cardKey: cardKey,
    );
  }
}
