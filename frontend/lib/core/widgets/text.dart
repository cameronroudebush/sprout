import 'package:flutter/material.dart';

/// A reusable text display that dynamically sizes to the screen size
class TextWidget extends StatelessWidget implements PreferredSizeWidget {
  /// The reference size for displaying the text size
  final double referenceSize;

  /// The text to display
  final String text;

  /// The style for this text display
  final TextStyle? style;

  final TextAlign textAlign;

  const TextWidget({
    super.key,
    this.referenceSize = 1,
    required this.text,
    this.style,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    var textSize = MediaQuery.of(context).size.height * .0125 * (referenceSize);
    var fontStyle = TextStyle(fontSize: textSize);
    var styleToUse = style;
    if (styleToUse == null) {
      styleToUse = fontStyle;
    } else {
      styleToUse = styleToUse.copyWith(fontSize: textSize);
    }

    return Text(text, style: styleToUse, textAlign: textAlign);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kTextHeightNone);
}
