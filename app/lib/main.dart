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
  /// The player's own card images, used by every screen, or
  /// [CardImages.empty] until they choose some.
  ///
  /// A notifier, rather than state, so that choosing images only rebuilds
  /// the [CardImagesScope], not the whole app.
  final _cardImages = ValueNotifier(CardImages.empty);

  /// Shows messages about the player's card images on whichever screen is
  /// showing.
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void dispose() {
    _cardImages.value.dispose();
    _cardImages.dispose();

    super.dispose();
  }

  /// Asks the player to choose their own card images, and uses them in
  /// place of the ones used before.
  ///
  /// Keeps the images used before if the player cancels, if choosing them
  /// fails, or if none of the files chosen are named after a card, telling
  /// the player why in the last two cases.
  Future<void> _chooseCardImages() async {
    final CardImages? images;
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
      _showMessage("Your card images couldn't be opened. Please try again.");
      return;
    }

    if (images == null) {
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
      _showMessage(
        'None of the files you chose are named after a card, so your card '
        'images are unchanged.',
      );
      return;
    }

    final oldImages = _cardImages.value;
    _cardImages.value = images;

    // The Card widgets showing the old images haven't rebuilt yet, but it's
    // safe to dispose of them straight away: each RawImage paints its own
    // clone of an image, which it disposes of itself once it's given
    // another.
    oldImages.dispose();

    _showMessage(
      images.length == 1
          ? 'Using your image of 1 card.'
          : 'Using your images of ${images.length} cards.',
    );
  }

  /// Shows [message] in a snack bar, in place of any already showing.
  void _showMessage(String message) {
    _scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spoiled Supper',
      scaffoldMessengerKey: _scaffoldMessengerKey,
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
      // Wraps the navigator, so that every Card widget on every screen,
      // including the setup and game screens, uses the player's own card
      // images.
      builder: (context, child) {
        return ValueListenableBuilder(
          valueListenable: _cardImages,
          builder: (context, images, child) {
            return CardImagesScope(images: images, child: child!);
          },
          child: child,
        );
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
