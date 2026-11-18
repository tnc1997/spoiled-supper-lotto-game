import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';

import 'heading.dart';
import 'player_count_selector.dart';
import 'player_name_field.dart';

/// The screen for setting up a Pass & Play game on this device: how many
/// players are playing, and, optionally, their names and their own card
/// images.
class SetupScreen extends StatefulWidget {
  /// Called when the button to choose card images is pressed, or `null` to
  /// disable it.
  ///
  /// The button is disabled, showing progress, until the [Future] this
  /// returns completes, so the player can't start choosing again while
  /// their images are still loading.
  final Future<void> Function()? onChooseCardImages;

  /// Called with the names of the players playing, in turn order, when the
  /// start button is pressed, or `null` to disable it.
  final ValueChanged<List<String>>? onStart;

  /// Shows the setup screen, calling [onChooseCardImages] when the button
  /// to choose card images is pressed, and [onStart] with the players'
  /// names when the start button is pressed.
  const SetupScreen({super.key, this.onChooseCardImages, this.onStart});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

/// The state of a [SetupScreen], holding the players' choices.
class _SetupScreenState extends State<SetupScreen> {
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

  /// Whether the player's card images are being chosen or loaded.
  bool _isChoosingCardImages = false;

  /// The names of the players playing, in turn order, with the default
  /// name of any player who didn't type one.
  ///
  /// Two players may have the same name until it's changed, in which case
  /// their name fields show an error.
  List<String> get playerNames {
    return [
      for (var index = 0; index < _playerCount; index++)
        PlayerNameField.nameOf(index + 1, _nameControllers[index].text),
    ];
  }

  /// The error to show on each playing player's name field, in turn order,
  /// or `null` for a field without one.
  ///
  /// A field shows an error if the name typed into it is the same as
  /// another player's. Default names are all different, so every clash
  /// involves at least one typed name, and so shows an error somewhere.
  /// A player left with their default name isn't asked to change it.
  List<String?> get _nameErrors {
    final names = playerNames;

    return [
      for (var index = 0; index < names.length; index++)
        if (names[index] == PlayerNameField.defaultNameOf(index + 1))
          null
        else
          _duplicateErrorOf(names, index),
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
              ListenableBuilder(
                listenable: Listenable.merge(_nameControllers),
                builder: (context, child) {
                  final errors = _nameErrors;
                  final onStart = widget.onStart;

                  // Two players with the same name can't start the game
                  // until one of them changes it.
                  final hasDuplicateNames =
                      errors.any((error) => error != null);

                  return Column(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          spacing: 8,
                          children: [
                            for (var index = 0; index < _playerCount; index++)
                              PlayerNameField(
                                number: index + 1,
                                controller: _nameControllers[index],
                                textInputAction: index == _playerCount - 1
                                    ? TextInputAction.done
                                    : TextInputAction.next,
                                errorText: errors[index],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      child!,
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: onStart == null || hasDuplicateNames
                            ? null
                            : () => onStart(playerNames),
                        child: const Text('Start'),
                      ),
                    ],
                  );
                },
                // The card images section, shown by the builder between the
                // name fields and the start button. It doesn't depend on the
                // names, so it's passed in as the child rather than built
                // there, and isn't rebuilt as they're typed. Splitting the
                // builder in two instead would work out the name errors
                // twice, once for the fields and once for the start button.
                child: Column(
                  children: [
                    const Heading('Do you have your own card images?'),
                    const SizedBox(height: 16),
                    _buildChooseCardImagesButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the button to choose card images, disabled and showing
  /// progress while they're being chosen.
  Widget _buildChooseCardImagesButton() {
    final onChooseCardImages = widget.onChooseCardImages;

    return OutlinedButton.icon(
      onPressed: onChooseCardImages == null || _isChoosingCardImages
          ? null
          : () => _chooseCardImages(onChooseCardImages),
      icon: _isChoosingCardImages
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.photo_library_outlined),
      label: const Text('Choose card images'),
    );
  }

  /// Calls [onChooseCardImages], disabling the button until it completes.
  Future<void> _chooseCardImages(
    Future<void> Function() onChooseCardImages,
  ) async {
    setState(() => _isChoosingCardImages = true);

    try {
      await onChooseCardImages();
    } finally {
      if (mounted) {
        setState(() => _isChoosingCardImages = false);
      }
    }
  }

  /// Returns the error to show for the player at [index] in [names] if
  /// another player has the same name, or `null` if none does.
  static String? _duplicateErrorOf(List<String> names, int index) {
    for (var other = 0; other < names.length; other++) {
      if (other != index &&
          PlayerNameField.isSameName(names[index], names[other])) {
        return 'Another player is called ${names[other]}. '
            'Add an initial to tell them apart.';
      }
    }

    return null;
  }
}
