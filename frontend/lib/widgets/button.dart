import 'package:flutter/material.dart';

/// A reusable button that helps with default sizing for mobile
class ButtonWidget extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double fontSize;
  final double minSize;

  const ButtonWidget({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.fontSize = 18,
    this.minSize = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text, style: TextStyle(fontSize: fontSize)),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(minSize, 50),
        elevation: 5,
      ),
    );
  }
}
