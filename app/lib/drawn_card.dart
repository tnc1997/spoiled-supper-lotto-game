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
/// [GameScope], turning it over from face down to face up as it's drawn.
///
/// Once the card is face up, if the player has a choice, because it's a
/// standard card whose slot on their plate is already filled, it offers to
/// place it, replacing the card in that slot, or to discard it. Otherwise
/// the card can only be played one way, so after a moment it's placed or
/// discarded for them.
///
/// While no card has been drawn, it keeps its space on the table, empty,
/// so that nothing around it moves when a card is drawn.
class DrawnCard extends StatefulWidget {
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
  State<DrawnCard> createState() => _DrawnCardState();
}

/// The state of a [DrawnCard], turning each card over as it's drawn.
class _DrawnCardState extends State<DrawnCard>
    with SingleTickerProviderStateMixin {
  /// Runs from the card being drawn, through it turning face up, to the
  /// end of the moment it stays face up.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: DrawnCard.flipDuration + DrawnCard.holdDuration,
  )..addStatusListener(_onStatusChanged);

  /// The part of [_controller] in which the card turns face up.
  late final Animation<double> _flip = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      0,
      DrawnCard.flipDuration.inMicroseconds /
          _controller.duration!.inMicroseconds,
      curve: Curves.easeInOut,
    ),
  );

  late GameNotifier _notifier;

  /// The card being shown, or `null` if no card has been drawn.
  engine.Card? _card;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _notifier = GameScope.of(context);
    final card = _notifier.game.drawnCard;

    if (card != _card) {
      _card = card;

      if (card == null) {
        _controller.reset();
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Plays the card for the player once it has been face up for a moment,
  /// if they have no choice of how to play it.
  void _onStatusChanged(AnimationStatus status) {
    final game = _notifier.game;

    if (status != AnimationStatus.completed || game.drawnCard != _card) {
      return;
    }

    if (game.canPlaceDrawnCard && !game.canDiscardDrawnCard) {
      _notifier.placeDrawnCard();
    } else if (game.canDiscardDrawnCard && !game.canPlaceDrawnCard) {
      _notifier.discardDrawnCard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = _card;

    if (card == null) {
      return SizedBox(
        width: widget.cardWidth,
        height: widget.cardWidth / cardAspectRatio,
      );
    }

    final game = _notifier.game;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return AnimatedBuilder(
      animation: _flip,
      builder: (context, child) {
        final isFaceUp = reduceMotion || _flip.value == 1;
        // Turns the card over about its upright axis, swapping its back for
        // its face halfway, when it's edge on.
        final angle = reduceMotion ? 0.0 : _flip.value * pi;
        final showsFace = angle >= pi / 2;

        return SizedBox(
          width: widget.cardWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              // Announces the card once it's face up, as a screen reader
              // can't see it turn over.
              Semantics(
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
                    child: showsFace || reduceMotion
                        ? Card(card: card)
                        : const CardBack(),
                  ),
                ),
              ),
              if (isFaceUp &&
                  game.canPlaceDrawnCard &&
                  game.canDiscardDrawnCard) ...[
                FilledButton(
                  onPressed: _notifier.placeDrawnCard,
                  child: const Text('Place'),
                ),
                OutlinedButton(
                  onPressed: _notifier.discardDrawnCard,
                  child: const Text('Discard'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
