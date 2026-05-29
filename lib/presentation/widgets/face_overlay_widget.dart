import 'package:flutter/material.dart';

class FaceOverlayWidget extends StatelessWidget {
  final bool isValid;

  const FaceOverlayWidget({super.key, required this.isValid});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FaceFramePainter(isValid: isValid),
      child: const SizedBox.expand(),
    );
  }
}

class FaceFramePainter extends CustomPainter {
  final bool isValid;
  FaceFramePainter({required this.isValid});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isValid ? const Color(0xFF4CAF50) : const Color(0xFFFF6B35)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Oval frame untuk wajah
    final oval = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.45),
      width: size.width * 0.65,
      height: size.height * 0.5,
    );
    canvas.drawOval(oval, paint);

    // Darken outside the oval
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(oval)
      ..fillType = PathFillType.evenOdd;

    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    canvas.drawPath(path, bgPaint);
    
    _drawCorners(canvas, oval, paint);
  }

  void _drawCorners(Canvas canvas, Rect oval, Paint paint) {
    const cornerLength = 20.0;
    
    // Top-left
    canvas.drawLine(Offset(oval.left, oval.top + cornerLength), Offset(oval.left, oval.top), paint);
    canvas.drawLine(Offset(oval.left, oval.top), Offset(oval.left + cornerLength, oval.top), paint);

    // Top-right
    canvas.drawLine(Offset(oval.right - cornerLength, oval.top), Offset(oval.right, oval.top), paint);
    canvas.drawLine(Offset(oval.right, oval.top), Offset(oval.right, oval.top + cornerLength), paint);

    // Bottom-left
    canvas.drawLine(Offset(oval.left, oval.bottom - cornerLength), Offset(oval.left, oval.bottom), paint);
    canvas.drawLine(Offset(oval.left, oval.bottom), Offset(oval.left + cornerLength, oval.bottom), paint);

    // Bottom-right
    canvas.drawLine(Offset(oval.right - cornerLength, oval.bottom), Offset(oval.right, oval.bottom), paint);
    canvas.drawLine(Offset(oval.right, oval.bottom), Offset(oval.right, oval.bottom - cornerLength), paint);
  }

  @override
  bool shouldRepaint(FaceFramePainter oldDelegate) =>
      oldDelegate.isValid != isValid;
}
