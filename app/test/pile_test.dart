import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spoiled_supper_lotto_game/card_aspect_ratio.dart';
import 'package:spoiled_supper_lotto_game/card_back.dart';
import 'package:spoiled_supper_lotto_game/card_frame.dart';
import 'package:spoiled_supper_lotto_game/empty_slot.dart';
import 'package:spoiled_supper_lotto_game/pile.dart';

void main() {
  group(
    'Pile',
    () {
      /// Shows [pile] in the middle of the screen.
      Future<void> pumpPile(WidgetTester tester, Pile pile) {
        return tester.pumpWidget(MaterialApp(home: Center(child: pile)));
      }

      testWidgets(
        'shows how many cards are in it',
        (tester) async {
          await pumpPile(
            tester,
            const Pile(
              label: 'Draw pile',
              count: 2,
              card: CardBack(),
              onTap: null,
            ),
          );

          expect(find.text('2 cards'), findsOneWidget);
        },
      );

      testWidgets(
        'shows a single card in the singular',
        (tester) async {
          await pumpPile(
            tester,
            const Pile(
              label: 'Draw pile',
              count: 1,
              card: CardBack(),
              onTap: null,
            ),
          );

          expect(find.text('1 card'), findsOneWidget);
        },
      );

      testWidgets(
        'frames its top card on the table',
        (tester) async {
          await pumpPile(
            tester,
            const Pile(
              label: 'Draw pile',
              count: 1,
              card: CardBack(),
              onTap: null,
            ),
          );

          expect(
            find.descendant(
              of: find.byType(CardFrame),
              matching: find.byType(CardBack),
            ),
            findsOneWidget,
          );
          expect(find.byType(EmptySlot), findsNothing);
        },
      );

      testWidgets(
        'shows that it is empty without a top card',
        (tester) async {
          await pumpPile(
            tester,
            const Pile(
              label: 'Draw pile',
              count: 0,
              card: null,
              onTap: null,
            ),
          );

          expect(find.text('Empty'), findsOneWidget);
          expect(find.text('0 cards'), findsOneWidget);
          expect(find.byType(CardFrame), findsNothing);
        },
      );

      testWidgets(
        'calls onTap when tapped',
        (tester) async {
          var taps = 0;
          await pumpPile(
            tester,
            Pile(
              label: 'Draw pile',
              count: 1,
              card: const CardBack(),
              onTap: () => taps++,
            ),
          );

          await tester.tap(find.byType(Pile));

          expect(taps, 1);
        },
      );

      testWidgets(
        'calls onTap when activated with the keyboard',
        (tester) async {
          var taps = 0;
          await pumpPile(
            tester,
            Pile(
              label: 'Draw pile',
              count: 1,
              card: const CardBack(),
              onTap: () => taps++,
            ),
          );

          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pump();

          expect(taps, 1);
        },
      );

      testWidgets(
        'is announced as one button with its top card and count',
        (tester) async {
          await pumpPile(
            tester,
            Pile(
              label: 'Discard pile',
              count: 2,
              card: Semantics(label: 'Sausages, Main', child: const CardBack()),
              onTap: () {},
            ),
          );

          expect(
            tester.getSemantics(find.byType(Pile)),
            matchesSemantics(
              label: 'Discard pile\nSausages, Main\n2 cards',
              isButton: true,
              hasEnabledState: true,
              isEnabled: true,
              isFocusable: true,
              hasTapAction: true,
              hasFocusAction: true,
            ),
          );
        },
      );

      testWidgets(
        'is announced as a disabled button without onTap',
        (tester) async {
          await pumpPile(
            tester,
            const Pile(
              label: 'Draw pile',
              count: 0,
              card: null,
              onTap: null,
            ),
          );

          expect(
            tester.getSemantics(find.byType(Pile)),
            matchesSemantics(
              label: 'Draw pile\n0 cards',
              isButton: true,
              hasEnabledState: true,
            ),
          );
        },
      );

      testWidgets(
        'tells a screen reader when it has keyboard focus',
        (tester) async {
          await pumpPile(
            tester,
            Pile(
              label: 'Draw pile',
              count: 1,
              card: const CardBack(),
              onTap: () {},
            ),
          );

          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();

          expect(
            tester.getSemantics(find.byType(Pile)),
            isSemantics(
              label: 'Draw pile\n1 card',
              isButton: true,
              isFocusable: true,
              isFocused: true,
            ),
          );
        },
      );

      testWidgets(
        'is card-shaped and as wide as the card width given',
        (tester) async {
          await pumpPile(
            tester,
            const Pile(
              label: 'Draw pile',
              count: 1,
              card: CardBack(),
              onTap: null,
              cardWidth: 80,
            ),
          );

          final size = tester.getSize(find.byType(CardFrame));

          expect(size.width, 80);
          expect(size.height, 80 / cardAspectRatio);
        },
      );
    },
  );
}
