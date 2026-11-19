import 'dart:math';

import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Card;

import 'card.dart';
import 'card_aspect_ratio.dart';
import 'card_back.dart';
import 'card_frame.dart';
import 'card_semantic_label.dart';
import 'game_notifier.dart';
import 'game_scope.dart';

/// Shows the card the current player has drawn, from the closest
/// [GameScope], turning it over from face down to face up as it's drawn,
/// over [flipDuration].
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
    final card = notifier.game.drawnCard;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return SizedBox(
      width: cardWidth,
      height: cardWidth / cardAspectRatio,
      child: card == null
          ? null
          // Starts again from face down for each card drawn.
          : TweenAnimationBuilder<double>(
              key: ObjectKey(card),
              tween: Tween(begin: 0, end: 1),
              // Turns the card over, then holds it face up, or only holds
              // it if animations are disabled.
              duration:
                  reduceMotion ? holdDuration : flipDuration + holdDuration,
              curve: Interval(
                0,
                flipDuration.inMicroseconds /
                    (flipDuration + holdDuration).inMicroseconds,
                curve: Curves.easeInOut,
              ),
              onEnd: () => _playIfNoChoice(notifier, card),
              builder: (context, flip, child) {
                final isFaceUp = reduceMotion || flip == 1;
                // Turns the card over about its upright axis, swapping its
                // back for its face halfway, when it's edge on.
                final angle = reduceMotion ? pi : flip * pi;
                final showsFace = angle >= pi / 2;

                // Announces the card once it's face up, as a screen reader
                // can't see it turn over.
                return Semantics(
                  container: true,
                  liveRegion: true,
                  excludeSemantics: true,
                  label: isFaceUp
                      ? 'Drawn card, ${card.semanticLabel}'
                      : 'Drawn card',
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      // Adds perspective, so the near edge looks bigger.
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(showsFace ? angle - pi : angle),
                    child: CardFrame(
                      child: showsFace ? Card(card: card) : const CardBack(),
                    ),
                  ),
                );
              },
            ),
    );
  }

  /// Places or discards [card] for the player, if it's still drawn and can
  /// only be played one way.
  static void _playIfNoChoice(GameNotifier notifier, engine.Card card) {
    final game = notifier.game;

    if (game.drawnCard != card) {
      return;
    }

    if (game.canPlaceDrawnCard && !game.canDiscardDrawnCard) {
      notifier.placeDrawnCard();
    } else if (game.canDiscardDrawnCard && !game.canPlaceDrawnCard) {
      notifier.discardDrawnCard();
    }
  }
}
