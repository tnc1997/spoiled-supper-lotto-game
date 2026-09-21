import 'dart:math';

/// Shuffles [items] in place using the
/// [Fisher–Yates algorithm](https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle).
///
/// Pass a seeded [random] for deterministic, reproducible shuffles (e.g. in
/// tests); otherwise a new [Random] is used.
void shuffle<T>(List<T> items, [Random? random]) {
  final rng = random ?? Random();

  for (var i = items.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);

    if (i != j) {
      final temp = items[i];
      items[i] = items[j];
      items[j] = temp;
    }
  }
}
