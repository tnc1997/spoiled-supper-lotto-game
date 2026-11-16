import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/home_screen.dart';

void main() {
  group(
    'HomeScreen',
    () {
      const displayLarge = TextStyle(fontFamily: 'Caprasimo');

      /// Shows a [HomeScreen] calling [onPlay], with a text theme whose
      /// `displayLarge` style is [displayLarge].
      Future<void> pumpHomeScreen(
        WidgetTester tester, {
        VoidCallback? onPlay,
      }) {
        return tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              textTheme: const TextTheme(displayLarge: displayLarge),
            ),
            home: HomeScreen(onPlay: onPlay),
          ),
        );
      }

      testWidgets(
        'shows the title of the game',
        (tester) async {
          await pumpHomeScreen(tester);

          expect(find.text('Spoiled Supper'), findsOneWidget);
        },
      );

      testWidgets(
        'shows the title in the displayLarge text style',
        (tester) async {
          await pumpHomeScreen(tester);

          final title = tester.widget<Text>(find.text('Spoiled Supper'));

          expect(title.style?.fontFamily, displayLarge.fontFamily);
        },
      );

      testWidgets(
        'marks the title as a header',
        (tester) async {
          final handle = tester.ensureSemantics();

          await pumpHomeScreen(tester);

          expect(
            tester.getSemantics(find.text('Spoiled Supper')),
            matchesSemantics(label: 'Spoiled Supper', isHeader: true),
          );

          handle.dispose();
        },
      );

      testWidgets(
        'calls onPlay when the play button is pressed',
        (tester) async {
          var played = false;

          await pumpHomeScreen(tester, onPlay: () => played = true);
          await tester.tap(find.widgetWithText(FilledButton, 'Play'));

          expect(played, isTrue);
        },
      );

      testWidgets(
        'disables the play button without onPlay',
        (tester) async {
          await pumpHomeScreen(tester);

          final button = tester.widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Play'),
          );

          expect(button.enabled, isFalse);
        },
      );
    },
  );
}
