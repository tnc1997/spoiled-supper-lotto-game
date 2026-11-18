import 'package:material_ui/material_ui.dart';

import 'card_size.dart';

/// The back of a card, for showing a card face down, e.g. on the draw pile.
///
/// It is an original design: the theme's primary container colour, with an
/// inset border and a place-setting icon. Like a card's face, it is a plain
/// rectangle, so frame it with a `CardFrame` on the board.
///
/// Like a card's face, it is laid out at [cardSize] and then scaled,
/// keeping its shape, to fit the space its parent allows, so that its
/// border and icon grow with it. In an unbounded parent it shows at
/// [cardSize].
class CardBack extends StatelessWidget {
  /// Shows the back of a card.
  const CardBack({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FittedBox(
      child: Container(
        width: cardSize.width,
        height: cardSize.height,
        padding: const EdgeInsets.all(8),
        color: colorScheme.primaryContainer,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.onPrimaryContainer, width: 2),
          ),
          child: Icon(
            Icons.restaurant,
            size: cardSize.width / 2,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
