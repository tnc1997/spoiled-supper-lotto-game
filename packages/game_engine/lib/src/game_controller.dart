import 'dart:collection';
import 'dart:math';

import 'card.dart';
import 'card_type.dart';
import 'deck.dart';
import 'notifier.dart';
import 'player.dart';
import 'shuffle.dart';

/// Holds the state of a single game: its players, the draw and discard
/// piles, and whose turn it is.
///
/// Listeners are notified once after each move, i.e. each successful call
/// to [drawFromDrawPile], [drawFromDiscardPile], [placeDrawnCard] or
/// [discardDrawnCard], and whenever a card is placed directly on one of
/// the players' plates. A move that throws doesn't notify them.
class GameController with Notifier {
  /// The fewest players a game can be started with.
  static const minPlayers = 2;

  /// The most players a game can be started with.
  static const maxPlayers = 4;

  final List<Player> _players;
  final List<Card> _drawPile;
  final List<Card> _discardPile;
  int _currentPlayerIndex;
  int? _lastPlayerIndex;
  int? _winnerIndex;
  Card? _drawnCard;
  final Random? _random;
  bool _isMakingMove = false;

  /// Holds the given state as-is.
  ///
  /// [players] are in turn order, and the top of each pile is its last
  /// card. [currentPlayerIndex] is the index into [players] of the player
  /// whose turn it is, and [drawnCard] is a card they have already drawn
  /// and not yet played. A player whose plate is already full is the
  /// [winner], so the game is over and [currentPlayerIndex] defaults to
  /// theirs; otherwise it defaults to the first player's. Pass a seeded
  /// [random] for reproducible reshuffles of the discard pile. To set up a
  /// new game, use [GameController.start] instead.
  ///
  /// Throws an [ArgumentError] if there are fewer than [minPlayers] or more
  /// than [maxPlayers] players, if more than one player's plate is full,
  /// since a game can only have one winner, if [currentPlayerIndex] is out
  /// of range, or if it isn't the winner's index once the game is over.
  GameController({
    required List<Player> players,
    required List<Card> drawPile,
    List<Card> discardPile = const [],
    int? currentPlayerIndex,
    Card? drawnCard,
    Random? random,
  })  : _players = List.unmodifiable(players),
        _drawPile = List.of(drawPile),
        _discardPile = List.of(discardPile),
        _currentPlayerIndex = currentPlayerIndex ?? 0,
        _winnerIndex = _findWinnerIndex(players),
        _drawnCard = drawnCard,
        _random = random {
    if (_players.length < minPlayers || _players.length > maxPlayers) {
      throw ArgumentError.value(
        _players.length,
        'players',
        'Must have between $minPlayers and $maxPlayers players',
      );
    }

    RangeError.checkValidIndex(
      _currentPlayerIndex,
      _players,
      'currentPlayerIndex',
    );

    final winnerIndex = _winnerIndex;

    if (winnerIndex != null) {
      if (currentPlayerIndex != null && currentPlayerIndex != winnerIndex) {
        throw ArgumentError.value(
          currentPlayerIndex,
          'currentPlayerIndex',
          'Must be the index of the winner, ${_players[winnerIndex].name}',
        );
      }

      _currentPlayerIndex = winnerIndex;
    }

    for (final player in _players) {
      player.plate.addListener(_handlePlateChanged);
    }
  }

