import 'package:flutter/material.dart';
import 'package:wall_tap/start_page.dart';

void main() {
  runApp(const WallKnockApp());
}

class WallKnockApp extends StatelessWidget {
  const WallKnockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '壁を叩くゲーム',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
        ),
        useMaterial3: true,
      ),
      home: const StartPage(),
    );
  }
}

// ============================================================
// ヒビ情報
// ============================================================

class Crack {
  final double x;
  final double y;
  final double length;

  Crack({
    required this.x,
    required this.y,
    required this.length,
  });
}

// ============================================================
// 壁 Painter
// ============================================================

class WallPainter extends CustomPainter {
  final double damage;
  final List<Crack> cracks;

  WallPainter({
    required this.damage,
    required this.cracks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wallRect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    );

    // ------------------------------------------
    // 壁の色
    // ------------------------------------------

    final wallPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFFBDBDBD),
        const Color(0xFF555555),
        damage,
      )!
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        wallRect,
        const Radius.circular(8),
      ),
      wallPaint,
    );

    // ------------------------------------------
    // レンガ
    // ------------------------------------------

    final brickPaint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..strokeWidth = 2;

    const brickHeight = 45.0;
    const brickWidth = 75.0;

    for (
    double y = brickHeight;
    y < size.height;
    y += brickHeight
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        brickPaint,
      );
    }

    for (
    double y = 0;
    y < size.height;
    y += brickHeight
    ) {
      final offset =
      ((y / brickHeight).round() % 2 == 0)
          ? 0.0
          : brickWidth / 2;

      for (
      double x = offset;
      x < size.width;
      x += brickWidth
      ) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, y + brickHeight),
          brickPaint,
        );
      }
    }

    // ------------------------------------------
    // ヒビ
    // ------------------------------------------

    final crackPaint = Paint()
      ..color = Colors.black.withOpacity(
        0.5 + damage * 0.4,
      )
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (final crack in cracks) {
      final start = Offset(
        crack.x * size.width,
        crack.y * size.height,
      );

      final path = Path();

      path.moveTo(
        start.dx,
        start.dy,
      );

      path.lineTo(
        start.dx + crack.length * 0.35,
        start.dy - crack.length * 0.2,
      );

      path.lineTo(
        start.dx + crack.length * 0.65,
        start.dy + crack.length * 0.15,
      );

      path.lineTo(
        start.dx + crack.length,
        start.dy - crack.length * 0.1,
      );

      canvas.drawPath(
        path,
        crackPaint,
      );

      // 枝分かれ
      canvas.drawLine(
        Offset(
          start.dx + crack.length * 0.35,
          start.dy - crack.length * 0.2,
        ),
        Offset(
          start.dx + crack.length * 0.25,
          start.dy - crack.length * 0.55,
        ),
        crackPaint,
      );

      canvas.drawLine(
        Offset(
          start.dx + crack.length * 0.65,
          start.dy + crack.length * 0.15,
        ),
        Offset(
          start.dx + crack.length * 0.85,
          start.dy + crack.length * 0.4,
        ),
        crackPaint,
      );
    }

    // ------------------------------------------
    // ダメージが大きいほど破片を表示
    // ------------------------------------------

    if (damage > 0.3) {
      final debrisPaint = Paint()
        ..color = Colors.black.withOpacity(
          damage * 0.3,
        );

      final debrisCount =
      (damage * 30).round();

      for (int i = 0; i < debrisCount; i++) {
        final x =
            (i * 47.0) % size.width;
        final y =
            (i * 83.0) % size.height;

        final debrisSize =
            5 + damage * 12;

        canvas.drawRect(
          Rect.fromLTWH(
            x,
            y,
            debrisSize,
            debrisSize,
          ),
          debrisPaint,
        );
      }
    }

    // ------------------------------------------
    // 90万回を超えたら大きなヒビ
    // ------------------------------------------

    if (damage > 0.9) {
      final bigCrackPaint = Paint()
        ..color = Colors.black.withOpacity(0.8)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke;

      final path = Path();

      path.moveTo(
        size.width * 0.5,
        0,
      );

      path.lineTo(
        size.width * 0.45,
        size.height * 0.2,
      );

      path.lineTo(
        size.width * 0.6,
        size.height * 0.4,
      );

      path.lineTo(
        size.width * 0.42,
        size.height * 0.65,
      );

      path.lineTo(
        size.width * 0.5,
        size.height,
      );

      canvas.drawPath(
        path,
        bigCrackPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant WallPainter oldDelegate,
      ) {
    return oldDelegate.damage != damage ||
        oldDelegate.cracks.length !=
            cracks.length;
  }
}

// ============================================================
// 景色 Painter
// ============================================================

class SceneryPainter extends CustomPainter {
  final double progress;

  SceneryPainter({
    required this.progress,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    // ------------------------------------------
    // 空
    // ------------------------------------------

    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFF4FC3F7),
          Color(0xFFB3E5FC),
          Color(0xFFFFE0B2),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
      skyPaint,
    );

    // ------------------------------------------
    // 太陽
    // ------------------------------------------

    final sunPaint = Paint()
      ..color = Colors.yellow.shade300;

