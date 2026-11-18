import 'package:material_ui/material_ui.dart';

import 'card_images.dart';
import 'card_images_data.dart';

/// Lets the player choose their own card images, and uses them for the
/// whole session by setting them in the closest [CardImages], which must be
/// above it.
///
/// While they're being chosen, the button is disabled and shrinks around a
/// progress indicator, like Material 3's loading indicator, and then grows
/// back. Afterwards, a snack bar says how many cards the player has images
/// of, or why their images are unchanged.
class CardImagesButton extends StatefulWidget {
  /// Shows the button to choose card images.
  const CardImagesButton({super.key});

  @override
  State<CardImagesButton> createState() => _CardImagesButtonState();
}

/// The state of a [CardImagesButton], tracking whether images are being
/// chosen.
class _CardImagesButtonState extends State<CardImagesButton> {
  /// Whether the player's card images are being chosen or loaded.
  bool _isChoosing = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _isChoosing ? null : _choose,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: _isChoosing
            ? const CircularProgressIndicator(
                strokeWidth: 2,
                semanticsLabel: 'Loading card images',
                constraints: BoxConstraints.tightFor(width: 18, height: 18),
              )
            : const Text('Choose card images'),
      ),
    );
  }

  /// Asks the player to choose their own card images, disabling the button
  /// until they're loaded, and uses them in place of the ones used before.
  ///
  /// Keeps the images already chosen if the player cancels, if choosing
  /// them fails, or if none of the files chosen are named after a card,
  /// telling the player why in the last two cases.
  Future<void> _choose() async {
    setState(() => _isChoosing = true);

    final CardImagesData? images;
    try {
      images = await CardImagesData.pick();
    } catch (exception, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'card images',
          context: ErrorDescription('while choosing card images'),
        ),
      );
      _finish("Your card images couldn't be opened. Please try again.");
      return;
    }

    if (images == null) {
      _finish();
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
      _finish(
        'None of the files you chose are named after a card, so your card '
        'images are unchanged.',
      );
      return;
    }

    CardImages.of(context).images = images;

    _finish(
      images.length == 1
          ? 'Using your image of 1 card.'
          : 'Using your images of ${images.length} cards.',
    );
  }

  /// Enables the button again, and shows [message], if there is one, in a
  /// snack bar in place of any already showing.
  void _finish([String? message]) {
    if (!mounted) {
      return;
    }

    setState(() => _isChoosing = false);

    if (message != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
