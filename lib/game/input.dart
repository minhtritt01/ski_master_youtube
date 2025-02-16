import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:ski_master/game/game.dart';

class Input extends Component
    with KeyboardHandler, HasGameReference<SkiMasterGame> {
  Input({required this.keyCallbacks});
  final Map<LogicalKeyboardKey, VoidCallback> keyCallbacks;
  bool _leftPressed = false;
  bool _rightPressed = false;

  var _leftInput = 0.0;
  var _rightInput = 0.0;
  final sensitivity = 2.0;
  final maxHAxis = 1.5;
  bool active = false;
  var hAxis = 0.0;
  @override
  void update(double dt) {
    if (!SkiMasterGame.isMobile) {
      _leftInput = lerpDouble(
          _leftInput, (_leftPressed && active) ? 1.5 : 0, sensitivity * dt)!;
      _rightInput = lerpDouble(
          _rightInput, (_rightPressed && active) ? 1.5 : 0, sensitivity * dt)!;
      hAxis = _rightInput - _leftInput;
    }
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!SkiMasterGame.isMobile && game.paused == false) {
      _leftPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
          keysPressed.contains(LogicalKeyboardKey.arrowLeft);
      _rightPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
          keysPressed.contains(LogicalKeyboardKey.arrowRight);

      if (active) {
        for (final entry in keyCallbacks.entries) {
          if (entry.key == event.logicalKey) {
            entry.value.call();
          }
        }
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
