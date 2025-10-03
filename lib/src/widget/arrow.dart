import 'package:flutter/material.dart';

/// Decoration-like class for the arrow.
class ArrowDecoration {
  /// Solid fill color (ignored if [gradient] is provided).
  final Color? color;

  /// Optional gradient fill.
  final Gradient? gradient;

  /// Painting style for the main paint (fill or stroke).
  final PaintingStyle paintingStyle;

  /// Optional border (stroke).
  final BorderSide? border;

  /// Soft shadows similar to BoxDecoration.boxShadow.
  final List<BoxShadow>? boxShadow;

  /// If true and [boxShadow] is null, use canvas.drawShadow with [shadowColor] and [shadowElevation].
  /// drawShadow gives a crisp, elevated shadow for shapes.
  final bool useDrawShadow;
  final Color shadowColor;
  final double shadowElevation;

  const ArrowDecoration({
    this.color,
    this.gradient,
    this.paintingStyle = PaintingStyle.fill,
    this.border,
    this.boxShadow,
    this.useDrawShadow = false,
    this.shadowColor = Colors.black54,
    this.shadowElevation = 4.0,
  });

  ArrowDecoration copyWith({
    Color? color,
    Gradient? gradient,
    PaintingStyle? paintingStyle,
    BorderSide? border,
    List<BoxShadow>? boxShadow,
    bool? useDrawShadow,
    Color? shadowColor,
    double? shadowElevation,
  }) {
    return ArrowDecoration(
      color: color ?? this.color,
      gradient: gradient ?? this.gradient,
      paintingStyle: paintingStyle ?? this.paintingStyle,
      border: border ?? this.border,
      boxShadow: boxShadow ?? this.boxShadow,
      useDrawShadow: useDrawShadow ?? this.useDrawShadow,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowElevation: shadowElevation ?? this.shadowElevation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ArrowDecoration &&
        other.color == color &&
        other.gradient == gradient &&
        other.paintingStyle == paintingStyle &&
        other.border == border &&
        _listEquals(other.boxShadow, boxShadow) &&
        other.useDrawShadow == useDrawShadow &&
        other.shadowColor == shadowColor &&
        other.shadowElevation == shadowElevation;
  }

  @override
  int get hashCode => Object.hash(
        color,
        gradient,
        paintingStyle,
        border,
        boxShadow?.length,
        useDrawShadow,
        shadowColor,
        shadowElevation,
      );

  // small helper for List<BoxShadow> equality by value
  static bool _listEquals(List<BoxShadow>? a, List<BoxShadow>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final A = a[i], B = b[i];
      if (A.color != B.color ||
          A.offset != B.offset ||
          A.blurRadius != B.blurRadius ||
          A.spreadRadius != B.spreadRadius) {
        return false;
      }
    }
    return true;
  }
}

/// Painter that draws a triangular arrow using an [ArrowDecoration].
class ArrowPainter extends CustomPainter {
  final ArrowDecoration decoration;
  final bool isUpArrow;

  ArrowPainter({
    required this.decoration,
    this.isUpArrow = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _getTrianglePath(size.width, size.height, isUpArrow);

    // 1) Soft/offset shadows (BoxShadow) - draw underneath the shape.
    if (decoration.boxShadow != null && decoration.boxShadow!.isNotEmpty) {
      for (final bs in decoration.boxShadow!) {
        final shadowPaint = Paint()
          ..color = bs.color
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;

        // MaskFilter.blur expects sigma; using blurRadius directly is fine for typical uses.
        if (bs.blurRadius > 0) {
          shadowPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, bs.blurRadius);
        }

        canvas.save();
        canvas.translate(bs.offset.dx, bs.offset.dy);
        canvas.drawPath(path, shadowPaint);
        canvas.restore();
      }
    } else if (decoration.useDrawShadow) {
      // 1b) drawShadow - crisp elevation shadow (useful for non-blobby shape)
      // last param (transparentOccluder) set to false (occluder considered opaque)
      canvas.drawShadow(path, decoration.shadowColor, decoration.shadowElevation, false);
    }

    // 2) Fill (or stroke-only if paintingStyle is stroke)
    if (decoration.paintingStyle == PaintingStyle.fill) {
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      if (decoration.gradient != null) {
        final rect = Rect.fromLTWH(0, 0, size.width, size.height);
        fillPaint.shader = decoration.gradient!.createShader(rect);
      } else {
        fillPaint.color = decoration.color ?? Colors.transparent;
      }

      canvas.drawPath(path, fillPaint);
    }

    // 3) Border / stroke (if provided)
    final border = decoration.border;
    if (border != null && border.width > 0) {
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = border.width
        ..color = border.color
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;
      canvas.drawPath(path, strokePaint);
    }
  }

  Path _getTrianglePath(double w, double h, bool up) {
    if (up) {
      return Path()
        ..moveTo(0, h)
        ..lineTo(w / 2, 0)
        ..lineTo(w, h)
        ..close();
    } else {
      return Path()
        ..moveTo(0, 0)
        ..lineTo(w, 0)
        ..lineTo(w / 2, h)
        ..close();
    }
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) {
    // We rely on ArrowDecoration's == to detect changes.
    return oldDelegate.decoration != decoration || oldDelegate.isUpArrow != isUpArrow;
  }
}