    canvas.drawCircle(
      Offset(
        size.width * 0.78,
        size.height * 0.2,
      ),
      55,
      sunPaint,
    );

    // ------------------------------------------
    // 遠くの山
    // ------------------------------------------

    final mountainPaint = Paint()
      ..color = const Color(0xFF78909C);

    final mountainPath = Path();

    mountainPath.moveTo(
      0,
      size.height * 0.62,
    );

    mountainPath.lineTo(
      size.width * 0.22,
      size.height * 0.38,
    );

    mountainPath.lineTo(
      size.width * 0.38,
      size.height * 0.58,
    );

    mountainPath.lineTo(
      size.width * 0.58,
      size.height * 0.32,
    );

    mountainPath.lineTo(
      size.width * 0.82,
      size.height * 0.58,
    );

    mountainPath.lineTo(
      size.width,
      size.height * 0.42,
    );

    mountainPath.lineTo(
      size.width,
      size.height,
    );

    mountainPath.lineTo(
      0,
      size.height,
    );

    mountainPath.close();

    canvas.drawPath(
      mountainPath,
      mountainPaint,
    );

    // ------------------------------------------
    // 山の雪
    // ------------------------------------------

    final snowPaint = Paint()
      ..color = Colors.white.withOpacity(0.8);

    final snowPath = Path();

    snowPath.moveTo(
      size.width * 0.22,
      size.height * 0.38,
    );

    snowPath.lineTo(
      size.width * 0.16,
      size.height * 0.46,
    );

    snowPath.lineTo(
      size.width * 0.22,
      size.height * 0.43,
    );

    snowPath.lineTo(
      size.width * 0.27,
      size.height * 0.48,
    );

    snowPath.close();

    canvas.drawPath(
      snowPath,
      snowPaint,
    );

    final snowPath2 = Path();

    snowPath2.moveTo(
      size.width * 0.58,
      size.height * 0.32,
    );

    snowPath2.lineTo(
      size.width * 0.51,
      size.height * 0.42,
    );

    snowPath2.lineTo(
      size.width * 0.58,
      size.height * 0.39,
    );

    snowPath2.lineTo(
      size.width * 0.66,
      size.height * 0.45,
    );

    snowPath2.close();

    canvas.drawPath(
      snowPath2,
      snowPaint,
    );

    // ------------------------------------------
    // 草原
    // ------------------------------------------

    final grassPaint = Paint()
      ..color = const Color(0xFF66BB6A);

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height * 0.62,
        size.width,
        size.height * 0.38,
      ),
      grassPaint,
    );

    // ------------------------------------------
    // 道
    // ------------------------------------------

    final pathPaint = Paint()
      ..color = const Color(0xFFD7CCC8)
      ..style = PaintingStyle.fill;

    final roadPath = Path();

    roadPath.moveTo(
      size.width * 0.45,
      size.height,
    );

    roadPath.lineTo(
      size.width * 0.55,
      size.height,
    );

    roadPath.lineTo(
      size.width * 0.52,
      size.height * 0.62,
    );

    roadPath.lineTo(
      size.width * 0.48,
      size.height * 0.62,
    );

    roadPath.close();

    canvas.drawPath(
      roadPath,
      pathPaint,
    );

    // ------------------------------------------
    // 木
    // ------------------------------------------

    drawTree(
      canvas,
      Offset(
        size.width * 0.16,
        size.height * 0.66,
      ),
      1.0,
    );

    drawTree(
      canvas,
      Offset(
        size.width * 0.85,
        size.height * 0.7,
      ),
      1.2,
    );

    drawTree(
      canvas,
      Offset(
        size.width * 0.72,
        size.height * 0.62,
      ),
      0.75,
    );

    // ------------------------------------------
    // 小さな光
    // ------------------------------------------

    final sparklePaint = Paint()
      ..color = Colors.white.withOpacity(
        0.5 + progress * 0.5,
      );

    for (int i = 0; i < 15; i++) {
      final x =
          (i * 97.0) % size.width;
      final y =
          (i * 53.0) % (size.height * 0.6);

      canvas.drawCircle(
        Offset(x, y),
        2.5,
        sparklePaint,
      );
    }
  }

  void drawTree(
      Canvas canvas,
      Offset position,
      double scale,
      ) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF795548);

    final leafPaint = Paint()
      ..color = const Color(0xFF2E7D32);

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(
          position.dx,
          position.dy + 45 * scale,
        ),
        width: 18 * scale,
        height: 70 * scale,
      ),
      trunkPaint,
    );

    canvas.drawCircle(
      Offset(
        position.dx,
        position.dy,
      ),
      45 * scale,
      leafPaint,
    );

    canvas.drawCircle(
      Offset(
        position.dx - 30 * scale,
        position.dy + 20 * scale,
      ),
      30 * scale,
      leafPaint,
    );

    canvas.drawCircle(
      Offset(
        position.dx + 30 * scale,
        position.dy + 20 * scale,
      ),
      30 * scale,
      leafPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant SceneryPainter oldDelegate,
      ) {
    return oldDelegate.progress != progress;
  }
}