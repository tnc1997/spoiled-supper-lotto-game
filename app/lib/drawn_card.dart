import 'dart:math';

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
/// A Spoiled card drawn from the draw pile is called out with "Spoiled!"
/// once it's face up, and shakes while it's held, unless animations are
/// disabled. One from the discard pile isn't, since it was already face up.
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
    // A Spoiled card is only revealed as it's drawn from the draw pile,
    // since one from the discard pile was already face up.
    final isSpoiledReveal = card?.type == engine.CardType.spoiled &&
        game.drawnFrom == engine.Pile.draw;
    final shouldShake =
        !MediaQuery.disableAnimationsOf(context) && isSpoiledReveal;
    final flipEnd = shouldFlip
        ? flipDuration.inMicroseconds /
            (flipDuration + holdDuration).inMicroseconds
        : 0.0;

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
              onEnd: () => _playIfNoChoice(notifier),
              builder: (context, value, child) {
                final progress = shouldFlip
                    ? Interval(0, flipEnd, curve: Curves.easeInOut)
                        .transform(value)
                    : 1.0;
                final isFaceUp = progress == 1;

                return Transform.translate(
                  offset: Offset(
                    shouldShake
                        ? _shakeOffset(Interval(flipEnd, 1).transform(value))
                        : 0,
                    0,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Announces the card once it's face up, as a screen
                      // reader can't see it turn over.
                      Semantics(
                        container: true,
                        liveRegion: true,
                        label: isFaceUp
                            ? 'Drawn card, ${card.semanticLabel}'
                            : 'Drawn card',
                        child: FlippingCard(card: card, progress: progress),
                      ),
                      // Calls out a Spoiled card once it's revealed. Its
                      // announcement already says it's Spoiled, so the
                      // callout is only for show.
                      if (isSpoiledReveal && isFaceUp) const _SpoiledCallout(),
                    ],
                  ),
                );
              },
            ),
    );
  }

  /// How far the card is shaken sideways, in logical pixels, [progress] of
  /// the way through holding it face up, shaking a few times and settling.
  static double _shakeOffset(double progress) {
    return sin(progress * 4 * 2 * pi) * 8 * (1 - progress);
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

/// The "Spoiled!" callout shown across a Spoiled card as it's revealed, in
/// the `displaySmall` text style, which is reserved for it.
class _SpoiledCallout extends StatelessWidget {
  const _SpoiledCallout();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ExcludeSemantics(
      // Lets the callout be wider than the card.
      child: OverflowBox(
        maxWidth: double.infinity,
        child: Transform.rotate(
          angle: -pi / 12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                'Spoiled!',
                // Keeps the callout from outgrowing the screen with a
                // larger text size, since it's only for show.
                textScaler: TextScaler.noScaling,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
