import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Card;

import 'card_aspect_ratio.dart';
import 'card_semantic_label.dart';
import 'flipping_card.dart';
import 'game_notifier.dart';
import 'game_scope.dart';

/// Shows the card the current player has drawn, from the closest
/// [GameScope], turning it over from face down to face up as it's drawn,
/// over [flipDuration]. A card drawn from the discard pile is shown face up
/// straight away, since it was already face up on the pile.
///
/// If the card can only be played one way, it's then held face up for
/// [holdDuration] before it's placed or discarded for the player. Otherwise
/// the player chooses with the `DrawnCardActions`.
///
/// While no card has been drawn, it keeps its space on the table, empty,
/// so that nothing around it moves when a card is drawn.
class DrawnCard extends StatelessWidget {
  /// How long the card takes to turn face up.
  static const flipDuration = Duration(milliseconds: 400);

  /// How long the card stays face up before it's played for the player,
  /// when they have no choice.
  static const holdDuration = Duration(milliseconds: 600);

  /// The width of the card, in logical pixels.
  final double cardWidth;

  /// Shows the drawn card, [cardWidth] logical pixels wide.
  const DrawnCard({super.key, this.cardWidth = 120});

  @override
  Widget build(BuildContext context) {
    final notifier = GameScope.of(context);
    final game = notifier.game;
    final card = game.drawnCard;
    // A card from the discard pile is already face up, so there's nothing
    // to turn over.
    final shouldFlip = !MediaQuery.disableAnimationsOf(context) &&
        game.drawnFrom != engine.Pile.discard;

    return SizedBox(
      width: cardWidth,
      height: cardWidth / cardAspectRatio,
      child: card == null
          ? null
          // Starts again for each card drawn.
          : TweenAnimationBuilder<double>(
              key: ObjectKey(card),
              tween: Tween(begin: 0, end: 1),
              // Turns the card over, then holds it face up, or only holds
              // it if it's already face up or animations are disabled.
              duration: shouldFlip ? flipDuration + holdDuration : holdDuration,
              curve: Interval(
                0,
                flipDuration.inMicroseconds /
                    (flipDuration + holdDuration).inMicroseconds,
                curve: Curves.easeInOut,
              ),
              onEnd: () => _playIfNoChoice(notifier),
              builder: (context, value, child) {
                final progress = shouldFlip ? value : 1.0;

                // Announces the card once it's face up, as a screen reader
                // can't see it turn over.
                return Semantics(
                  container: true,
                  liveRegion: true,
                  label: progress == 1
                      ? 'Drawn card, ${card.semanticLabel}'
                      : 'Drawn card',
                  child: FlippingCard(card: card, progress: progress),
                );
              },
            ),
    );
  }

  /// Places or discards the drawn card for the player, if it can only be
  /// played one way.
  ///
  /// Does nothing once the card has been played, since no card is drawn
  /// again until [DrawnCard] has rebuilt, which ends this card's animation.
  static void _playIfNoChoice(GameNotifier notifier) {
    final game = notifier.game;

    if (game.canPlaceDrawnCard && !game.canDiscardDrawnCard) {
      notifier.placeDrawnCard();
    } else if (game.canDiscardDrawnCard && !game.canPlaceDrawnCard) {
      notifier.discardDrawnCard();
    }
  }
}
