import 'dart:ui';

import 'package:flame/components.dart' show HasTimeScale;
import 'package:flame/game.dart';

import 'game_state.dart';
import 'audio/audio_manager.dart';
import 'components/grid/grid_board.dart';
import 'components/grid/grid_cell.dart';
import 'components/towers/archer_tower.dart';
import 'components/towers/base_tower.dart';
import 'components/towers/cannon_tower.dart';
import 'components/towers/magic_tower.dart';
import 'components/ui/tower_palette.dart';
import 'systems/merge_system.dart';
import 'systems/skill_system.dart';
import 'systems/wave_manager.dart';

/// Main FlameGame entry point for Fort Guardian.
/// Orchestrates all game systems: grid, waves, skills, and combat.
class FortGame extends FlameGame with HasTimeScale {
  static const int startingGold = 150;

  late final GridBoard _grid;
  late final TowerPalette _towerPalette;
  late final VoidCallback _gameStateListener;
  late final WaveManager _waveManager;

  _DragPlacementState? _dragPlacement;
  int gold = startingGold;
  final MergeSystem _mergeSystem = MergeSystem();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await AudioManager.instance.initialize();
    await AudioManager.instance.onGameplayStart();

    gold = startingGold;
    _gameStateListener = () {
      timeScale = GameState.instance.speed;
    };
    GameState.instance.addListener(_gameStateListener);
    GameState.instance.updateWave(0);
    GameState.instance.updateFortHp(10000, maxHp: 10000);
    GameState.instance.setSpeed(1.0);
    _syncGoldState();

    // Compute grid dimensions so the tile texture covers the full screen width.
    const gridCols = 5;
    const gridGap = 2.0;
    const paletteH = 90.0;
    const paletteBottomPad = 24.0;
    final availH = size.y - paletteH - paletteBottomPad - 4.0;
    final cellSize = ((size.x - gridCols * gridGap) / gridCols)
        .floorToDouble()
        .clamp(40.0, 100.0);
    final rows = ((availH + gridGap) / (cellSize + gridGap))
        .floor()
        .clamp(6, 16);
    // lockRows: rows in the combat zone + castle row; ~60% of total rows.
    final lockRows = (rows * 0.6).round().clamp(2, rows - 2);

    _grid = GridBoard(
      rows: rows,
      cols: gridCols,
      cellSize: cellSize,
      lockRows: lockRows,
    );
    _towerPalette = TowerPalette(
      currentGold: () => gold,
      onDragStart: _handleTowerDragStart,
      onDragUpdate: _handleTowerDragUpdate,
      onDragEnd: _handleTowerDragEnd,
      onDragCancel: _cancelTowerDrag,
    );

    await add(_grid);
    await add(_towerPalette);
    _waveManager = WaveManager(
      gridBoard: _grid,
      onGameOver: () {
        AudioManager.instance.onGameOver();
        GameState.instance.updateFortHp(0);
        pauseEngine();
        overlays.add('gameOver');
      },
      onWaveComplete: (wave) {
        GameState.instance.updateWave(wave);
        if (wave >= 20) {
          AudioManager.instance.onVictory();
          pauseEngine();
          overlays.add('victory');
          return;
        }

        SkillSystem.instance.requestSelection(wave: wave);
        pauseEngine();
        overlays.add('skillSelect');
      },
    );
    await add(_waveManager);
    _positionComponents();
    timeScale = GameState.instance.speed;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    if (isLoaded) {
      _positionComponents();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isLoaded) {
      return;
    }

    if (GameState.instance.wave != _waveManager.currentWave) {
      GameState.instance.updateWave(_waveManager.currentWave);
    }

