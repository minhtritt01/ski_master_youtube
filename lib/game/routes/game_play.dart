import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';
import 'package:ski_master/game/actors/snowman.dart';
import 'package:ski_master/game/game.dart';
import 'package:ski_master/game/input.dart';
import 'package:ski_master/game/actors/player.dart';

class GamePLay extends Component with HasGameReference<SkiMasterGame> {
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
    final world = World(children: [map, input]);
    await add(world);
    final camera = CameraComponent.withFixedResolution(
        width: 320, height: 180, world: world);
    await add(camera);
    final spawnPointLayer = map.tileMap.getLayer<ObjectGroup>('SpawnPoint');
    final objects = spawnPointLayer?.objects;
    final tiles = game.images.fromCache('../images/tilemap_packed.png');
    final spriteSheet = SpriteSheet(image: tiles, srcSize: Vector2.all(16.0));
    if (objects != null) {
      for (var object in objects) {
        switch (object.class_) {
          case 'Player':
            final player = Player(
                position: Vector2(object.x, object.y),
                sprite: spriteSheet.getSprite(5, 10));
            await world.add(player);
            camera.follow(player);
            break;
          case 'Snowman':
            final snowman = Snowman(
                position: Vector2(object.x, object.y),
                sprite: spriteSheet.getSprite(5, 9));
            await world.add(snowman);
            break;
        }
      }
    }
  }
}
