import 'package:material_ui/material_ui.dart';

/// Shows [child], a card, going to [targetOffset] from the top left corner
/// of the widget with [targetKey], such as a slot on a `Plate` or the top of
/// the discard pile, over [duration], then calls [onEnd] once it's there.
///
/// Unlike a `FlippingCard`, it has timing of its own: it starts from when
/// it's first shown, so show it as the card starts to move. If animations
/// are disabled, it shows the card at its target instead, from the frame
/// after it's first shown, once it has been laid out to find the target,
/// and still calls [onEnd] after [duration], so that the player sees it
/// there.
///
/// It only moves the card, so the target should be the card's size. If the
/// target isn't shown, the card stays where it is.
class MovingCard extends StatelessWidget {
  /// The key of the widget that the card goes to.
  final GlobalKey? targetKey;

  /// Where the card goes to, from the top left corner of the widget with
  /// [targetKey].
  final Offset targetOffset;

  /// How long the card takes to go to its target.
  final Duration duration;

  /// Called once the card is at its target.
  final VoidCallback? onEnd;

  /// The card being moved.
  final Widget child;

  /// Shows [child] going to [targetOffset] from the top left corner of the
  /// widget with [targetKey], over [duration], then calls [onEnd].
  const MovingCard({
    super.key,
    required this.targetKey,
    this.targetOffset = Offset.zero,
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
          offset: _targetOffsetFrom(context) * (disableAnimations ? 1 : value),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Returns where the card's target is, from where the card is shown in
  /// [context], or [Offset.zero] if the target isn't shown or the card
  /// hasn't been laid out yet.
  ///
  /// It's read from where they were last laid out, as the card is moved.
  Offset _targetOffsetFrom(BuildContext context) {
    final targetBox = targetKey?.currentContext?.findRenderObject();
    final box = context.findRenderObject();

    if (targetBox is! RenderBox ||
        !targetBox.hasSize ||
        box is! RenderBox ||
        !box.hasSize) {
      return Offset.zero;
    }

    return box.globalToLocal(targetBox.localToGlobal(targetOffset));
  }
}
