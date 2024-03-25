import 'dart:async';
import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' hide Viewport;

class Hud extends Component with ParentIsA<Viewport> {
  Hud({required Sprite snowmanSprite, required Sprite playerSprite})
      : _snowman =
            SpriteComponent(sprite: snowmanSprite, anchor: Anchor.center),
        _player = SpriteComponent(sprite: playerSprite, anchor: Anchor.center);
  final SpriteComponent _snowman;
  final SpriteComponent _player;
  final _life = TextComponent(
      text: 'x3',
      anchor: Anchor.centerLeft,
      textRenderer: TextPaint(
          style: const TextStyle(color: Colors.black, fontSize: 10.0)));
  final _score = TextComponent(
      text: 'x0',
      anchor: Anchor.centerLeft,
      textRenderer: TextPaint(
          style: const TextStyle(color: Colors.black, fontSize: 10.0)));
  @override
  Future<void> onLoad() async {
    _player.position.setValues(16, parent.virtualSize.y - 20);
    _life.position.setValues(_player.position.x + 8, _player.position.y);
    _snowman.position.setValues(parent.virtualSize.x - 35, _player.y);
    _score.position.setValues(_snowman.position.x + 8, _snowman.position.y);
    await addAll([_player, _life, _snowman, _score]);
    return super.onLoad();
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
