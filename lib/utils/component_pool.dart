import 'package:flame/components.dart' show Component;

import 'object_pool.dart';

/// Pool helper for Flame [Component]s.
class ComponentPool<T extends Component> {
  ComponentPool({
    required T Function() factory,
    void Function(T component)? reset,
    int initialSize = 5,
    int maxSize = 30,
  }) : _pool = ObjectPool<T>(
         factory,
         reset: reset,
         initialSize: initialSize,
         maxSize: maxSize,
       );

  final ObjectPool<T> _pool;

  T acquire(Component parent) {
    final component = _pool.acquire();
    if (component.parent != parent) {
      component.removeFromParent();
      parent.add(component);
    }
    return component;
  }

  void release(T component) {
    component.removeFromParent();
    _pool.release(component);
  }

  int get poolSize => _pool.poolSize;
  int get acquiredCount => _pool.acquiredCount;
  int get totalCreated => _pool.totalCreated;
}
