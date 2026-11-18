import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';

import 'card_images.dart';
import 'card_images_data.dart';
import 'heading.dart';
import 'player_count_selector.dart';
import 'player_name_field.dart';

/// The screen for setting up a Pass & Play game on this device: how many
/// players are playing, and, optionally, their names and their own card
/// images.
class SetupScreen extends StatefulWidget {
  /// Asks the player to choose their own card images, returning `null` if
  /// they cancel.
  ///
  /// Defaults to [CardImagesData.pick]; a test can pass its own.
  final Future<CardImagesData?> Function() pickCardImages;

  /// Called with the names of the players playing, in turn order, when the
  /// start button is pressed, or `null` to disable it.
  final ValueChanged<List<String>>? onStart;

  /// Shows the setup screen, choosing card images with [pickCardImages]
  /// for the closest [CardImages], which must be above it, and calling
  /// [onStart] with the players' names when the start button is pressed.
  const SetupScreen({
    super.key,
    this.pickCardImages = CardImagesData.pick,
    this.onStart,
  });

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

  /// Whether the players' card images are being chosen or loaded.
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
    return OutlinedButton.icon(
      onPressed: _isChoosingCardImages ? null : _chooseCardImages,
      icon: _isChoosingCardImages
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.photo_library_outlined),
      label: const Text('Choose card images'),
    );
  }

  /// Asks the player to choose their own card images, disabling the button
  /// until they're loaded, and uses them in place of the ones used before,
  /// for the whole session, by setting them in the closest [CardImages].
  ///
  /// Keeps the images already chosen if the player cancels, if choosing
  /// them fails, or if none of the files chosen are named after a card,
  /// telling the player why in the last two cases.
  Future<void> _chooseCardImages() async {
    setState(() => _isChoosingCardImages = true);

    final CardImagesData? images;
    try {
      images = await widget.pickCardImages();
    } catch (exception, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'card images',
          context: ErrorDescription('while choosing card images'),
        ),
      );
      _finishChoosingCardImages(
        "Your card images couldn't be opened. Please try again.",
      );
      return;
    }

    if (images == null) {
      _finishChoosingCardImages();
      return;
    }

    if (!mounted) {
      images.dispose();
      return;
    }

    // Choosing the wrong folder mustn't throw away the images the player
    // already chose.
    if (images.length == 0) {
      images.dispose();
      _finishChoosingCardImages(
        'None of the files you chose are named after a card, so your card '
        'images are unchanged.',
      );
      return;
    }

    CardImages.of(context).images = images;

    _finishChoosingCardImages(
      images.length == 1
          ? 'Using your image of 1 card.'
          : 'Using your images of ${images.length} cards.',
    );
  }

  /// Enables the button to choose card images again, and shows [message],
  /// if there is one, in a snack bar in place of any already showing.
  void _finishChoosingCardImages([String? message]) {
    if (!mounted) {
      return;
    }

    setState(() => _isChoosingCardImages = false);

    if (message != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
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