    if (GameState.instance.fortHp != _waveManager.fortHp) {
      GameState.instance.updateFortHp(_waveManager.fortHp);
    }
  }

  @override
  void onRemove() {
    GameState.instance.removeListener(_gameStateListener);
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final dragPlacement = _dragPlacement;
    if (dragPlacement == null) {
      return;
    }

    final ghostSize = _grid.cellSize * 0.68;
    final ghostRect = Rect.fromCenter(
      center: Offset(
        dragPlacement.canvasPosition.x,
        dragPlacement.canvasPosition.y,
      ),
      width: ghostSize,
      height: ghostSize,
    );
    final ghostFillPaint = Paint()
      ..color = dragPlacement.entry.fillColor.withAlpha(150);
    final ghostBorderPaint = Paint()
      ..color = dragPlacement.isValidDrop
          ? dragPlacement.entry.accentColor
          : const Color(0xFFFF8A80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(ghostRect, const Radius.circular(8)),
      ghostFillPaint,
    );
    canvas.drawCircle(
      ghostRect.center,
      ghostSize * 0.18,
      Paint()..color = dragPlacement.entry.accentColor.withAlpha(200),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(ghostRect, const Radius.circular(8)),
      ghostBorderPaint,
    );
  }

  void _positionComponents() {
    // Grid fills the full screen width from y=0 (tiles cover the whole canvas).
    const paletteH = 90.0;
    const paletteBottomPad = 24.0;
    final paletteY = size.y - paletteH - paletteBottomPad;
    final paletteX = (size.x - _towerPalette.size.x) / 2;

    _grid.position = Vector2(0, 0);
    _towerPalette.position = Vector2(paletteX, paletteY);
  }

  void _handleTowerDragStart(TowerPaletteEntry entry, Vector2 canvasPosition) {
    _dragPlacement = _DragPlacementState(
      entry: entry,
      canvasPosition: canvasPosition.clone(),
      isValidDrop: false,
    );
    _updateGhostState(canvasPosition);
  }

  void _handleTowerDragUpdate(Vector2 canvasPosition) {
    final dragPlacement = _dragPlacement;
    if (dragPlacement == null) {
      return;
    }

    dragPlacement.canvasPosition = canvasPosition.clone();
    _updateGhostState(canvasPosition);
  }

  void _handleTowerDragEnd(TowerPaletteEntry entry, Vector2 canvasPosition) {
    final dragPlacement = _dragPlacement;
    if (dragPlacement == null) {
      return;
    }

    dragPlacement.canvasPosition = canvasPosition.clone();
    final targetCell = _grid.cellAtCanvasPosition(canvasPosition);

    // --- Merge path: drop onto an occupied cell with the same tower type ---
    if (targetCell != null && !targetCell.isLocked && targetCell.isOccupied) {
      final existingTower = targetCell.occupyingTower;
      if (existingTower != null && existingTower.type == entry.id) {
        // Only attempt merge if we can afford the new tower (merge costs one unit)
        if (gold >= entry.cost) {
          final merged = _mergeSystem.performMerge(
              existingTower, _createTowerForEntry(entry), _grid);
          if (merged != null) {
            targetCell.occupyingTower = merged;
            gold -= entry.cost;
            _syncGoldState();
            // performMerge already plays merge audio and spawns particles
          }
        }
      }
      _clearDragPlacement();
      return;
    }

    // --- Normal placement path ---
    final canPlace =
        targetCell != null &&
        !targetCell.isLocked &&
        !targetCell.isOccupied &&
        gold >= dragPlacement.entry.cost;

    if (canPlace) {
      _placeTower(targetCell, entry);
      gold -= dragPlacement.entry.cost;
      _syncGoldState();
      AudioManager.instance.playTowerPlace();
    }

    _clearDragPlacement();
  }

  void _cancelTowerDrag() {
    _clearDragPlacement();
  }

  void _updateGhostState(Vector2 canvasPosition) {
    final dragPlacement = _dragPlacement;
    if (dragPlacement == null) {
      _grid.clearGhostCell();
      return;
    }

    final targetCell = _grid.cellAtCanvasPosition(canvasPosition);

    // Valid if: unlocked empty cell with enough gold, OR same-type tower for merge
    final isMergeTarget = targetCell != null &&
        !targetCell.isLocked &&
        targetCell.isOccupied &&
        targetCell.occupyingTower?.type == dragPlacement.entry.id &&
        gold >= dragPlacement.entry.cost;
    final isPlaceTarget = targetCell != null &&
        !targetCell.isLocked &&
        !targetCell.isOccupied &&
        gold >= dragPlacement.entry.cost;
    final isValidDrop = isMergeTarget || isPlaceTarget;

    dragPlacement.isValidDrop = isValidDrop;
    _grid.setGhostCell(targetCell, isValid: isValidDrop);
  }

  void _placeTower(GridCell cell, TowerPaletteEntry entry) {
    _grid.setOccupied(cell.row, cell.col, true);

    final towerSize = _grid.cellSize * 0.72;
    final tower = _createTowerForEntry(entry)
      ..size = Vector2.all(towerSize)
      ..position =
          cell.position + Vector2.all((_grid.cellSize - towerSize) / 2)
      ..getEnemies = () => _waveManager.activeEnemies;

    cell.occupyingTower = tower;
    _grid.add(tower);
  }

  BaseTower _createTowerForEntry(TowerPaletteEntry entry) {
    switch (entry.type) {
      case TowerType.cannon:
        return CannonTower();
      case TowerType.magic:
        return MagicTower();
      case TowerType.archer:
        return ArcherTower();
    }
  }

  void _clearDragPlacement() {
    _grid.clearGhostCell();
    _dragPlacement = null;
  }

  void _syncGoldState() {
    final delta = gold - GameState.instance.gold;
    if (delta > 0) {
      GameState.instance.addGold(delta);
      return;
    }

    if (delta < 0) {
      GameState.instance.spendGold(-delta);
    }
  }
}

class _DragPlacementState {
  _DragPlacementState({
    required this.entry,
    required this.canvasPosition,
    required this.isValidDrop,
  });

  final TowerPaletteEntry entry;
  Vector2 canvasPosition;
  bool isValidDrop;
}
