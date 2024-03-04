import 'package:flutter/material.dart';

class PauseMenu extends StatelessWidget {
  const PauseMenu(
      {super.key,
      this.onResumePressed,
      this.onRestartPressed,
      this.onExitPressed});
  final VoidCallback? onResumePressed;
  final VoidCallback? onRestartPressed;
  final VoidCallback? onExitPressed;
  static const id = 'pause-menu';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(210, 229, 238, 238),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Paused',
              style: TextStyle(fontSize: 30.0),
            ),
            const SizedBox(
              height: 15.0,
            ),
            SizedBox(
              width: 150.0,
              child: OutlinedButton(
                  onPressed: onResumePressed, child: const Text('Resume')),
            ),
            const SizedBox(
              height: 5.0,
            ),
            SizedBox(
              width: 150.0,
              child: OutlinedButton(
                  onPressed: onRestartPressed, child: const Text('Restart')),
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
