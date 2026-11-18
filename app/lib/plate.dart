import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';

import 'card_aspect_ratio.dart';
import 'category_color.dart';
import 'category_label.dart';
import 'framed_card.dart';
import 'game_scope.dart';

/// Shows a [player]'s place-setting board, from the closest [GameScope],
/// with a slot for each category that shows the card in it, or that the
/// slot is empty.
///
/// The drink and dessert sit above the meal, with the main in the middle
/// and its two sides, the vegetable and carbohydrate, either side of it.
///
/// Only rebuilt when the player's plate changes, not after every move.
class Plate extends StatelessWidget {
  static const _gap = 16.0;

  /// The player whose plate to show.
  final engine.Player player;

  /// The width of each slot, in logical pixels.
  final double cardWidth;

  /// Shows [player]'s plate, with each slot [cardWidth] logical pixels wide.
  const Plate({super.key, required this.player, this.cardWidth = 120});

  @override
  Widget build(BuildContext context) {
    final plate = GameScope.plateOf(context, player);

    Widget slot(engine.Category category) {
      final card = plate[category];

      return SizedBox(
        width: cardWidth,
        child: card == null
            ? _EmptySlot(category: category)
            : FramedCard(card: card),
      );
    }

    return Semantics(
      container: true,
      label: "${player.name}'s plate",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: _gap,
            children: [
              slot(engine.Category.drink),
              slot(engine.Category.dessert),
            ],
          ),
          const SizedBox(height: _gap),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: _gap,
            children: [
              slot(engine.Category.vegetable),
              slot(engine.Category.main),
              slot(engine.Category.carbohydrate),
            ],
          ),
        ],
      ),
    );
  }
}

/// The empty slot for [category]: a card-shaped outline in the category's
/// colour, labelled with the category.
class _EmptySlot extends StatelessWidget {
  final engine.Category category;

  const _EmptySlot({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = category.color;

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: '${category.label}, empty',
      child: AspectRatio(
        aspectRatio: cardAspectRatio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color, width: 2),
            borderRadius: FramedCard.borderRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              // Shrinks the label, rather than overflowing, at large text
              // scales.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  category.label,
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
