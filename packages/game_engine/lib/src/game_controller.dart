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
  final Random? _random;
  Card? _drawnCard;

  /// Holds the given state as-is, with the first player taking the first
  /// turn.
  ///
  /// [players] are in turn order, and the top of each pile is its last
  /// card. [drawnCard] is a card the current player has already drawn and
  /// not yet played. Pass a seeded [random] for reproducible reshuffles of
  /// the discard pile. To set up a new game, use [GameController.start]
  /// instead.
  GameController({
    required List<Player> players,
    required List<Card> drawPile,
    List<Card> discardPile = const [],
    Card? drawnCard,
    Random? random,
  })  : _players = List.unmodifiable(players),
        _drawPile = List.of(drawPile),
        _discardPile = List.of(discardPile),
        _currentPlayerIndex = 0,
        _random = random,
        _drawnCard = drawnCard;

  /// Sets up a new game for [players], in turn order, with the full deck
  /// from [buildDeck] shuffled into the draw pile and an empty discard
  /// pile.
  ///
  /// Pass a seeded [random] for a reproducible game, including any
  /// reshuffles of the discard pile.
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

    return GameController(players: players, drawPile: deck, random: random);
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

  /// Whether [placeDrawnCard] can be called, i.e. a card has been drawn
  /// and it's either a [CardType.standard] card or its slot on the current
  /// player's plate is empty.
  bool get canPlaceDrawnCard {
    final card = _drawnCard;

    return card != null &&
        (card.type == CardType.standard ||
            currentPlayer.plate[card.category] == null);
  }

  /// Whether [discardDrawnCard] can be called, i.e. a card has been drawn
  /// and its slot on the current player's plate is filled.
  bool get canDiscardDrawnCard {
    final card = _drawnCard;

    return card != null && currentPlayer.plate[card.category] != null;
  }

  /// Whether [drawFromDrawPile] can be called, i.e. no card has been drawn
  /// yet and either the draw pile or the discard pile has cards in it.
  bool get canDrawFromDrawPile =>
      _drawnCard == null && (_drawPile.isNotEmpty || _discardPile.isNotEmpty);

  /// Removes the top card from the draw pile and holds it as the
  /// [drawnCard] until the current player plays it.
  ///
  /// If the draw pile is empty, the whole discard pile, including its top
  /// card, is first shuffled into it, leaving the discard pile empty.
  ///
  /// Throws a [StateError] if a card has already been drawn and not yet
  /// played, or if both the draw pile and the discard pile are empty.
  void drawFromDrawPile() {
    if (_drawnCard != null) {
      throw StateError('A drawn card must be played before drawing another');
    }

    if (_drawPile.isEmpty) {
      if (_discardPile.isEmpty) {
        throw StateError(
          'Cannot draw when both the draw and discard piles are empty',
        );
      }

      _drawPile.addAll(_discardPile);
      _discardPile.clear();
      shuffle(_drawPile, _random);
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

    if (!canPlaceDrawnCard) {
      throw StateError(
        'A spoiled card must be discarded if the '
        '${card.category.name} slot is filled',
      );
    }

    final replaced = currentPlayer.plate.place(card);

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

    if (!canDiscardDrawnCard) {
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
