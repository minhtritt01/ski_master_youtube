import 'package:flutter/material.dart';

class LevelComplete extends StatelessWidget {
  const LevelComplete(
      {super.key, this.onNextPressed, this.onRetryPressed, this.onExitPressed});
  final VoidCallback? onNextPressed;
  final VoidCallback? onRetryPressed;
  final VoidCallback? onExitPressed;
  static const id = 'level-complete';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(210, 229, 238, 238),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Level Completed',
              style: TextStyle(fontSize: 30.0),
            ),
            const SizedBox(
              height: 15.0,
            ),
            SizedBox(
              width: 150.0,
              child: OutlinedButton(
                  onPressed: onNextPressed, child: const Text('Next')),
            ),
            const SizedBox(
              height: 5.0,
            ),
            SizedBox(
              width: 150.0,
              child: OutlinedButton(
                  onPressed: onRetryPressed, child: const Text('Retry')),
            ),
            const SizedBox(
              height: 5.0,
            ),
            SizedBox(
              width: 150.0,
              child: OutlinedButton(
                  onPressed: onExitPressed, child: const Text('Exit')),
            ),
          ],
        )));
  }
}
