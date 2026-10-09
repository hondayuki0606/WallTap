// ============================================================
// Start screen
// ============================================================

import 'package:flutter/material.dart';
import 'game_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.construction,
                  size: 100,
                  color: Colors.orange,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Smash The Wall!',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hit it 1,000,000 times to break the wall!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GamePage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Start Game',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // const SizedBox(height: 50),
                // SizedBox(
                //   width: double.infinity,
                //   height: 60,
                //   child: FilledButton(
                //     onPressed: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (_) => const GamePage(),
                //         ),
                //       );
                //     },
                //     child: const Text(
                //       'Watch Ad',
                //       style: TextStyle(
                //         fontSize: 22,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}