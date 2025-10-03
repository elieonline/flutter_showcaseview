import 'package:flutter/material.dart';

class ArrowDecoration {
  final bool hasShadow;
  final Color shadowColor;
  final double shadowElevation;
  final bool hasBorder;
  final Color borderColor;
  final double borderWidth;
  final double? arrowWidth;
  final double? arrowHeight;

  const ArrowDecoration({
    this.hasShadow = false,
    this.shadowColor = Colors.black54,
    this.shadowElevation = 4.0,
    this.hasBorder = false,
    this.borderColor = Colors.black,
    this.borderWidth = 2.0,
    this.arrowWidth,
    this.arrowHeight,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArrowDecoration &&
          runtimeType == other.runtimeType &&
          hasShadow == other.hasShadow &&
          shadowColor == other.shadowColor &&
          shadowElevation == other.shadowElevation &&
          hasBorder == other.hasBorder &&
          borderColor == other.borderColor &&
          borderWidth == other.borderWidth &&
          arrowWidth == other.arrowWidth &&
          arrowHeight == other.arrowHeight;

  @override
  int get hashCode =>
      hasShadow.hashCode ^
      shadowColor.hashCode ^
      shadowElevation.hashCode ^
      hasBorder.hashCode ^
      borderColor.hashCode ^
      borderWidth.hashCode ^
      arrowWidth.hashCode ^
      arrowHeight.hashCode;
}
