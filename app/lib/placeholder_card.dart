import 'package:game_engine/game_engine.dart';
import 'package:material_ui/material_ui.dart' hide Card;

import 'category_color.dart';
import 'category_label.dart';

/// The default, original artwork for a [card]: a plain card in its
/// category's colour, with its name and category as text.
///
/// Spoiled cards use a muted version of the colour and are tagged
/// "Spoiled", so they can be told apart without relying on colour alone.
///
/// The card is laid out at [size] and then scaled, keeping its shape, to
/// fit the space its parent allows. In an unbounded parent it shows at
/// [size].
///
/// The text follows the system text scale until it fills the card, and is
/// then shrunk to fit.
class PlaceholderCard extends StatelessWidget {
  /// The size the card is laid out at, before it is scaled to fit.
  ///
  /// Matches the 5:8 shape of the 260x416px card template that card images
  /// are cropped to (see `tools/crop-cards.sh`), so that a placeholder and
  /// an image take up the same space.
  static const size = Size(100, 160);

  static const _borderWidth = 2.5;

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

    final backgroundColor =
        Color.lerp(Colors.white, baseColor.toColor(), 0.35)!;
    final borderColor = baseColor.withLightness(0.35).toColor();
    final foregroundColor = baseColor.withLightness(0.2).toColor();

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: [
        card.name,
        card.category.label,
        if (_isSpoiled) 'Spoiled',
      ].join(', '),
      // Scales the whole card to fit its parent.
      child: FittedBox(
        child: Container(
          width: size.width,
          height: size.height,
          padding: _padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: _borderWidth),
            borderRadius: BorderRadius.circular(8),
          ),
          // Shrinks the text only if it doesn't fit, e.g. at a large system
          // text scale.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              // The container's padding includes its border.
              width: size.width - _padding.horizontal - 2 * _borderWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSpoiled)
                    Text(
                      'SPOILED',
                      style: textTheme.labelSmall
                          ?.copyWith(color: foregroundColor),
                    ),
                  Text(
                    card.name,
                    textAlign: TextAlign.center,
                    style:
                        textTheme.titleMedium?.copyWith(color: foregroundColor),
                  ),
                  Text(
                    card.category.label,
                    style:
                        textTheme.labelSmall?.copyWith(color: foregroundColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
