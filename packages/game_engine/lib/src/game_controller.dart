import 'dart:math';

import 'card.dart';
import 'deck.dart';
import 'player.dart';
import 'shuffle.dart';

/// Holds the state of a single game: its players, the draw and discard
/// piles, and whose turn it is.
class GameController {
  /// The fewest players a game can be started with.
  static const minPlayers = 2;

  /// The most players a game can be started with.
  static const maxPlayers = 4;

  final List<Player> _players;
  final List<Card> _drawPile;
  final List<Card> _discardPile;
  final int _currentPlayerIndex;

  /// Starts a new game for [players], in turn order, with the first player
  /// taking the first turn.
  ///
  /// The draw pile defaults to the full deck from [buildDeck], shuffled
  /// with [random] (pass a seeded [Random] for a reproducible game). Pass
  /// [drawPile] to use a specific pile as-is instead, e.g. in tests; the
  /// top of the pile is its last card. The discard pile starts empty unless
  /// [discardPile] is given.
  ///
  /// Throws an [ArgumentError] if there are fewer than [minPlayers] or more
  /// than [maxPlayers] players.
  GameController({
    required List<Player> players,
    List<Card>? drawPile,
    List<Card>? discardPile,
    Random? random,
  })  : _players = List.unmodifiable(players),
        _drawPile =
            drawPile != null ? List.of(drawPile) : _shuffledDeck(random),
        _discardPile = List.of(discardPile ?? const <Card>[]),
        _currentPlayerIndex = 0 {
    if (players.length < minPlayers || players.length > maxPlayers) {
      throw ArgumentError.value(
        players.length,
        'players',
        'Must have between $minPlayers and $maxPlayers players',
      );
    }
  }

  /// The players in turn order.
  List<Player> get players => _players;

  /// The cards still to be drawn, with the top of the pile last.
  List<Card> get drawPile => List.unmodifiable(_drawPile);

  /// The discarded cards, with the most recently discarded card last.
  List<Card> get discardPile => List.unmodifiable(_discardPile);

  /// The index into [players] of the player whose turn it is.
  int get currentPlayerIndex => _currentPlayerIndex;

  /// The player whose turn it is.
  Player get currentPlayer => _players[_currentPlayerIndex];

  static List<Card> _shuffledDeck(Random? random) {
    final deck = buildDeck();
    shuffle(deck, random);
    return deck;
  }
}
