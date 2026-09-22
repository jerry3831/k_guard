import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CameraOverlay extends StatelessWidget {
  final double frameSize;

  const CameraOverlay({
    super.key,
    this.frameSize = 240,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: frameSize,
      height: frameSize,
      child: CustomPaint(
        painter: _ViewfinderPainter(),
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.viewfinderBracket
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    const bracketLength = 28.0;
    const cornerRadius = 4.0;

    _drawCorner(canvas, paint, Offset.zero, bracketLength, cornerRadius,
        flipX: false, flipY: false);

    _drawCorner(canvas, paint, Offset(size.width, 0), bracketLength,
        cornerRadius, flipX: true, flipY: false);

    _drawCorner(canvas, paint, Offset(0, size.height), bracketLength,
        cornerRadius, flipX: false, flipY: true);

    _drawCorner(canvas, paint, Offset(size.width, size.height), bracketLength,
        cornerRadius, flipX: true, flipY: true);
  }

  void _drawCorner(
    Canvas canvas,
    Paint paint,
    Offset corner,
    double length,
    double radius, {
    required bool flipX,
    required bool flipY,
  }) {
    final xDir = flipX ? -1.0 : 1.0;
    final yDir = flipY ? -1.0 : 1.0;

    final path = Path();
    path.moveTo(corner.dx + xDir * length, corner.dy);
    path.lineTo(corner.dx + xDir * radius, corner.dy);
    path.arcToPoint(
      Offset(corner.dx, corner.dy + yDir * radius),
      radius: Radius.circular(radius),
      clockwise: flipX == flipY,
    );
    path.lineTo(corner.dx, corner.dy + yDir * length);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
