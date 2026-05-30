import 'package:flutter/material.dart';

extension BoxDecorationExtensions on BoxDecoration {
  BoxDecoration merge(BoxDecoration? other) {
    if (other == null) return this;
    return copyWith(
      color: other.color ?? color,
      image: other.image ?? image,
      border: other.border ?? border,
      borderRadius: other.borderRadius ?? borderRadius,
      boxShadow: other.boxShadow ?? boxShadow,
      gradient: other.gradient ?? gradient,
      backgroundBlendMode: other.backgroundBlendMode ?? backgroundBlendMode,
    );
  }
}
