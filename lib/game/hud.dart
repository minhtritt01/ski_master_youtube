import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Viewport;
import 'package:ski_master/game/game.dart';
import 'package:ski_master/game/input.dart';

class Hud extends PositionComponent
    with ParentIsA<Viewport>, HasGameReference<SkiMasterGame> {
  Hud(
      {required Sprite snowmanSprite,
      required Sprite playerSprite,
      this.input,
      this.onPausePressed})
      : _snowman = SpriteComponent(
            sprite: snowmanSprite,
            anchor: Anchor.center,
            scale: Vector2.all(SkiMasterGame.isMobile ? 0.6 : 1.0)),
        _player = SpriteComponent(
            sprite: playerSprite,
            anchor: Anchor.center,
            scale: Vector2.all(SkiMasterGame.isMobile ? 0.6 : 1.0));
  final SpriteComponent _snowman;
  final SpriteComponent _player;
  final Input? input;
  final VoidCallback? onPausePressed;
  final _life = TextComponent(
      text: 'x3',
      anchor: Anchor.centerLeft,
      textRenderer: TextPaint(
          style: const TextStyle(
        color: Colors.black,
        fontSize: SkiMasterGame.isMobile ? 8 : 10,
      )));
  final _score = TextComponent(
      text: 'x0',
      anchor: Anchor.centerLeft,
      textRenderer: TextPaint(
          style: const TextStyle(
        color: Colors.black,
        fontSize: SkiMasterGame.isMobile ? 8 : 10,
      )));
  late final JoystickComponent? _joystick;
  @override
  Future<void> onLoad() async {
    _player.position
        .setValues(16, SkiMasterGame.isMobile ? 10 : parent.virtualSize.y - 20);
    _life.position.setValues(_player.position.x + 8, _player.position.y);
    _snowman.position.setValues(parent.virtualSize.x - 35, _player.y);
    _score.position.setValues(_snowman.position.x + 8, _snowman.position.y);
    await addAll([_player, _life, _snowman, _score]);
    if (SkiMasterGame.isMobile) {
      _joystick = JoystickComponent(
          anchor: Anchor.center,
          position: parent.virtualSize * 0.5,
          background: CircleComponent(
            radius: 20,
            paint: Paint()
              ..color = Colors.black.withOpacity(0.05)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4,
          ),
          knob: CircleComponent(
              radius: 10.0,
              paint: Paint()
                ..color = Colors.green.withOpacity(0.08)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4));
      _joystick?.position.y = parent.virtualSize.y - _joystick.knobRadius * 1.5;
      await _joystick?.addToParent(this);
      final pauseButton = HudButtonComponent(
          anchor: Anchor.bottomRight,
          position: parent.virtualSize,
          onPressed: onPausePressed,
          button: SpriteComponent.fromImage(
            await game.images.load('pause.png'),
            size: Vector2.all(12),
          ));
      await add(pauseButton);
    }
  }

  @override
  void update(double dt) {
    if (input?.active ?? false) {
      input?.hAxis = lerpDouble(
          input!.hAxis,
          _joystick!.isDragged
              ? _joystick.relativeDelta.x * input!.maxHAxis
              : 0,
          input!.sensitivity * dt)!;
    }
    super.update(dt);
  }

  void updateSnowmanCount(int score) {
    _score.text = 'x$score';
    _snowman.add(RotateEffect.by(pi / 8, ZigzagEffectController(period: 0.2)));
    _score.add(ScaleEffect.by(
        Vector2.all(1.2), EffectController(alternate: true, duration: 0.1)));
  }

  void updateLifeCount(int score) {
    _life.text = 'x$score';
    _player.add(RotateEffect.by(pi / 8, ZigzagEffectController(period: 0.2)));
    _life.add(ScaleEffect.by(
        Vector2.all(1.2), EffectController(alternate: true, duration: 0.1)));
  }
}
