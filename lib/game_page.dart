// ============================================================
// ゲーム画面
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wall_tap/scenery_page.dart';
import 'main.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  static const int maxWallHits = 100;

  int wallHits = 0;

  double damage = 0.0;

  bool showHitEffect = false;
  bool isBreaking = false;
  late AnimationController hammerController;

  Offset tapPosition = Offset.zero;

  final Random random = Random();

  final List<Crack> cracks = [];

  @override
  void initState() {
    super.initState();

    hammerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    loadHits();
  }

  @override
  void dispose() {
    hammerController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // 累計回数読み込み
  // ------------------------------------------------------------

  Future<void> loadHits() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      wallHits = prefs.getInt('wall_hits') ?? 0;
    });
  }

  // ------------------------------------------------------------
  // 累計回数保存
  // ------------------------------------------------------------

  Future<void> saveHits() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('wall_hits', wallHits);
  }

  // ------------------------------------------------------------
  // 壁を叩く
  // ------------------------------------------------------------

  Future<void> hitWall(TapDownDetails details) async {
    if (isBreaking || hammerController.isAnimating) {
      return;
    }

    // ------------------------------------------
    // 回数を増やす
    // ------------------------------------------
    setState(() {
      tapPosition = details.localPosition;
      showHitEffect = true;

      wallHits++;

      damage = wallHits / maxWallHits;

      if (wallHits % 1000 == 0) {
        cracks.add(
          Crack(
            x: 0.15 + random.nextDouble() * 0.7,
            y: 0.15 + random.nextDouble() * 0.7,
            length: 40 + random.nextDouble() * 100,
          ),
        );

        if (cracks.length > 500) {
          cracks.removeAt(0);
        }
      }
    });

    // ------------------------------------------
    // 保存
    // ------------------------------------------

    await saveHits();

    // ------------------------------------------
    // パンチエフェクトを消す
    // ------------------------------------------

    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        if (!mounted || isBreaking) return;

        setState(() {
          showHitEffect = false;
        });
      },
    );

    // ------------------------------------------
    // 100万回到達
    // ------------------------------------------

    if (wallHits >= maxWallHits) {
      await breakWall();
    }
  }

  // ------------------------------------------------------------
  // 壁を壊す
  // ------------------------------------------------------------

  Future<void> breakWall() async {
    if (isBreaking) return;

    isBreaking = true;

    setState(() {
      damage = 1.0;
      showHitEffect = false;
    });

    // 崩壊アニメーション
    await hammerController.forward();

    if (!mounted) return;

    // SharedPreferencesを初期化
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wall_hits');

    // 景色ページへ
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SceneryPage(),
      ),
    );
  }

  // ------------------------------------------------------------
  // 進行率
  // ------------------------------------------------------------

  String get progressText {
    return '${wallHits.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (match) => '${match.group(1)},',
        )} / $maxWallHits';
  }

  @override
  Widget build(BuildContext context) {
    final double progress = wallHits / maxWallHits;
    final int remaining = maxWallHits - wallHits;
    Color counterColor;
    if (progress < 0.5) {
      counterColor = Colors.white;
    } else if (progress < 0.8) {
      counterColor = Colors.yellow;
    } else if (progress < 0.95) {
      counterColor = Colors.orange;
    } else {
      counterColor = Colors.red;
    }
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ==========================================
            // 画面全体が壁
            // ==========================================

            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: hitWall,
                child: AnimatedBuilder(
                  animation: hammerController,
                  builder: (context, child) {
                    final value = hammerController.value;

                    return Transform.scale(
                      scale: 1.0 - value * 0.18,
                      child: Transform.translate(
                        offset: Offset(
                          sin(value * 30) * 8,
                          value * 40,
                        ),
                        child: Opacity(
                          opacity: 1.0 - value,
                          child: CustomPaint(
                            painter: WallPainter(
                              damage: damage,
                              cracks: cracks,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ==========================================
            // 上部の情報
            // ==========================================
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: counterColor.withOpacity(0.8),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: counterColor.withOpacity(
                          progress > 0.8 ? 0.45 : 0.2,
                        ),
                        blurRadius: progress > 0.8 ? 18 : 8,
                        spreadRadius: progress > 0.8 ? 3 : 0,
                      ),
                    ],
                  ),
                  child: Text(
                    '${wallHits.toString()} / ${maxWallHits.toString()} 回',
                    style: TextStyle(
                      color: counterColor,
                      fontSize: progress > 0.95 ? 26 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // ==========================================
            // タップエフェクト
            // ==========================================
            if (showHitEffect)
              Positioned(
                left: tapPosition.dx - 45,
                top: tapPosition.dy - 90,
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: hammerController,
                    builder: (context, child) {
                      final value = hammerController.value;

                      // 最初は上、最後に振り下ろす
                      final angle = -0.8 + (value * 1.6);

                      return Transform.rotate(
                        angle: angle,
                        alignment: Alignment.bottomRight,
                        child: const Icon(
                          Icons.hardware,
                          size: 90,
                          color: Colors.yellow,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 8,
                              offset: Offset(4, 5),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

            // ==========================================
            // 下部の説明
            // ==========================================

            const Positioned(
              bottom: 25,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: Text(
                    '画面をタップして壁を叩こう！',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 5,
                        ),
                      ],
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
// @override
// Widget build(BuildContext context) {
//   // final progress = wallHits / maxWallHits;
//
//   return Scaffold(
//     backgroundColor: const Color(0xFFEAEAEA),
//     appBar: AppBar(
//       title: const Text('壁を叩け！'),
//       centerTitle: true,
//     ),
//     body: SafeArea(
//       child: Column(
//         children: [
//           // --------------------------------------------------
//           // 回数
//           // --------------------------------------------------
//
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment:
//                   MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'この壁',
//                           style: TextStyle(
//                             color: Colors.grey,
//                           ),
//                         ),
//                         Text(
//                           progressText,
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     // Column(
//                     //   crossAxisAlignment:
//                     //   CrossAxisAlignment.end,
//                     //   children: [
//                     //     const Text(
//                     //       '累計',
//                     //       style: TextStyle(
//                     //         color: Colors.grey,
//                     //       ),
//                     //     ),
//                     //     Text(
//                     //       '$totalHits 回',
//                     //       style: const TextStyle(
//                     //         fontSize: 24,
//                     //         fontWeight: FontWeight.bold,
//                     //       ),
//                     //     ),
//                     //   ],
//                     // ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 // // 進行バー
//                 // ClipRRect(
//                 //   borderRadius:
//                 //   BorderRadius.circular(10),
//                 //   child: LinearProgressIndicator(
//                 //     value: progress,
//                 //     minHeight: 14,
//                 //     backgroundColor:
//                 //     Colors.grey.shade300,
//                 //     color: progress > 0.8
//                 //         ? Colors.red
//                 //         : Colors.orange,
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//
//           // --------------------------------------------------
//           // 壁
//           // --------------------------------------------------
//
//           Expanded(
//             child: Center(
//               child: GestureDetector(
//                 behavior: HitTestBehavior.opaque,
//                 onTap: hitWall,
//                 child: AnimatedBuilder(
//                   animation: crumbleController,
//                   builder: (context, child) {
//                     final value =
//                         crumbleController.value;
//
//                     return Transform.scale(
//                       scale: 1.0 - value * 0.18,
//                       child: Transform.translate(
//                         offset: Offset(
//                           sin(value * 30) * 8,
//                           value * 40,
//                         ),
//                         child: Opacity(
//                           opacity: 1.0 - value,
//                           child: Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               CustomPaint(
//                                 size: const Size(
//                                   300,
//                                   430,
//                                 ),
//                                 painter: WallPainter(
//                                   damage: damage,
//                                   cracks: cracks,
//                                 ),
//                               ),
//
//                               if (showHitEffect)
//                                 const Icon(
//                                   Icons.flash_on,
//                                   color: Colors.yellow,
//                                   size: 90,
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//
//           // const Padding(
//           //   padding: EdgeInsets.only(
//           //     bottom: 30,
//           //   ),
//           //   child: Text(
//           //     '壁をタップして叩こう！',
//           //     style: TextStyle(
//           //       fontSize: 20,
//           //       fontWeight: FontWeight.bold,
//           //     ),
//           //   ),
//           // ),
//         ],
//       ),
//     ),
//   );
// }
}
