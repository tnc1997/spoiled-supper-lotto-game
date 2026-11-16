import 'package:material_ui/material_ui.dart';

import 'heading.dart';

/// The first screen of the game: its title, and a button to start playing.
///
/// The title is set in the `displayLarge` text style, which is reserved
/// for it, and everything else in the theme's other styles.
class HomeScreen extends StatelessWidget {
  /// Called when the play button is pressed, or `null` to disable it.
  final VoidCallback? onPlay;

  /// Shows the home screen, calling [onPlay] when the play button is
  /// pressed.
  const HomeScreen({super.key, this.onPlay});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Heading('Spoiled Supper', style: textTheme.displayLarge),
              const SizedBox(height: 48),
              FilledButton(
                onPressed: onPlay,
                child: const Text('Play'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
