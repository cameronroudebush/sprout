import 'package:flutter/material.dart';

/// A reusable button that helps with default sizing for mobile
class ButtonWidget extends StatelessWidget {
  final String? text;
  final IconData? icon;

  /// If given displays instead of the icon
  final Widget? image;
  final VoidCallback? onPressed;

  /// Minimum width
  final double minSize;

  /// Height to set
  final double? height;
  final Color? color;

  final ButtonStyle? style;

  final MainAxisAlignment mainAxisAlignment;

  final Widget? child;

  const ButtonWidget({
    super.key,
    this.text,
    this.image,
    this.icon,
    this.onPressed,
    this.minSize = double.infinity,
    this.color,
    this.height,
    this.style,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context).size;
    final dynamicHeightMultiplier = mediaQuery.height > 1200 ? 0.02 : 0.03;
    final maxWidth = mediaQuery.width * .5;
    final ButtonStyle buttonStyle = (style ?? const ButtonStyle()).merge(
      FilledButton.styleFrom(
        minimumSize: Size(minSize, height ?? mediaQuery.height * dynamicHeightMultiplier),
        maximumSize: Size(
          minSize > maxWidth ? minSize : maxWidth,
          height ?? mediaQuery.height * dynamicHeightMultiplier,
        ),
        elevation: 5,
        backgroundColor: color ?? theme.colorScheme.primary,
        textStyle: TextStyle(color: theme.colorScheme.onPrimary),
      ),
    );

    final fontSize = MediaQuery.of(context).size.height * .0125 * (1.1);

    if (icon != null && text != null) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text!, style: TextStyle(fontSize: fontSize)),
        style: buttonStyle,
      );
    } else if (icon != null && text == null) {
      return FilledButton(onPressed: onPressed, style: buttonStyle, child: Icon(icon));
    } else if (icon == null && text != null) {
      return FilledButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Row(
          mainAxisAlignment: mainAxisAlignment,
          children: [
            if (image != null) image!,
            Text(
              text!,
              style: TextStyle(fontSize: fontSize),
              textAlign: TextAlign.center,
            ),
            if (child != null) child!,
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
