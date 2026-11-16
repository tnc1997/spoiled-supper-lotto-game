import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/heading.dart';

void main() {
  group(
    'Heading',
    () {
      const titleLarge = TextStyle(fontFamily: 'Fredoka');

      /// Shows [heading], with a text theme whose `titleLarge` style is
      /// [titleLarge].
      Future<void> pumpHeading(WidgetTester tester, Heading heading) {
        return tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              textTheme: const TextTheme(titleLarge: titleLarge),
            ),
            home: Scaffold(body: heading),
          ),
        );
      }

      testWidgets(
        'marks the text as a header',
        (tester) async {
          await pumpHeading(tester, const Heading('Players'));

          expect(
            tester.getSemantics(find.text('Players')),
            matchesSemantics(label: 'Players', isHeader: true),
          );
        },
      );

      testWidgets(
        'centres the text',
        (tester) async {
          await pumpHeading(tester, const Heading('Players'));

          final text = tester.widget<Text>(find.text('Players'));

          expect(text.textAlign, TextAlign.center);
        },
      );

      testWidgets(
        'uses the titleLarge text style without a style',
        (tester) async {
          await pumpHeading(tester, const Heading('Players'));

          final text = tester.widget<Text>(find.text('Players'));

          expect(text.style?.fontFamily, titleLarge.fontFamily);
        },
      );

      testWidgets(
        'uses the style given',
        (tester) async {
          const style = TextStyle(fontFamily: 'Caprasimo');

          await pumpHeading(tester, const Heading('Players', style: style));

          final text = tester.widget<Text>(find.text('Players'));

          expect(text.style?.fontFamily, style.fontFamily);
        },
      );
    },
  );
}
