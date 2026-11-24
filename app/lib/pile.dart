import 'package:material_ui/material_ui.dart';

import 'card_frame.dart';
import 'empty_slot.dart';

/// A pile of cards on the table, such as the draw pile or the discard
/// pile, showing its top [card] with the number of cards in it below.
///
/// The pile is one button, labelled [label], which takes on the focus state
/// and tap action of its ink, so a screen reader announces it as it gains
/// keyboard focus, along with whatever [card] announces and the count below
/// it, e.g. "Discard pile", "Sausages, Main", "2 cards". Tapping it calls
/// [onTap], and it is disabled while [onTap] is `null`.
///
/// While [card] is `null`, the pile is empty and shows as a plain
/// card-shaped area.
class Pile extends StatelessWidget {
  /// What the pile is announced as, e.g. "Draw pile".
  final String label;

  /// The number of cards in the pile.
  final int count;

  /// The top card of the pile, face up or face down, unframed, or `null`
  /// while the pile is empty.
  ///
  /// It is framed on the table with a [CardFrame], and announced as part of
  /// the pile's button, so it should announce only what a player can see,
  /// e.g. nothing for a card back.
  final Widget? card;

  /// Called when the pile is tapped, or `null` to disable it.
  final VoidCallback? onTap;

  /// The width of the pile, in logical pixels.
  final double cardWidth;

  /// The key of the area that [card] is shown in, e.g. for a card to be
  /// moved onto the pile.
  ///
  /// It isn't always at the top left corner of the pile, since the pile is
  /// as wide as the count below it, if that's wider, with [card] centred.
  final GlobalKey? cardKey;

  /// Shows a pile labelled [label], with [count] cards in it and [card] on
  /// top, [cardWidth] logical pixels wide, that calls [onTap] when tapped,
  /// with its card's area keyed with [cardKey].
  const Pile({
    super.key,
    required this.label,
    required this.count,
    required this.card,
    required this.onTap,
    this.cardWidth = 120,
    this.cardKey,
  });

  @override
  Widget build(BuildContext context) {
    final card = this.card;
    final countLabel = count == 1 ? '1 card' : '$count cards';

    return Semantics(
      container: true,
      button: true,
      enabled: onTap != null,
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          SizedBox(
            key: cardKey,
            width: cardWidth,
            // Takes its size, in the card's shape, from the pile.
            child: Stack(
              children: [
                card == null
                    // Leaves the label and count to say that the pile is
                    // empty, rather than the empty slot's "Empty".
                    ? const ExcludeSemantics(child: EmptySlot(label: 'Empty'))
                    : CardFrame(child: card),
                // Lies over the pile, so that its ink and focus highlight
                // show on top of the card rather than behind it.
                Positioned.fill(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(onTap: onTap),
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
