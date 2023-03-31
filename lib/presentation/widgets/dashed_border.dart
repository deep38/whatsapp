import 'package:flutter/material.dart';

class DashedBorder extends StatelessWidget {
  final Widget child;
  final double strokeWidth;
  final Color color;
  final int numDashes;
  final double gapSize;

  const DashedBorder({
    super.key,
    required this.child,
    this.strokeWidth = 1.0,
    this.color = Colors.white,
    this.numDashes = 10,
    this.gapSize = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(
        strokeWidth: strokeWidth,
        color: color,
        numDashes: numDashes,
        gapSize: gapSize,
      ),
      child: Container(
        child: child,
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final int numDashes;
  final double gapSize;

  DashedBorderPainter({
    required this.strokeWidth,
    required this.color,
    required this.numDashes,
    required this.gapSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final dashLength = size.width / (numDashes * 2);

    for (int i = 0; i < numDashes; i++) {
      final x = i * 2 * dashLength + dashLength;
      path.moveTo(x, 0);
      path.lineTo(x + dashLength, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color ||
        oldDelegate.numDashes != numDashes ||
        oldDelegate.gapSize != gapSize;
  }
}