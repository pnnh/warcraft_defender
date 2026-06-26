import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../game/fort_game.dart';
import '../../game/components/grid/grid_board.dart';
import '../../game/components/towers/base_tower.dart';
import '../../game/systems/skill_system.dart';
import '../../game/systems/wave_manager.dart';
import '../widgets/hud_overlay.dart';
import '../widgets/skill_select_overlay.dart';

/// Main game screen: hosts the Flame GameWidget with Flutter HUD overlays.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final FortGame _game;
  bool _waveManagerAttached = false;

  @override
  void initState() {
    super.initState();
    SkillSystem.instance.reset();
    SkillSystem.instance.selectionListenable.addListener(_handleSelectionState);
    _game = FortGame();
    _attachWaveManager();
  }

  @override
  void dispose() {
    SkillSystem.instance.selectionListenable.removeListener(
      _handleSelectionState,
    );
    super.dispose();
  }

  Future<void> _attachWaveManager() async {
    while (mounted && !_game.isLoaded) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    if (!mounted || _waveManagerAttached) {
      return;
    }

    GridBoard? gridBoard;
    for (final component in _walkComponents(_game)) {
      if (component is GridBoard) {
        gridBoard = component;
        break;
      }
    }

    await _game.add(
      WaveManager(
        gridBoard: gridBoard,
        onGameOver: () {},
        onWaveComplete: (wave) {
          SkillSystem.instance.requestSelection(wave: wave);
        },
      ),
    );
    _waveManagerAttached = true;
  }

  void _handleSelectionState() {
    final selection = SkillSystem.instance.pendingSelection;
    if (selection != null) {
      if (!_game.overlays.isActive('skillSelect')) {
        _game.pauseEngine();
        _game.overlays.add('skillSelect');
      }
      return;
    }

    if (_game.overlays.isActive('skillSelect')) {
      _game.overlays.remove('skillSelect');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<FortGame>(
        game: _game,
        initialActiveOverlays: const <String>['hud'],
        overlayBuilderMap: {
          'hud': (context, game) => const HudOverlay(),
          'skillSelect': (context, game) {
            final selection = SkillSystem.instance.pendingSelection;
            if (selection == null) {
              return const SizedBox.shrink();
            }

            return SkillSelectOverlay(
              options: selection.options,
              onSelected: (skill) {
                SkillSystem.instance.completeSelection(skill);
                for (final tower in _collectTowers(game)) {
                  SkillSystem.instance.applySkillToTarget(skill, tower);
                }
                game.resumeEngine();
              },
            );
          },
        },
      ),
    );
  }
}

Iterable<Component> _walkComponents(Component root) sync* {
  yield root;
  for (final child in root.children) {
    yield* _walkComponents(child);
  }
}

Iterable<BaseTower> _collectTowers(Component root) sync* {
  for (final component in _walkComponents(root)) {
    if (component is BaseTower) {
      yield component;
    }
  }
}
