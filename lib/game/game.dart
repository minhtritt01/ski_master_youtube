import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart' hide Route, OverlayRoute;
import 'package:ski_master/game/routes/game_play.dart';
import 'package:ski_master/game/routes/level_complete.dart';

import 'package:ski_master/game/routes/level_selection.dart';
import 'package:ski_master/game/routes/main_menu.dart';
import 'package:ski_master/game/routes/pause_menu.dart';
import 'package:ski_master/game/routes/retry_menu.dart';
import 'package:ski_master/game/routes/settings.dart';

class SkiMasterGame extends FlameGame with HasKeyboardHandlerComponents {
  final musicValueNotifier = ValueNotifier(true);
  final sfxValueNotifier = ValueNotifier(true);
  late final _routes = <String, Route>{
    MainMenu.id: OverlayRoute((context, game) => MainMenu(
          onPlayPressed: () => _routeById(LevelSelection.id),
          onSettingPressed: () => _routeById(Settings.id),
        )),
    LevelSelection.id: OverlayRoute((context, game) => LevelSelection(
          onLevelSelected: _startLevel,
          onBackPressed: _popRoute,
        )),
    Settings.id: OverlayRoute((context, game) => Settings(
          onBackPressed: _popRoute,
          musicValueListenable: musicValueNotifier,
          sfxValueListenable: sfxValueNotifier,
          onMusicValueChanged: (value) => musicValueNotifier.value = value,
          onSfxValueChanged: (value) => sfxValueNotifier.value = value,
        )),
    PauseMenu.id: OverlayRoute((context, game) => PauseMenu(
        onRestartPressed: _restartGame,
        onResumePressed: _resumeGame,
        onExitPressed: _exitToMainMenu)),
    LevelComplete.id: OverlayRoute((context, game) => LevelComplete(
        onRetryPressed: _restartGame,
        onNextPressed: _startNextLevel,
        onExitPressed: _exitToMainMenu)),
    RetryMenu.id: OverlayRoute((context, game) => RetryMenu(
        onRetryPressed: _restartGame, onExitPressed: _exitToMainMenu)),
  };
  late final _router =
      RouterComponent(initialRoute: MainMenu.id, routes: _routes);
  @override
  Future<void> onLoad() async {
    await add(_router);
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 238, 248, 254);
  }

  void _routeById(String id) {
    _router.pushNamed(id);
  }

  void _popRoute() {
    _router.pop();
  }

  void _startLevel(int levelIndex) {
    _router.pop();
    _router.pushReplacement(
        Route(() => GamePLay(levelIndex,
            onLevelCompleted: _showLevelCompleteMenu,
            onPausedPressed: _pauseGame,
            onGameOver: _showRetryMenu,
            key: ComponentKey.named(GamePLay.id))),
        name: GamePLay.id);
  }

  void _pauseGame() {
    _router.pushNamed(PauseMenu.id);
    pauseEngine();
  }

  void _resumeGame() {
    _router.pop();
    resumeEngine();
  }

  void _restartGame() {
    final gamePlay = findByKeyName<GamePLay>(GamePLay.id);
    if (gamePlay != null) {
      _startLevel(gamePlay.currentLevel);
      resumeEngine();
    }
  }

  void _startNextLevel() {
    final gamePlay = findByKeyName<GamePLay>(GamePLay.id);
    if (gamePlay != null) {
      _startLevel(gamePlay.currentLevel + 1);
    }
  }

  void _exitToMainMenu() {
    _resumeGame();
    _router.pushNamed(MainMenu.id);
  }

  void _showLevelCompleteMenu() {
    _router.pushNamed(LevelComplete.id);
  }

  void _showRetryMenu() {
    _router.pushNamed(RetryMenu.id);
  }
}
