import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';

class GamePLay extends Component with KeyboardHandler {
  static const id = 'game-play';
  final int currentLevel;
  final VoidCallback? onLevelCompleted;
  final VoidCallback? onPausedPressed;
  final VoidCallback? onGameOver;
  GamePLay(
    this.currentLevel, {
    super.key,
    this.onPausedPressed,
    this.onLevelCompleted,
    this.onGameOver,
  });
  @override
  Future<void> onLoad() async {
    print('currentLevel: $currentLevel ');
    final map = await TiledComponent.load('sampleMap.tmx', Vector2.all(16.0));
    await add(map);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.keyP)) {
      onPausedPressed?.call();
    } else if (keysPressed.contains(LogicalKeyboardKey.keyC)) {
      onLevelCompleted?.call();
    } else if (keysPressed.contains(LogicalKeyboardKey.keyO)) {
      onGameOver?.call();
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
