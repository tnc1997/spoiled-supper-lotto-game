import 'package:game_engine/game_engine.dart' as engine;

import 'game_notifier.dart';

/// A drawn card that a player has placed or discarded, as recorded in
/// [GameNotifier.playedCards].
class PlayedCard {
  /// The player who played the card.
  final engine.Player player;

  /// The card that was played.
  final engine.Card card;

  /// How the card was played.
  final DrawnCardPlay play;

  /// The card that [card] replaced on [player]'s plate, which went onto the
  /// discard pile, or `null` if it went into an empty slot or was
  /// discarded.
  final engine.Card? replacedCard;

  /// Records that [player] played [card] as [play], replacing
  /// [replacedCard] on their plate, if any.
  const PlayedCard({
    required this.player,
    required this.card,
    required this.play,
    this.replacedCard,
  });

  /// What happened, e.g. `Alice placed Sausages`,
  /// `Alice placed Sausages, replacing Fish Fingers` or
  /// `Alice discarded Fish Bone`.
  String get description {
    final verb = switch (play) {
      DrawnCardPlay.place => 'placed',
      DrawnCardPlay.discard => 'discarded',
    };
    final replacedCard = this.replacedCard;

    return [
      '${player.name} $verb ${card.name}',
      if (replacedCard != null) 'replacing ${replacedCard.name}',
    ].join(', ');
  }
}
