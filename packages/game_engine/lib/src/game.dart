import 'card.dart';
import 'card_type.dart';
import 'game_controller.dart';
import 'plate.dart';
import 'player.dart';

/// A read-only view of a single game: its players and their plates, the
/// draw and discard piles, and whose turn it is.
///
/// What this returns is the game's current state, not a snapshot of it.
/// Read it from the game each time it's needed, such as on each build, and
/// don't hold on to what it returns, since it may or may not reflect later
/// moves.
///
/// To make moves, use a [GameController], which implements this.
abstract interface class Game {
  /// The players in turn order.
  List<Player> get players;

  /// The plate of [player], who is looked up by identity.
  ///
  /// Each player keeps the same plate for the whole game, and it shows
  /// their cards as they are now.
  ///
  /// Throws an [ArgumentError] if [player] isn't one of [players].
  Plate plateOf(Player player);

  /// The cards still to be drawn, with the top of the pile last.
  List<Card> get drawPile;

  /// The discarded cards, with the most recently discarded card last.
  List<Card> get discardPile;

  /// The index into [players] of the player whose turn it is. Once the
  /// game is over, this stays as the [winner]'s index.
  int get currentPlayerIndex;

  /// The player whose turn it is. Once the game is over, this stays as the
  /// [winner].
  Player get currentPlayer;

  /// The index into [players] of the player who most recently played a
  /// drawn card, by placing or discarding it, or `null` if no card has been
  /// played since the game was created.
  int? get lastPlayerIndex;

  /// The player who most recently played a drawn card, by placing or
  /// discarding it, or `null` if no card has been played since the game was
  /// created.
  ///
  /// Use this to show the result of a play once the turn has passed to the
  /// next player. After a winning play, this is the [winner], since the
  /// turn doesn't pass.
  Player? get lastPlayer;

  /// The index into [players] of the player who completed their meal and
  /// won the game, or `null` if no one has won yet.
  int? get winnerIndex;

  /// The player who completed their meal and won the game, or `null` if
  /// no one has won yet.
  ///
  /// This is recorded when a placed card fills the current player's plate,
  /// and doesn't change once set.
  Player? get winner;

  /// Whether the game has ended because a player has won, after which no
  /// more cards can be drawn, placed or discarded.
  bool get isGameOver;

  /// The card the current player has drawn and not yet played, or `null`
  /// if they haven't drawn one.
  Card? get drawnCard;

  /// Whether the [drawnCard] can be placed, i.e. the game isn't over, a
  /// card has been drawn and it's either a [CardType.standard] card or its
  /// slot on the current player's plate is empty.
  bool get canPlaceDrawnCard;

  /// Whether the [drawnCard] can be discarded, i.e. the game isn't over, a
  /// card has been drawn and its slot on the current player's plate is
  /// filled.
  bool get canDiscardDrawnCard;

  /// Whether a card can be drawn from the draw pile, i.e. the game isn't
  /// over, no card has been drawn yet and either the draw pile or the
  /// discard pile has cards in it, since an empty draw pile is refilled
  /// from the discard pile.
  bool get canDrawFromDrawPile;

  /// Whether a card can be drawn from the discard pile, i.e. the game isn't
  /// over, no card has been drawn yet and the discard pile has cards in it.
  bool get canDrawFromDiscardPile;
}
