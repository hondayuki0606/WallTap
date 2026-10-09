// 衝撃波のCustomPainter例（簡易版）
import 'dart:math';

import 'package:flutter/material.dart';
class SparkShockwavePainter extends CustomPainter {
  final double progress; // 0.0 -> 1.0

  SparkShockwavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // 1. メインの太い波紋（外側へ広がる）
    final mainPaint = Paint()
      ..color = Colors.amberAccent.withOpacity((1.0 - progress).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0 * (1.0 - progress);

    canvas.drawCircle(center, maxRadius * progress, mainPaint);

    // 2. 遅れて追従する内側の光る波紋
    final innerProgress = (progress * 1.2).clamp(0.0, 1.0);
    final innerPaint = Paint()
      ..color = Colors.white.withOpacity((1.0 - innerProgress).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, maxRadius * innerProgress * 0.7, innerPaint);

    // 3. 放射状に飛び散るインパクトライン（8本）
    final linePaint = Paint()
      ..color = Colors.orangeAccent.withOpacity((1.0 - progress).clamp(0.0, 1.0))
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const int lineCount = 8;
    for (int i = 0; i < lineCount; i++) {
      final angle = (i * (2 * pi / lineCount));
      final startDist = maxRadius * progress * 0.3;
      final endDist = maxRadius * progress * 0.9;

      final start = center + Offset(cos(angle) * startDist, sin(angle) * startDist);
      final end = center + Offset(cos(angle) * endDist, sin(angle) * endDist);

      canvas.drawLine(start, end, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant SparkShockwavePainter oldDelegate) => true;
}