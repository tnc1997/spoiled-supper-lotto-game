import 'dart:math';

import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';

import 'discard_pile.dart';
import 'draw_pile.dart';
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
  late final GameNotifier _notifier;

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
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Builder(
              builder: (context) {
                final player = GameScope.of(context).game.currentPlayer;

                return Column(
                  spacing: 24,
                  children: [
                    Heading("${player.name}'s turn"),
                    // Shrinks the plate and piles together, rather than
                    // overflowing, on narrow screens, so that the piles'
                    // cards stay the size of the plate's.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        spacing: 24,
                        children: [
                          Plate(player: player),
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 24,
                            children: [DrawPile(), DiscardPile()],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
