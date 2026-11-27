import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart' as engine;
import 'package:spoiled_supper_lotto_game/game_notifier.dart';
import 'package:spoiled_supper_lotto_game/played_card.dart';

void main() {
  group(
    'PlayedCard',
    () {
      const fishBone = engine.Card(
        id: '1',
        type: engine.CardType.spoiled,
        category: engine.Category.main,
        name: 'Fish Bone',
      );

      final alice = engine.Player(name: 'Alice');

      test(
        'describes a card placed',
        () {
          final playedCard = PlayedCard(
            player: alice,
            card: fishBone,
            play: DrawnCardPlay.place,
          );

          expect(playedCard.description, 'Alice placed Fish Bone');
        },
      );

      test(
        'describes a card placed over another, naming the card replaced',
        () {
          final playedCard = PlayedCard(
            player: alice,
            card: const engine.Card(
              id: '2',
              type: engine.CardType.standard,
              category: engine.Category.main,
              name: 'Sausages',
            ),
            play: DrawnCardPlay.place,
            replacedCard: fishBone,
          );

          expect(
            playedCard.description,
            'Alice placed Sausages, replacing Fish Bone',
          );
        },
      );

      test(
        'describes a card discarded',
        () {
          final playedCard = PlayedCard(
            player: alice,
            card: fishBone,
            play: DrawnCardPlay.discard,
          );

          expect(playedCard.description, 'Alice discarded Fish Bone');
        },
      );
    },
  );
}
