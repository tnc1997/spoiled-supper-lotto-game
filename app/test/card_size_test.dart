import 'package:flutter_test/flutter_test.dart';
import 'package:spoiled_supper_lotto_game/card_aspect_ratio.dart';
import 'package:spoiled_supper_lotto_game/card_size.dart';

void main() {
  group(
    'cardSize',
    () {
      test(
        'has the shape of every card',
        () {
          expect(cardSize.aspectRatio, cardAspectRatio);
        },
      );
    },
  );
}
