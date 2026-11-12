import 'dart:collection';
import 'dart:math';

import 'card.dart';
import 'card_type.dart';
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
  Card? _drawnCard;

  /// Holds the given state as-is, with the first player taking the first
  /// turn.
  ///
  /// [players] are in turn order, and the top of each pile is its last
  /// card. [drawnCard] is a card the current player has already drawn and
  /// not yet played. To set up a new game, use [GameController.start]
  /// instead.
  GameController({
    required List<Player> players,
    required List<Card> drawPile,
    List<Card> discardPile = const [],
    Card? drawnCard,
  })  : _players = List.unmodifiable(players),
        _drawPile = List.of(drawPile),
        _discardPile = List.of(discardPile),
        _currentPlayerIndex = 0,
        _drawnCard = drawnCard;

  /// Sets up a new game for [players], in turn order, with the full deck
  /// from [buildDeck] shuffled into the draw pile and an empty discard
  /// pile.
  ///
  /// Pass a seeded [random] for a reproducible game.
  ///
  /// Throws an [ArgumentError] if there are fewer than [minPlayers] or more
  /// than [maxPlayers] players.
  factory GameController.start(
    List<Player> players, {
    Random? random,
  }) {
    if (players.length < minPlayers || players.length > maxPlayers) {
      throw ArgumentError.value(
        players.length,
        'players',
        'Must have between $minPlayers and $maxPlayers players',
      );
    }

    final deck = buildDeck();
    shuffle(deck, random);

    return GameController(players: players, drawPile: deck);
  }

  /// The players in turn order.
  List<Player> get players => _players;

  /// The cards still to be drawn, with the top of the pile last.
  List<Card> get drawPile => UnmodifiableListView(_drawPile);

  /// The discarded cards, with the most recently discarded card last.
  List<Card> get discardPile => UnmodifiableListView(_discardPile);

  /// The index into [players] of the player whose turn it is.
  int get currentPlayerIndex => _currentPlayerIndex;

  /// The player whose turn it is.
  Player get currentPlayer => _players[_currentPlayerIndex];

  /// The card the current player has drawn and not yet played, or `null`
  /// if they haven't drawn one.
  Card? get drawnCard => _drawnCard;

  /// Removes the top card from the draw pile and holds it as the
  /// [drawnCard] until the current player plays it.
  ///
  /// Throws a [StateError] if a card has already been drawn and not yet
  /// played, or if the draw pile is empty.
  void drawFromDrawPile() {
    if (_drawnCard != null) {
      throw StateError('A drawn card must be played before drawing another');
    }

    if (_drawPile.isEmpty) {
      throw StateError('Cannot draw from an empty draw pile');
    }

    _drawnCard = _drawPile.removeLast();
  }

  /// Removes the top card from the discard pile and holds it as the
  /// [drawnCard] until the current player plays it.
  ///
  /// Throws a [StateError] if a card has already been drawn and not yet
  /// played, or if the discard pile is empty.
  void drawFromDiscardPile() {
    if (_drawnCard != null) {
      throw StateError('A drawn card must be played before drawing another');
    }

    if (_discardPile.isEmpty) {
      throw StateError('Cannot draw from an empty discard pile');
    }

    _drawnCard = _discardPile.removeLast();
  }

  /// Plays the [drawnCard] for the current player.
  ///
  /// A [CardType.standard] card is placed on the current player's plate if
  /// the slot for its category is empty; otherwise the slot is blocked, so
  /// the card goes on top of the discard pile instead. Either way, the
  /// current player no longer holds a drawn card.
  ///
  /// Playing a [CardType.spoiled] card is not yet supported: it throws an
  /// [UnimplementedError] and the current player still holds the card.
  ///
  /// Throws a [StateError] if no card has been drawn.
  void playDrawnCard() {
    final card = _drawnCard;

    if (card == null) {
      throw StateError('A card must be drawn before it can be played');
    }

    if (card.type == CardType.spoiled) {
      throw UnimplementedError('Playing a spoiled card is not yet supported');
    }

    final plate = currentPlayer.plate;

    if (plate[card.category] == null) {
      plate.place(card);
    } else {
      _discardPile.add(card);
    }

    _drawnCard = null;
  }
}
