import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/player_count_selector.dart';
import 'package:spoiled_supper_lotto_game/setup_screen.dart';

void main() {
  group(
    'SetupScreen',
    () {
      /// Returns the number of players chosen on the selector on screen.
      int playerCountOf(WidgetTester tester) {
        return tester
            .widget<PlayerCountSelector>(find.byType(PlayerCountSelector))
            .playerCount;
      }

      testWidgets(
        'shows that the game is Pass & Play',
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SetupScreen()));

          expect(find.text('Pass & Play'), findsOneWidget);
        },
      );

      testWidgets(
        'chooses 2 players to start with',
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SetupScreen()));

          expect(playerCountOf(tester), 2);
        },
      );

      testWidgets(
        'chooses the number of players tapped',
        (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SetupScreen()));
          await tester.tap(find.text('3 players'));
          await tester.pump();

          expect(playerCountOf(tester), 3);
        },
      );
    },
  );
}
