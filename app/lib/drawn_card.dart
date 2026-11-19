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
/// standard card whose slot on their plate is already filled, its actions
/// offer to place it, replacing the card in that slot, or to discard it.
/// Otherwise the card can only be played one way, so after a moment it's
/// placed or discarded for them.
///
/// The card and its actions are passed to [builder] to lay out separately,
/// so that the card can be scaled with the table while the actions stay
/// full size. Both keep their space, empty, while there's nothing to show
/// in them, so that nothing around them moves when a card is drawn or
/// played.
class DrawnCard extends StatefulWidget {
  /// How long the card takes to turn face up.
  static const flipDuration = Duration(milliseconds: 400);

  /// How long the card stays face up before it's played for the player,
  /// when they have no choice.
  static const holdDuration = Duration(milliseconds: 600);

  /// The width of the card, in logical pixels.
  final double cardWidth;

  /// Lays out the [card], [cardWidth] logical pixels wide, and its
  /// [actions].
  final Widget Function(BuildContext context, Widget card, Widget actions)
      builder;

  /// Shows the drawn card, [cardWidth] logical pixels wide, and its
  /// actions, laid out by [builder].
  const DrawnCard({super.key, this.cardWidth = 120, required this.builder});

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
    final game = _notifier.game;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    /// Whether the card is face up, once it's been turned over.
    bool isFaceUp() => reduceMotion || _flip.value == 1;

    final cardView = SizedBox(
      width: widget.cardWidth,
      height: widget.cardWidth / cardAspectRatio,
      child: card == null
          ? null
          : AnimatedBuilder(
              animation: _flip,
              builder: (context, child) {
                // Turns the card over about its upright axis, swapping its
                // back for its face halfway, when it's edge on.
                final angle = reduceMotion ? 0.0 : _flip.value * pi;
                final showsFace = angle >= pi / 2;

                // Announces the card once it's face up, as a screen reader
                // can't see it turn over.
                return Semantics(
                  container: true,
                  liveRegion: true,
                  excludeSemantics: true,
                  label: isFaceUp()
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
                );
              },
            ),
    );

    final actions = AnimatedBuilder(
      animation: _flip,
      builder: (context, child) {
        final hasChoice = card != null &&
            isFaceUp() &&
            game.canPlaceDrawnCard &&
            game.canDiscardDrawnCard;

        // Keeps the actions' space while they're hidden, and disables them
        // so that they can't be focused.
        return Visibility(
          visible: hasChoice,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: hasChoice ? _notifier.placeDrawnCard : null,
                child: const Text('Place'),
              ),
              OutlinedButton(
                onPressed: hasChoice ? _notifier.discardDrawnCard : null,
                child: const Text('Discard'),
              ),
            ],
          ),
        );
      },
    );

    return widget.builder(context, cardView, actions);
  }
}