  /// Sets up a new game for [players], in turn order, with the full deck
  /// from [buildDeck] shuffled into the draw pile and an empty discard
  /// pile.
  ///
  /// Pass a seeded [random] for a reproducible game, including any
  /// reshuffles of the discard pile.
  ///
  /// Throws an [ArgumentError] if there are fewer than [minPlayers] or more
  /// than [maxPlayers] players, as the [GameController.new] constructor
  /// does.
  factory GameController.start(
    List<Player> players, {
    Random? random,
  }) {
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

  /// The index into [players] of the player whose turn it is. Once the
  /// game is over, this stays as the [winner]'s index.
  int get currentPlayerIndex => _currentPlayerIndex;

  /// The player whose turn it is. Once the game is over, this stays as the
  /// [winner].
  Player get currentPlayer => _players[_currentPlayerIndex];

  /// The index into [players] of the player who most recently played a
  /// drawn card, by placing or discarding it, or `null` if no card has been
  /// played since this controller was created.
  int? get lastPlayerIndex => _lastPlayerIndex;

  /// The player who most recently played a drawn card, by placing or
  /// discarding it, or `null` if no card has been played since this
  /// controller was created.
  ///
  /// Use this to show the result of a play once the turn has passed to the
  /// next player. After a winning play, this is the [winner], since the
  /// turn doesn't pass.
  Player? get lastPlayer {
    final index = _lastPlayerIndex;

    return index == null ? null : _players[index];
  }

  /// The index into [players] of the player who completed their meal and
  /// won the game, or `null` if no one has won yet.
  int? get winnerIndex => _winnerIndex;

  /// The player who completed their meal and won the game, or `null` if
  /// no one has won yet.
  ///
  /// This is recorded when [placeDrawnCard] fills the current player's
  /// plate, and doesn't change once set, even if a plate is changed
  /// directly.
  Player? get winner {
    final index = _winnerIndex;

    return index == null ? null : _players[index];
  }

  /// Whether the game has ended because a player has won, after which no
  /// more cards can be drawn, placed or discarded.
  bool get isGameOver => _winnerIndex != null;

  /// The card the current player has drawn and not yet played, or `null`
  /// if they haven't drawn one.
  Card? get drawnCard => _drawnCard;

  /// Whether [placeDrawnCard] can be called, i.e. the game isn't over, a
  /// card has been drawn and it's either a [CardType.standard] card or its
  /// slot on the current player's plate is empty.
  bool get canPlaceDrawnCard {
    final card = _drawnCard;

    return !isGameOver &&
        card != null &&
        (card.type == CardType.standard ||
            currentPlayer.plate[card.category] == null);
  }

  /// Whether [discardDrawnCard] can be called, i.e. the game isn't over, a
  /// card has been drawn and its slot on the current player's plate is
  /// filled.
  bool get canDiscardDrawnCard {
    final card = _drawnCard;

    return !isGameOver &&
        card != null &&
        currentPlayer.plate[card.category] != null;
  }

  /// Whether [drawFromDrawPile] can be called, i.e. the game isn't over, no
  /// card has been drawn yet and either the draw pile or the discard pile
  /// has cards in it.
  bool get canDrawFromDrawPile =>
      !isGameOver &&
      _drawnCard == null &&
      (_drawPile.isNotEmpty || _discardPile.isNotEmpty);

  /// Whether [drawFromDiscardPile] can be called, i.e. the game isn't over,
  /// no card has been drawn yet and the discard pile has cards in it.
  bool get canDrawFromDiscardPile =>
      !isGameOver && _drawnCard == null && _discardPile.isNotEmpty;

  /// Removes the top card from the draw pile and holds it as the
  /// [drawnCard] until the current player plays it.
  ///
  /// If the draw pile is empty, the whole discard pile, including its top
  /// card, is first shuffled into it, leaving the discard pile empty.
  ///
  /// Throws a [StateError] if the game is over, if a card has already been
  /// drawn and not yet played, or if both the draw pile and the discard
  /// pile are empty.
  void drawFromDrawPile() {
    _requireGameNotOver();

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
    notifyListeners();
  }

  /// Removes the top card from the discard pile and holds it as the
  /// [drawnCard] until the current player plays it.
  ///
  /// Throws a [StateError] if the game is over, if a card has already been
  /// drawn and not yet played, or if the discard pile is empty.
  void drawFromDiscardPile() {
    _requireGameNotOver();

    if (_drawnCard != null) {
      throw StateError('A drawn card must be played before drawing another');
    }

    if (_discardPile.isEmpty) {
      throw StateError('Cannot draw from an empty discard pile');
    }

    _drawnCard = _discardPile.removeLast();
    notifyListeners();
  }

  /// Places the [drawnCard] into the slot for its category on the current
  /// player's plate.
  ///
  /// If the slot already has a card, the player has chosen to keep the
  /// drawn food card instead, so the card it replaces goes on top of the
  /// discard pile. Either way, the current player no longer holds a drawn
  /// card. If this completes their meal, they are the [winner] and the
  /// game is over. Otherwise, their turn ends and the next player's turn
  /// begins.
  ///
  /// Throws a [StateError] if the game is over, if no card has been drawn,
  /// or if the drawn card is [CardType.spoiled] and the slot already has a
  /// card, since a spoiled card can only go into an empty slot.
  void placeDrawnCard() {
    _requireGameNotOver();
    final card = _requireDrawnCard();

    if (!canPlaceDrawnCard) {
      throw StateError(
        'A spoiled card must be discarded if the '
        '${card.category.name} slot is filled',
      );
    }

    final Card? replaced;
    _isMakingMove = true;

    try {
      replaced = currentPlayer.plate.place(card);
    } finally {
      _isMakingMove = false;
    }

    if (replaced != null) {
      _discardPile.add(replaced);
    }

    _finishPlay();
  }

  /// Puts the [drawnCard] on top of the discard pile, keeping the card
  /// already in the slot for its category on the current player's plate.
  /// The current player's turn then ends and the next player's turn
  /// begins.
  ///
  /// Throws a [StateError] if the game is over, if no card has been drawn,
  /// or if the slot for its category is empty, since a card that fits must
  /// be placed.
  void discardDrawnCard() {
    _requireGameNotOver();
    final card = _requireDrawnCard();

    if (!canDiscardDrawnCard) {
      throw StateError(
        'A card must be placed if the ${card.category.name} slot is empty',
      );
    }

    _discardPile.add(card);
    _finishPlay();
  }

  /// Finishes the current player's play once their drawn card has been
  /// placed or discarded.
  ///
  /// If their plate is now full, they are the [winner] and the game is
  /// over. Otherwise, the turn passes to the next player in turn order,
  /// going back to the first player after the last. Either way, listeners
  /// are then notified.
  void _finishPlay() {
    _drawnCard = null;
    _lastPlayerIndex = _currentPlayerIndex;

    if (currentPlayer.plate.isFull) {
      _winnerIndex = _currentPlayerIndex;
    } else {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
    }

    notifyListeners();
  }

  /// Notifies listeners of a card placed directly on a player's plate.
  ///
  /// A card placed by [placeDrawnCard] is skipped, since listeners are
  /// notified once the whole move has finished.
  void _handlePlateChanged() {
    if (!_isMakingMove) {
      notifyListeners();
    }
  }

  /// Returns the index into [players] of the player whose plate is full,
  /// or `null` if no one's is.
  ///
  /// Throws an [ArgumentError] if more than one player's plate is full.
  static int? _findWinnerIndex(List<Player> players) {
    int? winnerIndex;

    for (var i = 0; i < players.length; i++) {
      if (!players[i].plate.isFull) {
        continue;
      }

      if (winnerIndex != null) {
        throw ArgumentError.value(
          players,
          'players',
          'Only one player can have a full plate',
        );
      }

      winnerIndex = i;
    }

    return winnerIndex;
  }

  /// Checks that the game isn't over, since no more moves can be made once
  /// a player has won.
  void _requireGameNotOver() {
    final winner = this.winner;

    if (winner != null) {
      throw StateError('The game is over because ${winner.name} has won');
    }
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
