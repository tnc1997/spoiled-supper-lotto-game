import 'package:material_ui/material_ui.dart' hide Card;

import 'card.dart';
import 'card_frame.dart';
import 'card_semantic_label.dart';
import 'empty_slot.dart';
import 'game_scope.dart';

/// Shows the discard pile, from the closest [GameScope], with its top card
/// face up and the number of cards in it below.
///
/// Tapping the pile takes its top card, while the current player can draw
/// from it. Once the pile is empty, it shows as a plain card-shaped area.
class DiscardPile extends StatelessWidget {
  /// The width of the pile, in logical pixels.
  final double cardWidth;

  /// Shows the discard pile, [cardWidth] logical pixels wide.
  const DiscardPile({super.key, this.cardWidth = 120});

  @override
  Widget build(BuildContext context) {
    final notifier = GameScope.of(context);
    final game = notifier.game;
    final top = game.discardPile.lastOrNull;
    final count = game.discardPile.length;
    final countLabel = count == 1 ? '1 card' : '$count cards';
    final onDraw =
        game.canDrawFromDiscardPile ? notifier.drawFromDiscardPile : null;

    // Makes the pile one button, which takes on the focus state and tap
    // action of its InkWell, so a screen reader announces it as it gains
    // keyboard focus, along with its top card and the count below it, e.g.
    // "Discard pile", "Sausages, Main", "1 card".
    return Semantics(
      container: true,
      button: true,
      enabled: onDraw != null,
      label: 'Discard pile',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          SizedBox(
            width: cardWidth,
            // Takes its size, in the card's shape, from the pile.
            child: Stack(
              children: [
                top == null
                    // Leaves the label and count to say that the pile is
                    // empty, rather than the empty slot's "Empty".
                    ? const ExcludeSemantics(child: EmptySlot(label: 'Empty'))
                    // Announces the card as part of the button, rather
                    // than as a container of its own.
                    : Semantics(
                        excludeSemantics: true,
                        label: top.semanticLabel,
                        child: CardFrame(child: Card(card: top)),
                      ),
                // Lies over the pile, so that its ink and focus highlight
                // show on top of the card rather than behind it.
                Positioned.fill(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(onTap: onDraw),
                  ),
                ),
              ],
            ),
          ),
          Text(countLabel, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
