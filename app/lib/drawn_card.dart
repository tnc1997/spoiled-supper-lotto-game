import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Card;

import 'card_aspect_ratio.dart';
import 'card_semantic_label.dart';
import 'flipping_card.dart';
import 'game_notifier.dart';
import 'game_scope.dart';
import 'placing_card.dart';
import 'plate.dart';
import 'spoiled_reveal.dart';

/// Shows the card the current player has drawn, from the closest
/// [GameScope], turning it over from face down to face up as it's drawn,
/// over [flipDuration]. A card drawn from the discard pile is shown face up
/// straight away, since it was already face up on the pile.
///
/// If the card can only be played one way, it's then held face up for
/// [holdDuration] before it's placed or discarded for the player. Otherwise
/// the player chooses with the `DrawnCardActions`.
///
/// Once the card is chosen to be placed, with
/// [GameNotifier.startPlacingDrawnCard], it goes to its slot on the plate
/// with [plateKey] as a [PlacingCard], over [placeDuration], and is then
/// placed, so that the player sees it land on their plate before their
/// turn ends.
///
/// A Spoiled card drawn from the draw pile is revealed with a
/// [SpoiledReveal] once it's face up. One from the discard pile isn't,
/// since it was already face up.
///
/// While no card has been drawn, it keeps its space on the table, empty,
/// so that nothing around it moves when a card is drawn.
class DrawnCard extends StatelessWidget {
  /// How long the card takes to turn face up.
  static const flipDuration = Duration(milliseconds: 400);

  /// How long the card stays face up before it's played for the player,
  /// when they have no choice.
  static const holdDuration = Duration(milliseconds: 600);

  /// How long the card takes to go to its slot on the plate, once it's
  /// chosen to be placed.
  static const placeDuration = Duration(milliseconds: 400);

  /// The width of the card, in logical pixels.
  final double cardWidth;

  /// The key of the [Plate] that the card is placed on, for finding the
  /// card's slot, or `null` to place the card where it is.
  ///
  /// The plate's slots should be [cardWidth] wide, so that the card fills
  /// its slot when it lands.
  final GlobalKey? plateKey;

  /// Shows the drawn card, [cardWidth] logical pixels wide, placing it on
  /// the [Plate] with [plateKey].
  const DrawnCard({super.key, this.cardWidth = 120, this.plateKey});

  @override
  Widget build(BuildContext context) {
    final notifier = GameScope.of(context);
    final game = notifier.game;
    final card = game.drawnCard;
    // A card from the discard pile is already face up, so there's nothing
    // to turn over.
    final shouldFlip = !MediaQuery.disableAnimationsOf(context) &&
        game.drawnFrom != engine.Pile.discard;
    final isSpoiledReveal = card?.type == engine.CardType.spoiled &&
        game.drawnFrom == engine.Pile.draw;

    final size = Size(cardWidth, cardWidth / cardAspectRatio);

    if (card != null && notifier.isPlacingDrawnCard) {
      return SizedBox.fromSize(
        size: size,
        child: PlacingCard(
          plateKey: plateKey,
          category: card.category,
          duration: placeDuration,
          onEnd: notifier.placeDrawnCard,
          // Isn't a live region, so that the card, already announced as it
          // turned face up, isn't announced again as it starts to move.
          child: Semantics(
            container: true,
            label: 'Drawn card, ${card.semanticLabel}',
            // Keeps a revealed Spoiled card's callout on the way, without
            // shaking it again.
            child: isSpoiledReveal
                ? SpoiledReveal(
                    duration: Duration.zero,
                    child: FlippingCard(card: card, progress: 1),
                  )
                : FlippingCard(card: card, progress: 1),
          ),
        ),
      );
    }

    return SizedBox.fromSize(
      size: size,
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

                final drawnCard = _drawnCard(card, progress);

                return isSpoiledReveal && progress == 1
                    ? SpoiledReveal(duration: holdDuration, child: drawnCard)
                    : drawnCard;
              },
            ),
    );
  }

  /// Shows [card], [progress] of the way through turning face up.
  ///
  /// Announces the card once it's face up, as a screen reader can't see it
  /// turn over.
  static Widget _drawnCard(engine.Card card, double progress) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: progress == 1 ? 'Drawn card, ${card.semanticLabel}' : 'Drawn card',
      child: FlippingCard(card: card, progress: progress),
    );
  }

  /// Starts placing, or discards, the drawn card for the player, if it can
  /// only be played one way.
  ///
  /// Does nothing once the card has been played, since no card is drawn
  /// again until [DrawnCard] has rebuilt, which ends this card's animation.
  static void _playIfNoChoice(GameNotifier notifier) {
    final game = notifier.game;

    if (game.canPlaceDrawnCard && !game.canDiscardDrawnCard) {
      notifier.startPlacingDrawnCard();
    } else if (game.canDiscardDrawnCard && !game.canPlaceDrawnCard) {
      notifier.discardDrawnCard();
    }
  }
}
