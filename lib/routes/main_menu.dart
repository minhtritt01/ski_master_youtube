import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key, this.onPlayPressed, this.onSettingPressed});
  final VoidCallback? onPlayPressed;
  final VoidCallback? onSettingPressed;
  static const id = 'MainMenu';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Ski Master',
          style: TextStyle(fontSize: 30.0),
        ),
        const SizedBox(
          height: 15.0,
        ),
        SizedBox(
          width: 150.0,
          child: OutlinedButton(
              onPressed: onPlayPressed, child: const Text('Play')),
        ),
        const SizedBox(
          height: 5.0,
        ),
        SizedBox(
          width: 150.0,
          child: OutlinedButton(
              onPressed: onSettingPressed, child: const Text('Settings')),
        )
      ],
    )));
  }
}
