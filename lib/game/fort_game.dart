import 'package:flame/game.dart';

import 'audio/audio_manager.dart';
import 'components/grid/grid_board.dart';

/// Main FlameGame entry point for Fort Guardian.
/// Orchestrates all game systems: grid, waves, skills, and combat.
class FortGame extends FlameGame {
  // TODO(phase1): Initialize GridBoard component
  // TODO(phase2): Initialize WaveManager system
  // TODO(phase3): Initialize SkillSystem (roguelike)

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await AudioManager.instance.initialize();
    await AudioManager.instance.onGameplayStart();

    final grid = GridBoard();
    grid.position = Vector2(
      (size.x - grid.size.x) / 2,
      (size.y - grid.size.y) / 2,
    );
    add(grid);
  }
}
