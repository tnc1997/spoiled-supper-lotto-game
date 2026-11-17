import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'game_screen.dart';
import 'home_screen.dart';
import 'setup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: Builder(
        builder: (context) {
          return HomeScreen(
            onPlay: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) {
                    return SetupScreen(
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
