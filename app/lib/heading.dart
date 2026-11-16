import 'package:material_ui/material_ui.dart';

/// A centred line of text that titles the content below it, marked as a
/// header for screen readers.
class Heading extends StatelessWidget {
  /// The text of the heading.
  final String text;

  /// The style of the heading, or `null` for the theme's `titleLarge`.
  final TextStyle? style;

  /// Shows [text] as a heading in [style].
  const Heading(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: style ?? Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}
