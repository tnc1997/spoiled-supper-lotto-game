import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'card_images.dart';
import 'card_images_scope.dart';
import 'game_screen.dart';
import 'home_screen.dart';
import 'setup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  /// Asks the player to choose their own card images, returning `null` if
  /// they cancel.
  ///
  /// Defaults to [CardImages.pick]; a test can pass its own.
  final Future<CardImages?> Function() pickCardImages;

  const MyApp({super.key, this.pickCardImages = CardImages.pick});

  @override
  State<MyApp> createState() => _MyAppState();
}

/// The state of [MyApp], holding the player's own card images.
class _MyAppState extends State<MyApp> {
  /// The player's own card images, shown on every screen, or
  /// [CardImages.empty] until they choose some.
  CardImages _cardImages = CardImages.empty;

  @override
  void dispose() {
    _cardImages.dispose();

    super.dispose();
  }

  /// Asks the player to choose their own card images, and shows them in
  /// place of the ones shown before, unless the player cancels.
  Future<void> _chooseCardImages() async {
    final images = await widget.pickCardImages();

    if (images == null) {
      return;
    }

    if (!mounted) {
      images.dispose();
      return;
    }

    final oldImages = _cardImages;
    setState(() => _cardImages = images);

    // Every Card widget rebuilds with the new images before the next
    // frame is painted, so none paints the old ones after this.
    oldImages.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spoiled Supper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.caprasimo(),
          displayMedium: GoogleFonts.caprasimo(),
          displaySmall: GoogleFonts.caprasimo(),
          headlineLarge: GoogleFonts.fredoka(),
          headlineMedium: GoogleFonts.fredoka(),
          headlineSmall: GoogleFonts.fredoka(),
          titleLarge: GoogleFonts.fredoka(),
          titleMedium: GoogleFonts.fredoka(),
          titleSmall: GoogleFonts.fredoka(),
          bodyLarge: GoogleFonts.fredoka(),
          bodyMedium: GoogleFonts.fredoka(),
          bodySmall: GoogleFonts.fredoka(),
          labelLarge: GoogleFonts.fredoka(),
          labelMedium: GoogleFonts.fredoka(),
          labelSmall: GoogleFonts.fredoka(),
        ),
      ),
      // Wraps the navigator, so that every screen, including the setup and
      // game screens, shows the player's own card images.
      builder: (context, child) {
        return CardImagesScope(images: _cardImages, child: child!);
      },
      home: Builder(
        builder: (context) {
          return HomeScreen(
            onPlay: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) {
                    return SetupScreen(
                      onChooseCardImages: _chooseCardImages,
                      onStart: (playerNames) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) {
                              return GameScreen(playerNames: playerNames);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
