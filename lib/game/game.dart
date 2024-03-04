import 'dart:async';

import 'package:flame/game.dart';
// import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/widgets.dart' hide Route, OverlayRoute;

import 'package:ski_master/routes/level_selection.dart';
import 'package:ski_master/routes/main_menu.dart';
import 'package:ski_master/routes/settings.dart';

class SkiMasterGame extends FlameGame {
  final musicValueNotifier = ValueNotifier(true);
  final sfxValueNotifier = ValueNotifier(true);
  late final _routes = <String, Route>{
    MainMenu.id: OverlayRoute((context, game) => MainMenu(
          onPlayPressed: () => _routeById(LevelSelection.id),
          onSettingPressed: () => _routeById(Settings.id),
        )),
    LevelSelection.id: OverlayRoute((context, game) => LevelSelection(
          onBackPressed: _popRoute,
        )),
    Settings.id: OverlayRoute((context, game) => Settings(
          onBackPressed: _popRoute,
          musicValueListenable: musicValueNotifier,
          sfxValueListenable: sfxValueNotifier,
          onMusicValueChanged: (value) => musicValueNotifier.value = value,
          onSfxValueChanged: (value) => sfxValueNotifier.value = value,
        )),
  };
  late final _router =
      RouterComponent(initialRoute: MainMenu.id, routes: _routes);
  @override
  Future<void> onLoad() async {
    await add(_router);
    // final map = await TiledComponent.load('sampleMap.tmx', Vector2.all(16.0));
    // await add(map);
  }

  void _routeById(String id) {
    _router.pushNamed(id);
  }

  void _popRoute() {
    _router.pop();
  }
}
