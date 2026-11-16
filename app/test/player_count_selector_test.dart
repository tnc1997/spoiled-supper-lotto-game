import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/player_count_selector.dart';

void main() {
  group(
    'PlayerCountSelector',
    () {
      /// Shows a [PlayerCountSelector] with [playerCount] chosen, calling
      /// [onChanged].
      Future<void> pumpSelector(
        WidgetTester tester, {
        int playerCount = 2,
        ValueChanged<int>? onChanged,
      }) {
        return tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PlayerCountSelector(
                playerCount: playerCount,
                onChanged: onChanged,
              ),
            ),
          ),
        );
      }

      /// Returns the segmented button of the selector on screen.
      SegmentedButton<int> segmentedButtonOf(WidgetTester tester) {
        return tester.widget<SegmentedButton<int>>(
          find.byType(SegmentedButton<int>),
        );
      }

      testWidgets(
        'offers 2, 3, and 4 players',
        (tester) async {
          await pumpSelector(tester);

          expect(
            segmentedButtonOf(tester).segments.map((segment) => segment.value),
            [2, 3, 4],
          );
        },
      );

      testWidgets(
        'shows the chosen number of players as selected',
        (tester) async {
          await pumpSelector(tester, playerCount: 3);

          expect(segmentedButtonOf(tester).selected, {3});
        },
      );

      testWidgets(
        'calls onChanged with the number of players chosen',
        (tester) async {
          int? chosen;

          await pumpSelector(tester, onChanged: (count) => chosen = count);
          await tester.tap(find.text('4 players'));

          expect(chosen, 4);
        },
      );

      testWidgets(
        'disables every option without onChanged',
        (tester) async {
          await pumpSelector(tester);

          expect(
            segmentedButtonOf(tester)
                .segments
                .map((segment) => segment.enabled),
            everyElement(isFalse),
          );
        },
      );

      testWidgets(
        'labels the selector for screen readers',
        (tester) async {
          await pumpSelector(tester);

          expect(find.bySemanticsLabel('Number of players'), findsOneWidget);
        },
      );
    },
  );
}
