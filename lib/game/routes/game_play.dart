import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
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
  late World _world;
  late CameraComponent _camera;
  late Player _player;
  late final _resetTimer = Timer(3, onTick: _resetPlayer, autoStart: false);
  late final Vector2 _lastSafePosition;
  int _nTrailTriggers = 0;
  bool get _isOffTrail => _nTrailTriggers == 0;
  @override
  void update(double dt) {
    if (_isOffTrail) {
      _resetTimer.update(dt);
      if (!_resetTimer.isRunning()) {
        _resetTimer.start();
      }
    } else {
      if (_resetTimer.isRunning()) {
        _resetTimer.stop();
      }
    }
    super.update(dt);
  }

  @override
  Future<void> onLoad() async {
    print('currentLevel: $currentLevel ');
    final map = await TiledComponent.load('Level1.tmx', Vector2.all(16.0));
    await _setupWorldAndCamera(map);
    await _handleSpawnPoints(map);
    await _handleTriggers(map);
  }

  Future<void> _handleSpawnPoints(TiledComponent<FlameGame<World>> map) async {
    final spawnPointLayer = map.tileMap.getLayer<ObjectGroup>('SpawnPoint');
    final objects = spawnPointLayer?.objects;
    final tiles = game.images.fromCache('../images/tilemap_packed.png');
    final spriteSheet = SpriteSheet(image: tiles, srcSize: Vector2.all(16.0));
    if (objects != null) {
      for (var object in objects) {
        switch (object.class_) {
          case 'Player':
            _player = Player(
                position: Vector2(object.x, object.y),
                sprite: spriteSheet.getSprite(5, 10));
            await _world.add(_player);
            _camera.follow(_player);
            _lastSafePosition = Vector2(object.x, object.y);
            break;
          case 'Snowman':
            final snowman = Snowman(
                position: Vector2(object.x, object.y),
                sprite: spriteSheet.getSprite(5, 9));
            await _world.add(snowman);
            break;
        }
      }
    }
  }

  Future<void> _handleTriggers(TiledComponent<FlameGame<World>> map) async {
    final triggerLayer = map.tileMap.getLayer<ObjectGroup>('Trigger');
    final objects = triggerLayer?.objects;

    if (objects != null) {
      for (var object in objects) {
        switch (object.class_) {
          case 'Trail':
            final vertices = <Vector2>[];
            for (final point in object.polygon) {
              vertices.add(Vector2(point.x + object.x, point.y + object.y));
            }
            final hitbox = PolygonHitbox(vertices,
                collisionType: CollisionType.passive, isSolid: true)
              ..debugMode = true;
            hitbox.onCollisionStartCallback = (_, __) => _onTrailEnter();
            hitbox.onCollisionEndCallback = (_) => _onTrailExit();
            await map.add(hitbox);
            break;
        }
      }
    }
  }

  Future<void> _setupWorldAndCamera(
      TiledComponent<FlameGame<World>> map) async {
    _world = World(children: [map, input]);
    await add(_world);
    _camera = CameraComponent.withFixedResolution(
        width: 320, height: 180, world: _world);
    await add(_camera);
  }

  void _onTrailEnter() {
    ++_nTrailTriggers;
  }

  void _onTrailExit() {
    --_nTrailTriggers;
  }

  void _resetPlayer() {
    _player.resetTo(_lastSafePosition);
  }
}
