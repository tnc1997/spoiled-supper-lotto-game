import 'package:material_ui/material_ui.dart';

/// Lets a player optionally type their name, falling back to a default
/// name, such as "Player 1", when they leave it empty.
///
/// Read the name to play under with [nameOf], which applies the default.
class PlayerNameField extends StatelessWidget {
  /// The most characters a name can have, so it fits wherever it's shown.
  static const maxLength = 20;

  /// The player's number, counting from 1.
  final int number;

  /// Controls the name typed into the field.
  final TextEditingController? controller;

  /// Shows a field for the name of the player numbered [number], counting
  /// from 1, with the name typed into it held by [controller].
  const PlayerNameField({
    super.key,
    required this.number,
    this.controller,
  }) : assert(number >= 1);

  /// Returns the default name of the player numbered [number], counting
  /// from 1, such as "Player 1".
  static String defaultNameOf(int number) => 'Player $number';

  /// Returns the name of the player numbered [number], counting from 1,
  /// who typed [text]: the text without surrounding whitespace, or their
  /// default name if that leaves it empty.
  static String nameOf(int number, String text) {
    final name = text.trim();

    return name.isEmpty ? defaultNameOf(number) : name;
  }

  @override
  Widget build(BuildContext context) {
    final defaultName = defaultNameOf(number);

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: '$defaultName name',
        hintText: defaultName,
        helperText: 'Optional',
      ),
      maxLength: maxLength,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
    );
  }
}
