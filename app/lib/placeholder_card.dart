import 'package:game_engine/game_engine.dart';
import 'package:material_ui/material_ui.dart' hide Card;

import 'card_semantic_label.dart';
import 'card_size.dart';
import 'category_color.dart';
import 'category_label.dart';

/// The default, original artwork for a [card]: a plain card in its
/// category's colour, with its name and category as text.
///
/// Like the card images that can replace it, it is a plain rectangle with
/// no border or rounded corners, so that the parent can frame both alike,
/// e.g. with a shadow.
///
/// Spoiled cards use a muted version of the colour and are tagged
/// "Spoiled", so they can be told apart without relying on colour alone.
///
/// The card is laid out at [size] and then scaled, keeping its shape, to
/// fit the space its parent allows. In an unbounded parent it shows at
/// [size].
///
/// The "Spoiled" tag sits at the top, the category at the bottom, and the
/// name, one word per line so words are never split, in the centre.
///
/// Like the text on a card image, the text ignores the system text scale
/// and only grows with the card, so that it always fits. To make cards
/// easier to read, give them more space instead.
class PlaceholderCard extends StatelessWidget {
  /// The size the card is laid out at, before it is scaled to fit.
  ///
  /// Has the shape of every card, [cardAspectRatio], so that a placeholder
  /// and a player's own image take up the same space.
  static const size = Size(100, 100 / cardAspectRatio);

  static const _padding = EdgeInsets.all(8);

  /// The card to show.
  final Card card;

  /// Shows [card].
  const PlaceholderCard({super.key, required this.card});

  bool get _isSpoiled => card.type == CardType.spoiled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    var baseColor = HSLColor.fromColor(card.category.color);
    if (_isSpoiled) {
      baseColor = baseColor.withSaturation(baseColor.saturation * 0.6);
    }

    final backgroundColor = baseColor.withLightness(0.8).toColor();
    final foregroundColor = baseColor.withLightness(0.2).toColor();

    final nameStyle = textTheme.titleSmall?.copyWith(color: foregroundColor);
    final labelStyle = textTheme.labelSmall?.copyWith(color: foregroundColor);

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: card.semanticLabel,
      // Fixes the text's size relative to the card, like a card image's.
      child: MediaQuery.withNoTextScaling(
        // Scales the whole card to fit its parent.
        child: FittedBox(
          child: Container(
            width: size.width,
            height: size.height,
            padding: _padding,
            color: backgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Holds the tag's space on standard cards too, so that
                // every name sits at the same height.
                Visibility.maintain(
                  visible: _isSpoiled,
                  child: Text('SPOILED', style: labelStyle),
                ),
                Column(
                  children: [
                    for (final word in card.name.split(' '))
                      Text(word, style: nameStyle),
                  ],
                ),
                Text(card.category.label, style: labelStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
