import 'dart:math';

import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Card;

import 'card.dart';
import 'card_back.dart';
import 'card_frame.dart';

/// Shows a [card] partway through turning over, from face down at a
/// [progress] of 0 to face up at 1, framed on the table with a [CardFrame].
///
/// It turns about its upright axis, with a little perspective, and swaps
/// its back for its face halfway, when it's edge on. It has no timing of
/// its own, so animate [progress] to turn it over.
///
/// It doesn't announce anything, since a screen reader can't see it turn
/// over, so whoever shows it should announce the card, e.g. once it's face
/// up.
class FlippingCard extends StatelessWidget {
  /// The card to show.
  final engine.Card card;

  /// How far the card has turned over, from 0 (face down) to 1 (face up).
  final double progress;

  /// Shows [card], [progress] of the way through turning face up.
  const FlippingCard({super.key, required this.card, required this.progress});

  @override
  Widget build(BuildContext context) {
    final angle = progress * pi;
    final showsFace = angle >= pi / 2;

    return ExcludeSemantics(
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          // Adds perspective, so the near edge looks bigger.
          ..setEntry(3, 2, 0.001)
          // Turns the face the other way round, so it isn't mirrored.
          ..rotateY(showsFace ? angle - pi : angle),
        child: CardFrame(
          child: showsFace ? Card(card: card) : const CardBack(),
        ),
      ),
    );
  }
}
