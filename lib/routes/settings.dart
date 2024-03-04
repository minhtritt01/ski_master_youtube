import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings(
      {super.key,
      this.onMusicValueChanged,
      this.onBackPressed,
      this.onSfxValueChanged,
      required this.musicValueListenable,
      required this.sfxValueListenable});
  final ValueListenable<bool> musicValueListenable;
  final ValueListenable<bool> sfxValueListenable;
  final ValueChanged<bool>? onMusicValueChanged;
  final ValueChanged<bool>? onSfxValueChanged;
  final VoidCallback? onBackPressed;
  static const id = 'settings';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 30.0),
        ),
        const SizedBox(
          height: 15.0,
        ),
        SizedBox(
          width: 200.0,
          child: ValueListenableBuilder<bool>(
            valueListenable: musicValueListenable,
            builder: (context, value, child) {
              return SwitchListTile(
                value: value,
                onChanged: onMusicValueChanged,
                title: child,
              );
            },
            child: const Text('Music'),
          ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        SizedBox(
          width: 200.0,
          child: ValueListenableBuilder<bool>(
            valueListenable: sfxValueListenable,
            builder: (context, value, child) {
              return SwitchListTile(
                value: value,
                onChanged: onSfxValueChanged,
                title: child,
              );
            },
            child: const Text('Sfx'),
          ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        IconButton(onPressed: onBackPressed, icon: const Icon(Icons.arrow_back))
      ],
    )));
  }
}
