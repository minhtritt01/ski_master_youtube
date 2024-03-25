import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:ski_master/game/actors/snowman.dart';
import 'package:ski_master/game/game.dart';
import 'package:ski_master/game/hud.dart';
import 'package:ski_master/game/input.dart';
import 'package:ski_master/game/actors/player.dart';

class GamePLay extends Component with HasGameReference<SkiMasterGame> {
  static const id = 'game-play';
  final int currentLevel;
  final ValueChanged<int> onLevelCompleted;
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
    LogicalKeyboardKey.keyC: () => onLevelCompleted.call(3),
    LogicalKeyboardKey.keyO: onGameOver
  });
  late World _world;
  late CameraComponent _camera;
  late Player _player;
  late Hud _hud;
  late SpriteSheet _spriteSheet;
  late final _resetTimer = Timer(1.5, onTick: _resetPlayer, autoStart: false);
  late final _cameraShake = MoveEffect.by(Vector2(0, 3),
      InfiniteEffectController(ZigzagEffectController(period: 0.2)));
  late final Vector2 _lastSafePosition;
  late final RectangleComponent _fader;
  late int _star1;
  late int _star2;
  late int _star3;

  int _nTrailTriggers = 0;
  static const _timeScaleRate = 1;
  static const _bgmFadeRate = 1.0;
  static const _bgmMinVol = 0;
  static const _bgmMaxVol = 0.6;

  int _nSnowmanCollected = 0;
  int _nLives = 3;
  bool get _isOffTrail => _nTrailTriggers == 0;
  bool _levelCompleted = false;
  bool _gameOver = false;
  AudioPlayer? _bgmTrack;

  @override
  Future<void> onLoad() async {
    if (game.musicValueNotifier.value) {
      _bgmTrack =
          await FlameAudio.loopLongAudio(SkiMasterGame.bgmTrack, volume: 0);
    }
    final map =
        await TiledComponent.load('Level$currentLevel.tmx', Vector2.all(16.0));
    final tiles = game.images.fromCache('../images/tilemap_packed.png');
    _spriteSheet = SpriteSheet(image: tiles, srcSize: Vector2.all(16.0));
    _star1 = map.tileMap.map.properties.getValue<int>('Star1')!;
    _star2 = map.tileMap.map.properties.getValue<int>('Star2')!;
    _star3 = map.tileMap.map.properties.getValue<int>('Star3')!;
    await _setupWorldAndCamera(map);
    await _handleSpawnPoints(map);
    await _handleTriggers(map);
    _fader = RectangleComponent(
        priority: 1,
        size: _camera.viewport.virtualSize,
        paint: Paint()..color = game.backgroundColor(),
        children: [OpacityEffect.fadeOut(LinearEffectController(1.5))]);
    _hud = Hud(
        snowmanSprite: _spriteSheet.getSprite(5, 9),
        playerSprite: _spriteSheet.getSprite(5, 10));
    await _camera.viewport.addAll([_fader, _hud]);
    await _camera.viewfinder.add(_cameraShake);
    _cameraShake.pause();
  }

  @override
  void update(double dt) {
    if (_levelCompleted || _gameOver) {
      _player.timeScale =
          lerpDouble(_player.timeScale, 0, _timeScaleRate * dt)!;
    } else {
      if (_isOffTrail && input.active) {
        _resetTimer.update(dt);
        if (!_resetTimer.isRunning()) {
          _resetTimer.start();
        }
        if (_cameraShake.isPaused) {
          _cameraShake.resume();
        }
      } else {
        if (_resetTimer.isRunning()) {
          _resetTimer.stop();
        }
        if (!_cameraShake.isPaused) {
          _cameraShake.pause();
        }
      }
    }
    if (_bgmTrack != null) {
      if (_levelCompleted) {
        if (_bgmTrack!.volume > _bgmMinVol) {
          _bgmTrack!.setVolume(
              lerpDouble(_bgmTrack!.volume, _bgmMinVol, _bgmFadeRate * dt)!);
        }
      } else {
        if (_bgmTrack!.volume < _bgmMaxVol) {
          _bgmTrack!.setVolume(
              lerpDouble(_bgmTrack!.volume, _bgmMaxVol, _bgmFadeRate * dt)!);
        }
      }
    }
    super.update(dt);
  }

  @override
  void onRemove() {
    _bgmTrack?.dispose();
  }

  Future<void> _handleSpawnPoints(TiledComponent<FlameGame<World>> map) async {
    final spawnPointLayer = map.tileMap.getLayer<ObjectGroup>('SpawnPoint');
    final objects = spawnPointLayer?.objects;

    if (objects != null) {
      for (var object in objects) {
        switch (object.class_) {
          case 'Player':
            _player = Player(
                priority: 1,
                position: Vector2(object.x, object.y),
                sprite: _spriteSheet.getSprite(5, 10));
            await _world.add(_player);
            _camera.follow(_player);
            _lastSafePosition = Vector2(object.x, object.y);
            break;
          case 'Snowman':
            final snowman = Snowman(
                onCollected: _onSnowmanCollected,
                position: Vector2(object.x, object.y),
                sprite: _spriteSheet.getSprite(5, 9));
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
                collisionType: CollisionType.passive, isSolid: true);
            hitbox.onCollisionStartCallback = (_, __) => _onTrailEnter();
            hitbox.onCollisionEndCallback = (_) => _onTrailExit();
            await map.add(hitbox);
            break;
          case 'Checkpoint':
            final checkpoint = RectangleHitbox(
                position: Vector2(object.x, object.y),
                collisionType: CollisionType.passive,
                size: Vector2(object.width, object.height));
            checkpoint.onCollisionStartCallback =
                (_, __) => _onCheckPoint(checkpoint);
            await map.add(checkpoint);
            break;
          case 'Ramp':
            final ramp = RectangleHitbox(
                position: Vector2(object.x, object.y),
                collisionType: CollisionType.passive,
                size: Vector2(object.width, object.height));
            ramp.onCollisionStartCallback = (_, __) => _onRamp();
            await map.add(ramp);
            break;
          case 'Start':
            final trailStart = RectangleHitbox(
                position: Vector2(object.x, object.y),
                collisionType: CollisionType.passive,
                size: Vector2(object.width, object.height));
            trailStart.onCollisionStartCallback = (_, __) => _onTrailStart();
            await map.add(trailStart);
            break;
          case 'End':
            final trailEnd = RectangleHitbox(
                position: Vector2(object.x, object.y),
                collisionType: CollisionType.passive,
                size: Vector2(object.width, object.height));
            trailEnd.onCollisionStartCallback = (_, __) => _onTrailEnd();
            await map.add(trailEnd);
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

  void _onSnowmanCollected() {
    ++_nSnowmanCollected;
    _hud.updateSnowmanCount(_nSnowmanCollected);
  }

  void _onTrailEnter() {
    ++_nTrailTriggers;
  }

  void _onTrailExit() {
    --_nTrailTriggers;
  }

  void _resetPlayer() {
    --_nLives;
    _hud.updateLifeCount(_nLives);
    if (_nLives > 0) {
      _player.resetTo(_lastSafePosition);
    } else {
      _gameOver = true;
      _fader.add(OpacityEffect.fadeIn(LinearEffectController(1.5)));
      onGameOver.call();
    }
  }

  void _onCheckPoint(RectangleHitbox checkpoint) {
    _lastSafePosition.setFrom(checkpoint.absoluteCenter);
    checkpoint.removeFromParent();
  }

  void _onTrailEnd() {
    _fader.add(OpacityEffect.fadeIn(LinearEffectController(1.5)));
    input.active = false;
    _levelCompleted = true;
    if (_nSnowmanCollected >= _star3) {
      onLevelCompleted.call(3);
    } else if (_nSnowmanCollected >= _star2) {
      onLevelCompleted.call(2);
    } else if (_nSnowmanCollected >= _star1) {
      onLevelCompleted.call(1);
    } else {
      onLevelCompleted.call(0);
    }
  }

  void _onTrailStart() {
    _lastSafePosition.setFrom(_player.position);
    input.active = true;
  }

  void _onRamp() {
    final jumpFactor = _player.jump();
    final jumpScale = lerpDouble(1, 1.2, jumpFactor)!;
    final jumpDuration = lerpDouble(0, 0.8, jumpFactor)!;
    _camera.viewfinder.add(ScaleEffect.by(
        Vector2.all(jumpScale),
        EffectController(
            duration: jumpDuration, alternate: true, curve: Curves.easeInOut)));
  }
}
