import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Table;

import 'discard_pile.dart';
import 'draw_pile.dart';
import 'drawn_card.dart';
import 'game_scope.dart';
import 'plate.dart';

/// Shows the table of the game in the closest [GameScope]: [player]'s
/// plate, with the draw pile, the discard pile and the drawn card in a row
/// below it.
class Table extends StatelessWidget {
  /// The player whose plate is shown.
  final engine.Player player;

  /// The key of the plate, so that the drawn card can find its slot on it.
  final GlobalKey plateKey;

  /// The key of the discard pile's top card, so that the drawn card can
  /// find where to go when it's discarded.
  final GlobalKey discardPileKey;

  /// Shows [player]'s plate, with [plateKey], above the piles and the drawn
  /// card, with the discard pile's top card shown with [discardPileKey].
  const Table({
    super.key,
    required this.player,
    required this.plateKey,
    required this.discardPileKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 24,
      children: [
        Plate(key: plateKey, player: player),
        // Lines up the cards' tops, rather than centring them, so that the
        // piles' count labels hang below and don't push the drawn card down.
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            const DrawPile(),
            DiscardPile(cardKey: discardPileKey),
            DrawnCard(plateKey: plateKey, discardPileKey: discardPileKey),
          ],
        ),
      ],
    );
  }
}
