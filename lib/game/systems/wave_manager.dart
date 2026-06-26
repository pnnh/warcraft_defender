import 'dart:convert';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../audio/audio_manager.dart';
import '../components/enemies/base_enemy.dart';
import '../components/enemies/goblin_enemy.dart';
import '../components/enemies/orc_enemy.dart';
import '../components/enemies/troll_enemy.dart';
import '../components/enemies/dark_knight_enemy.dart';
import '../components/enemies/boss_dragon_enemy.dart';
import '../components/castle_wall_component.dart';
import '../components/grid/grid_board.dart';
import '../game_state.dart';
import 'skill_system.dart';

class WaveConfig {
  const WaveConfig({required this.wave, required this.enemyGroups});

  factory WaveConfig.fromJson(Map<String, dynamic> json) {
    final enemies = (json['enemies'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(EnemyGroup.fromJson)
        .toList(growable: false);

    return WaveConfig(wave: json['wave'] as int? ?? 0, enemyGroups: enemies);
  }

  final int wave;
  final List<EnemyGroup> enemyGroups;
}

class EnemyGroup {
  const EnemyGroup({
    required this.type,
    required this.count,
    required this.interval,
    required this.healthMult,
    required this.speedMult,
  });

  factory EnemyGroup.fromJson(Map<String, dynamic> json) {
    return EnemyGroup(
      type: json['type'] as String? ?? 'goblin',
      count: json['count'] as int? ?? 0,
      interval: (json['interval'] as num? ?? 1).toDouble(),
      healthMult: (json['health_mult'] as num? ?? 1).toDouble(),
      speedMult: (json['speed_mult'] as num? ?? 1).toDouble(),
    );
  }

  final String type;
  final int count;
  final double interval;
  final double healthMult;
  final double speedMult;
}

/// Manages wave loading, timed enemy spawning, fort damage, and progression.
class WaveManager extends Component {
  WaveManager({
    required this.onGameOver,
    required this.onWaveComplete,
    this.gridBoard,
    this.fortMaxHp = 10000,
  }) : _fortHp = fortMaxHp;

  final void Function() onGameOver;
  final void Function(int wave) onWaveComplete;
  GridBoard? gridBoard;

  int currentWave = 0;
  final int fortMaxHp;

  int _fortHp;
  bool _waveActive = false;
  bool _gameOver = false;
  double _spawnTimer = 0;
  double _nextWaveDelay = 0;
  int _aliveEnemyCount = 0;

  final List<WaveConfig> _waves = <WaveConfig>[];
  final List<_PendingSpawn> _pendingSpawns = <_PendingSpawn>[];
  final Map<BaseEnemy, String> _trackedEnemies = <BaseEnemy, String>{};
  final math.Random _rng = math.Random();

  CastleWallComponent? _fortComponent;

  int get fortHp => _fortHp;
  bool get gameOver => _gameOver;
  bool get waveActive => _waveActive;

  /// Returns all currently-alive tracked enemies. Used by units to find targets.
  List<BaseEnemy> get activeEnemies =>
      _trackedEnemies.keys.where((e) => e.isAlive).toList(growable: false);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadWaveConfig();
    await _ensureFortComponent();

    GameState.instance.updateFortHp(fortMaxHp, maxHp: fortMaxHp);

    if (_waves.isNotEmpty) {
      startNextWave();
    }
  }

  Future<void> _loadWaveConfig() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/waves.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final waves = (data['waves'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(WaveConfig.fromJson)
          .where((wave) => wave.enemyGroups.isNotEmpty)
          .toList(growable: false);

      _waves
        ..clear()
        ..addAll(waves);
    } catch (_) {
      _waves
        ..clear()
        ..add(
          const WaveConfig(
            wave: 1,
            enemyGroups: <EnemyGroup>[
              EnemyGroup(
                type: 'goblin',
                count: 5,
                interval: 1.5,
                healthMult: 1,
                speedMult: 1,
              ),
            ],
          ),
        );
    }
  }

  Future<void> _ensureFortComponent() async {
    if (_fortComponent != null || parent == null) {
      return;
    }

    final board = gridBoard;
    final fort = CastleWallComponent(
      cols: board?.cols ?? 5,
      cellSize: board?.cellSize ?? 64,
      gap: board?.gap ?? 2,
      maxHp: fortMaxHp,
    )
      ..priority = 2
      ..getEnemies = () => activeEnemies;
    _fortComponent = fort;
    _syncFortComponent();
    await parent!.add(fort);
  }

  void startNextWave() {
    if (_gameOver || _waveActive || currentWave >= _waves.length) {
      return;
    }

    final config = _waves[currentWave];
    currentWave += 1;
    GameState.instance.updateWave(currentWave);
    _waveActive = true;
    _spawnTimer = 0;
    _nextWaveDelay = 0;
    _aliveEnemyCount = 0;
    _pendingSpawns.clear();

    var delay = 0.0;
    for (final group in config.enemyGroups) {
      for (var index = 0; index < group.count; index += 1) {
        _pendingSpawns.add(
          _PendingSpawn(
            delay: delay,
            type: group.type,
            healthMult: group.healthMult,
            speedMult: group.speedMult,
          ),
        );
        delay += group.interval;
        _aliveEnemyCount += 1;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _syncFortComponent();

    if (_gameOver) {
      return;
    }

    _reconcileTrackedEnemies();

    if (_waveActive) {
      _spawnTimer += dt;
      while (_pendingSpawns.isNotEmpty &&
          _spawnTimer >= _pendingSpawns.first.delay) {
        final spawn = _pendingSpawns.removeAt(0);
        _spawnEnemy(spawn);
      }

      if (_pendingSpawns.isEmpty && _aliveEnemyCount <= 0) {
        _waveActive = false;
        onWaveComplete(currentWave);
        if (currentWave < _waves.length) {
          _nextWaveDelay = 2;
        }
      }
      return;
    }

    if (_nextWaveDelay > 0 && currentWave < _waves.length) {
      _nextWaveDelay -= dt;
      if (_nextWaveDelay <= 0) {
        startNextWave();
      }
    }
  }

  void _spawnEnemy(_PendingSpawn spawn) {
    final host = parent;
    if (host == null) {
      return;
    }

    final enemy = _createEnemy(spawn);
    _trackedEnemies[enemy] = spawn.type;
    host.add(enemy);
  }

  BaseEnemy _createEnemy(_PendingSpawn spawn) {
    final BaseEnemy enemy;
    switch (spawn.type) {
      case 'orc':
        enemy = OrcEnemy();
      case 'troll':
        enemy = TrollEnemy();
      case 'dark_knight':
        enemy = DarkKnightEnemy();
      case 'boss_dragon':
        enemy = BossDragonEnemy();
      default:
        enemy = GoblinEnemy();
    }
    enemy.health *= spawn.healthMult;
    enemy.speed *= spawn.speedMult;
    enemy.onAttackFort = (damage) => _applyFortDamage(damage);

    final board = gridBoard;
    if (board != null) {
      // Pick a random column so enemies spread across the top edge.
      final entryCol = _rng.nextInt(board.cols);
      // Enemies path to the castle row (lockRows row) as their target.
      final fortRow = board.lockRows;
      final fortCol = board.cols ~/ 2;
      final stride = board.cellSize + board.gap;
      final inset = (board.cellSize - enemy.size.x) / 2;

      // Spawn above the visible grid so the enemy walks in from off-screen.
      final spawnX = board.position.x + entryCol * stride + inset +
          (_rng.nextDouble() - 0.5) * stride * 0.5;
      final spawnY = board.position.y - enemy.size.y - 10 - _rng.nextDouble() * 30;

      enemy
        ..gridBoard = board
        ..entryCell = (0, entryCol)
        ..fortCell = (fortRow, fortCol)
        ..position = Vector2(spawnX, spawnY);
      enemy.calculatePath();
    }

    return enemy;
  }

  void _reconcileTrackedEnemies() {
    if (_trackedEnemies.isEmpty) {
      return;
    }

    final processed = <BaseEnemy>[];
    for (final entry in _trackedEnemies.entries) {
      final enemy = entry.key;

      // When an enemy reaches fort proximity, stop it and let it attack.
      if (!enemy.isAttackingFort && _isNearFort(enemy)) {
        enemy.isAttackingFort = true;
      }

      _updateEnemyProgress(enemy);

      if (!enemy.isAlive || enemy.parent == null) {
        processed.add(enemy);
        enemyKilled();
      }
    }

    for (final enemy in processed) {
      _trackedEnemies.remove(enemy);
    }
  }

  /// Returns true when an enemy is close enough to the fort to start attacking.
  bool _isNearFort(BaseEnemy enemy) {
    final board = gridBoard;
    if (board == null) return false;
    // Castle wall is centered on the lockRows boundary.
    final fortCenter = _cellCenter(board, board.lockRows, board.cols ~/ 2);
    return enemy.absoluteCenter.distanceTo(fortCenter) <= board.cellSize * 1.2;
  }

  void _applyFortDamage(int damage) {
    if (_gameOver) return;
    _fortHp = (_fortHp - damage).clamp(0, fortMaxHp);
    _fortComponent?.takeDamage(damage);
    GameState.instance.updateFortHp(_fortHp, maxHp: fortMaxHp);
    AudioManager.instance.playFortHit();
    if (_fortHp == 0) {
      _gameOver = true;
      _waveActive = false;
      _nextWaveDelay = 0;
      onGameOver();
    }
  }

  void _updateEnemyProgress(BaseEnemy enemy) {
    final board = gridBoard;
    if (board == null) {
      return;
    }

    // Progress: distance travelled from spawn row toward the castle row.
    final entryCenter = _cellCenter(board, 0, board.cols ~/ 2);
    final fortCenter = _cellCenter(board, board.lockRows, board.cols ~/ 2);
    final totalDistance = (fortCenter - entryCenter).length;
    if (totalDistance <= 0) {
      return;
    }

    final currentDistance = (enemy.absoluteCenter - entryCenter).length;
    enemy.pathProgress = (currentDistance / totalDistance).clamp(0.0, 1.0);
  }

  Vector2 _cellCenter(GridBoard board, int row, int col) {
    final stride = board.cellSize + board.gap;
    return board.absolutePosition +
        Vector2(
          col * stride + (board.cellSize / 2),
          row * stride + (board.cellSize / 2),
        );
  }

  void enemyKilled() {
    _aliveEnemyCount = (_aliveEnemyCount - 1).clamp(0, 999999);
    final goldReward = 5 + SkillSystem.instance.bonusGoldPerKill;
    GameState.instance.addGold(goldReward);
    GameState.instance.addEnemyKill();
    AudioManager.instance.playEnemyDeathSmall();
  }

  void _syncFortComponent() {
    final board = gridBoard;
    final wall = _fortComponent;
    if (board == null || wall == null) {
      return;
    }

    final stride = board.cellSize + board.gap;
    final wallH = board.cellSize;

    // Castle wall sits at the boundary between combat zone and building zone.
    // Its top edge is flush with the start of lockRows row (castle row).
    wall
      ..size = Vector2(board.size.x, wallH)
      ..position = board.position +
          Vector2(0, board.lockRows * stride - wallH / 2);
  }
}

class _PendingSpawn {
  const _PendingSpawn({
    required this.delay,
    required this.type,
    required this.healthMult,
    required this.speedMult,
  });

  final double delay;
  final String type;
  final double healthMult;
  final double speedMult;
}
