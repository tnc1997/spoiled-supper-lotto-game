import 'plate.dart';

/// A participant in the game, human or computer-controlled.
class Player {
  /// The name shown for this player throughout the UI.
  final String name;

  /// Whether this player is controlled by a computer opponent.
  final bool isAi;

  /// This player's place-setting board.
  final Plate plate;

  Player({
    required this.name,
    this.isAi = false,
    Plate? plate,
  }) : plate = plate ?? Plate();
}
