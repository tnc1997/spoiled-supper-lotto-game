/// A participant in the game, human or computer-controlled.
///
/// A game tells its players apart by identity, so give each player in a
/// game their own instance. Their plate belongs to the game, and is read
/// with `Game.plateOf`.
class Player {
  /// The name shown for this player throughout the UI.
  final String name;

  /// Whether this player is controlled by a computer opponent.
  final bool isAi;

  Player({
    required this.name,
    this.isAi = false,
  });
}
