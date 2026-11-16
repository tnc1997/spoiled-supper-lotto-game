import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';

import 'heading.dart';
import 'player_count_selector.dart';
import 'player_name_field.dart';

/// The screen for setting up a Pass & Play game on this device: how many
/// players are playing, and, optionally, their names.
class SetupScreen extends StatefulWidget {
  /// Shows the setup screen.
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => SetupScreenState();
}

/// The state of a [SetupScreen], holding the players' choices.
class SetupScreenState extends State<SetupScreen> {
  /// The names typed for every player the game allows, so a name is kept
  /// if the number of players goes down and then back up.
  ///
  /// Only the first [_playerCount] are playing, so read their names with
  /// [playerNames] rather than from here.
  final _nameControllers = List.generate(
    engine.GameController.maxPlayers,
    (_) => TextEditingController(),
  );

  int _playerCount = engine.GameController.minPlayers;

  /// The names of the players playing, in turn order, with the default
  /// name of any player who didn't type one.
  List<String> get playerNames {
    return [
      for (var index = 0; index < _playerCount; index++)
        PlayerNameField.nameOf(index + 1, _nameControllers[index].text),
    ];
  }

  @override
  void dispose() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pass & Play')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Heading('How many players?'),
              const SizedBox(height: 16),
              PlayerCountSelector(
                playerCount: _playerCount,
                onChanged: (playerCount) {
                  setState(() => _playerCount = playerCount);
                },
              ),
              const SizedBox(height: 32),
              const Heading("What are the players' names?"),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    for (var index = 0; index < _playerCount; index++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: PlayerNameField(
                          number: index + 1,
                          controller: _nameControllers[index],
                          textInputAction: index == _playerCount - 1
                              ? TextInputAction.done
                              : TextInputAction.next,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
