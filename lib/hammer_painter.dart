
import 'package:flutter/material.dart';

class HammerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 1. 柄（木の柄）
    final handlePath = Path()
      ..moveTo(width * 0.45, height * 0.35)
      ..lineTo(width * 0.55, height * 0.35)
      ..lineTo(width * 0.85, height * 0.95)
      ..lineTo(width * 0.75, height * 0.98)
      ..close();

    final handlePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8B4513), Color(0xFFA0522D), Color(0xFF5C2C0C)],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawPath(handlePath, handlePaint);

    // 2. 金属ヘッド（本体）
    final headRect = RRect.fromLTRBR(
      width * 0.1,
      height * 0.15,
      width * 0.7,
      height * 0.45,
      const Radius.circular(6),
    );

    final headPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF808080),
          Color(0xFFE0E0E0), // ハイライト
          Color(0xFF404040),
          Color(0xFF202020),
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawRRect(headRect, headPaint);

    // 3. 打撃面（補強リング・左右のふち）
    final capPaint = Paint()..color = const Color(0xFF333333);
    canvas.drawRect(
      Rect.fromLTWH(width * 0.08, height * 0.13, width * 0.06, height * 0.34),
      capPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(width * 0.66, height * 0.13, width * 0.06, height * 0.34),
      capPaint,
    );

    // 4. 金属の光沢ライン
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(width * 0.15, height * 0.22),
      Offset(width * 0.65, height * 0.22),
      shinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}