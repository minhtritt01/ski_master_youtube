import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';
import 'package:ski_master/game/input.dart';
import 'package:ski_master/game/player.dart';

class GamePLay extends Component {
  static const id = 'game-play';
  final int currentLevel;
  final VoidCallback onLevelCompleted;
  final VoidCallback onPausedPressed;
  final VoidCallback onGameOver;
  GamePLay(
    this.currentLevel, {
    super.key,
    required this.onPausedPressed,
    required this.onLevelCompleted,
    required this.onGameOver,
  });
  late final input = Input(keyCallbacks: {
    LogicalKeyboardKey.keyP: onPausedPressed,
    LogicalKeyboardKey.keyC: onLevelCompleted,
    LogicalKeyboardKey.keyO: onGameOver
  });
  @override
  Future<void> onLoad() async {
    print('currentLevel: $currentLevel ');
    final map = await TiledComponent.load('Level1.tmx', Vector2.all(16.0));
    final player = Player(position: Vector2(map.size.x * 0.5, 8.0));
    final world = World(children: [map, input, player]);
    await add(world);
    final camera = CameraComponent.withFixedResolution(
        width: 320, height: 180, world: world);
    await add(camera);
    camera.follow(player);
  }
}
