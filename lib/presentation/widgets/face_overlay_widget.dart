import 'package:flutter/material.dart';
import '../../core/themes/color_palette.dart';

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
    // Geser titik tengah oval agak ke atas agar tidak menabrak UI di bawahnya
    final center = Offset(size.width / 2, size.height * 0.38);
    
    // Bentuk oval portrait (lebih cocok untuk wajah manusia daripada lingkaran penuh)
    final ovalWidth = size.width * 0.65;
    final ovalHeight = size.height * 0.45;
    final rect = Rect.fromCenter(center: center, width: ovalWidth, height: ovalHeight);
    
    // Darken outside the oval
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(rect)
      ..fillType = PathFillType.evenOdd;

    // Background lebih terang sedikit agar tidak terlalu gloomy
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    canvas.drawPath(path, bgPaint);
    
    // Warna neon modern (Ubah ke warna Orange HSIL)
    final color = isValid ? AppColors.safetyOrange : Colors.white;
    
    // Efek Glow bayangan
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(rect, glowPaint);

    // Garis frame utama
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(FaceFramePainter oldDelegate) =>
      oldDelegate.isValid != isValid;
}
