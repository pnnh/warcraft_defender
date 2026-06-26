import 'package:flame/components.dart';

import '../components/effects/merge_animation.dart';
import '../components/effects/particle_effects.dart';
import '../components/towers/archer_tower.dart';
import '../components/towers/base_tower.dart';
import '../components/towers/cannon_tower.dart';
import '../components/towers/magic_tower.dart';

/// Handles the merge mechanic: two same-type, same-level towers create one
/// upgraded tower.
class MergeSystem {
  static const int maxLevel = 5;
  static const Map<String, Map<int, int>> _mergeTree = {
    'archer': {1: 2, 2: 3, 3: 4, 4: 5},
    'cannon': {1: 2, 2: 3, 3: 4, 4: 5},
    'magic': {1: 2, 2: 3, 3: 4, 4: 5},
  };

  /// Returns the merged tower if [a] and [b] can merge, or `null` if
  /// they are incompatible.
  BaseTower? tryMerge(BaseTower a, BaseTower b) {
    if (a.type != b.type || a.level != b.level) {
      return null;
    }

    final nextLevel = _mergeTree[a.type]?[a.level];
    if (nextLevel == null || nextLevel > maxLevel) {
      return null;
    }

    return _spawnMerged(a, nextLevel);
  }

  BaseTower? performMerge(BaseTower a, BaseTower b, Component parent) {
    final merged = tryMerge(a, b);
    if (merged == null) {
      return null;
    }

    final center = a.position + (a.size / 2);
    final cellSize = a.size.x > 0
        ? a.size.x
        : (merged.size.x > 0 ? merged.size.x : 56.0);

    a.removeFromParent();
    b.removeFromParent();
    parent.add(merged);
    parent.add(
      MergeAnimation(position: merged.position.clone(), cellSize: cellSize),
    );
    ParticleEffects.spawnMergeShimmer(parent, center);
    ParticleEffects.spawnLevelUpGlow(parent, center, cellSize: cellSize);

    return merged;
  }

  BaseTower _spawnMerged(BaseTower source, int level) {
    final tower = _createTower(source.type, level)
      ..position = source.position.clone()
      ..size = source.size.clone()
      ..angle = source.angle
      ..anchor = source.anchor;
    return tower;
  }

  BaseTower _createTower(String type, int level) {
    switch (type) {
      case 'archer':
        return ArcherTower(level: level);
      case 'cannon':
        return CannonTower(level: level);
      case 'magic':
        return MagicTower(level: level);
    }

    throw UnsupportedError('Unknown tower type: $type');
  }
}
