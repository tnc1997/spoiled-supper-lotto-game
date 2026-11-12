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

  /// Places the [drawnCard] into the slot for its category on the current
  /// player's plate.
  ///
  /// If the slot already has a card, the player has chosen to keep the
  /// drawn food card instead, so the card it replaces goes on top of the
  /// discard pile. Either way, the current player no longer holds a drawn
  /// card.
  ///
  /// Throws a [StateError] if no card has been drawn, or if the drawn card
  /// is [CardType.spoiled] and the slot already has a card, since a spoiled
  /// card can only go into an empty slot.
  void placeDrawnCard() {
    final card = _requireDrawnCard();
    final plate = currentPlayer.plate;

    if (card.type == CardType.spoiled && plate[card.category] != null) {
      throw StateError(
        'A spoiled card must be discarded if the '
        '${card.category.name} slot is filled',
      );
    }

    final replaced = plate.place(card);

    if (replaced != null) {
      _discardPile.add(replaced);
    }

    _drawnCard = null;
  }

  /// Puts the [drawnCard] on top of the discard pile, keeping the card
  /// already in the slot for its category on the current player's plate.
  ///
  /// Throws a [StateError] if no card has been drawn, or if the slot for
  /// its category is empty, since a card that fits must be placed.
  void discardDrawnCard() {
    final card = _requireDrawnCard();

    if (currentPlayer.plate[card.category] == null) {
      throw StateError(
        'A card must be placed if the ${card.category.name} slot is empty',
      );
    }

    _discardPile.add(card);
    _drawnCard = null;
  }

  /// Returns the [drawnCard], checking that one has been drawn.
  Card _requireDrawnCard() {
    final card = _drawnCard;

    if (card == null) {
      throw StateError('A card must be drawn before it can be played');
    }

    return card;
  }
}
