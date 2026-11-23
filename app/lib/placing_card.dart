import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';

import 'plate.dart';

/// Shows [child], a card, going to the slot for [category] on the [Plate]
/// with [plateKey], over [duration], then calls [onEnd] once it's there.
///
/// Unlike a `FlippingCard`, it has timing of its own: it starts from when
/// it's first shown, so show it as the card is placed. If animations are
/// disabled, it shows the card in its slot instead, from the frame after
/// it's first shown, once it has been laid out to find the slot, and still
/// calls [onEnd] after [duration], so that the player sees it there.
///
/// It only moves the card, so the plate's slots should be as wide as the
/// card. If the plate isn't shown, the card stays where it is.
class PlacingCard extends StatelessWidget {
  /// The key of the [Plate] that the card is placed on.
  final GlobalKey? plateKey;

  /// The category of the slot that the card goes to.
  final engine.Category category;

  /// How long the card takes to go to its slot.
  final Duration duration;

  /// Called once the card is in its slot.
  final VoidCallback? onEnd;

  /// The card being placed.
  final Widget child;

  /// Shows [child] going to the slot for [category] on the [Plate] with
  /// [plateKey], over [duration], then calls [onEnd].
  const PlacingCard({
    super.key,
    required this.plateKey,
    required this.category,
    required this.duration,
    this.onEnd,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeInOut,
      onEnd: onEnd,
      builder: (context, value, child) {
        return Transform.translate(
          offset: _slotOffsetFrom(context) * (disableAnimations ? 1 : value),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Returns where the top left corner of the slot is, from where the card
  /// is shown in [context], or [Offset.zero] if the plate isn't shown or
  /// the card hasn't been laid out yet.
  ///
  /// It's read from where they were last laid out, as the card is moved.
  Offset _slotOffsetFrom(BuildContext context) {
    final plateContext = plateKey?.currentContext;
    final plate = plateContext?.widget;
    final plateBox = plateContext?.findRenderObject();
    final box = context.findRenderObject();

    if (plate is! Plate ||
        plateBox is! RenderBox ||
        !plateBox.hasSize ||
        box is! RenderBox ||
        !box.hasSize) {
      return Offset.zero;
    }

    return box.globalToLocal(
      plateBox.localToGlobal(plate.slotOffsetOf(category)),
    );
  }
}
