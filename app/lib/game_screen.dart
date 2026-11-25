import 'dart:math';

import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';

import 'discard_pile.dart';
import 'draw_pile.dart';
import 'drawn_card.dart';
import 'drawn_card_actions.dart';
import 'game_notifier.dart';
import 'game_scope.dart';
import 'heading.dart';
import 'plate.dart';

/// The screen for playing a new Pass & Play game between players with the
/// names given, which sets up the game and exposes it through a [GameScope]
/// to the widgets below it.
class GameScreen extends StatefulWidget {
  /// The names of the players, in turn order.
  final List<String> playerNames;

  /// The source of randomness for shuffling the deck, or `null` for a
  /// different game each time.
  final Random? random;

  /// Shows a new game between players named [playerNames], in turn order,
  /// with the deck shuffled by [random].
  const GameScreen({super.key, required this.playerNames, this.random});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

/// The state of a [GameScreen], owning the game being played.
class _GameScreenState extends State<GameScreen> {
  /// The height of the screen's body, in logical pixels, below which the
  /// board would be shrunk too small to read or tap if it were fitted to
  /// the height left, so it's fitted to the width instead, and the screen
  /// scrolls.
  static const _minFillHeight = 480.0;

  /// The padding around the screen's body, in logical pixels.
  static const _padding = 24.0;

  late final GameNotifier _notifier;

  /// The key of the plate, so that the drawn card can find its slot on it.
  final _plateKey = GlobalKey();

  /// The key of the discard pile's top card, so that the drawn card can
  /// find where to go when it's discarded.
  final _discardPileCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _notifier = GameNotifier(
      engine.GameController.start(
        [for (final name in widget.playerNames) engine.Player(name: name)],
        random: widget.random,
      ),
    );
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScope(
      notifier: _notifier,
      child: Scaffold(
        appBar: AppBar(title: const Text('Pass & Play')),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final fill = constraints.maxHeight >= _minFillHeight;
            final player = GameScope.of(context).game.currentPlayer;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(_padding),
                child: SizedBox(
                  // Fills the screen's height, so that the board can grow to
                  // fill the space left, unless the screen is too short.
                  height: fill ? constraints.maxHeight - 2 * _padding : null,
                  child: Column(
                    spacing: 24,
                    children: [
                      // Announces each new turn to a screen reader.
                      Semantics(
                        liveRegion: true,
                        child: Heading(
                          "${player.name}'s turn",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      // Scales the plate and piles together, so that the
                      // piles' cards stay the size of the plate's: to fill
                      // the space left, growing them on large screens, or,
                      // on short screens, to fit the width, shrinking them
                      // rather than overflowing on narrow ones.
                      Flexible(
                        flex: fill ? 1 : 0,
                        fit: FlexFit.tight,
                        child: FittedBox(
                          fit: fill ? BoxFit.contain : BoxFit.scaleDown,
                          child: Column(
                            spacing: 24,
                            children: [
                              Plate(key: _plateKey, player: player),
                              // Lines up the cards' tops, rather than
                              // centring them, so that the piles' count
                              // labels hang below and don't push the drawn
                              // card down.
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 24,
                                children: [
                                  const DrawPile(),
                                  DiscardPile(
                                    cardKey: _discardPileCardKey,
                                  ),
                                  DrawnCard(
                                    plateKey: _plateKey,
                                    discardPileKey: _discardPileCardKey,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Keeps the drawn card's actions full size, below
                      // the table, so that they're easy to tap.
                      const DrawnCardActions(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
