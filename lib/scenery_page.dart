// ============================================================
// 壁を壊した後の景色
// ============================================================

import 'package:flutter/material.dart';
import 'game_page.dart';
import 'main.dart';

class SceneryPage extends StatefulWidget {

  const SceneryPage({
    super.key,
  });

  @override
  State<SceneryPage> createState() =>
      _SceneryPageState();
}

class _SceneryPageState
    extends State<SceneryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(
            milliseconds: 1800,
          ),
        );

    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 景色
            Positioned.fill(
              child: AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: SceneryPainter(
                      progress:
                      animationController.value,
                    ),
                  );
                },
              ),
            ),

            // メッセージ
            Positioned(
              left: 0,
              right: 0,
              top: 70,
              child: Column(
                children: [
                  const Text(
                    '壁が壊れた！',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // もう一度
            Positioned(
              left: 30,
              right: 30,
              bottom: 30,
              child: SizedBox(
                height: 58,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor:
                    Colors.green.shade700,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const GamePage(),
                      ),
                    );
                  },
                  child: const Text(
                    'もう一度壁を壊す',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
