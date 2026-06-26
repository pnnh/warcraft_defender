import 'package:flame/components.dart' show Vector2;

import '../../utils/component_pool.dart' as pools;
import '../components/enemies/goblin_enemy.dart';
import '../components/projectiles/arrow_projectile.dart';
import '../components/projectiles/base_projectile.dart';
import '../components/projectiles/cannonball_projectile.dart';

class GamePools {
  GamePools._();

  static final GamePools instance = GamePools._();

  bool _initialized = false;

  late final pools.ComponentPool<ArrowProjectile> arrows;
  late final pools.ComponentPool<CannonballProjectile> cannonballs;
  late final pools.ComponentPool<GoblinEnemy> goblins;

  void initialize() {
    if (_initialized) {
      return;
    }

    arrows = pools.ComponentPool<ArrowProjectile>(
      factory: ArrowProjectile.acquire,
      reset: _resetProjectile,
      initialSize: 10,
      maxSize: 40,
    );

    cannonballs = pools.ComponentPool<CannonballProjectile>(
      factory: CannonballProjectile.acquire,
      reset: _resetProjectile,
      initialSize: 5,
      maxSize: 20,
    );

    goblins = pools.ComponentPool<GoblinEnemy>(
      factory: GoblinEnemy.new,
      reset: (goblin) {
        goblin
          ..health = 80
          ..speed = 80
          ..pathProgress = 0
          ..isAlive = true
          ..position = Vector2.zero();
      },
      initialSize: 6,
      maxSize: 24,
    );

    _initialized = true;
  }

  void _resetProjectile(BaseProjectile projectile) {
    projectile
      ..position = Vector2.zero()
      ..angle = 0
      ..onRelease = null;
  }
}
