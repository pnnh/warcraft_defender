/// Generic object pool to recycle Flame components (projectiles, damage numbers).
/// Prevents frequent GC pauses during intense combat.
class ObjectPool<T> {
  final List<T> _available = [];
  final T Function() _factory;

  ObjectPool(this._factory);

  T acquire() {
    if (_available.isNotEmpty) return _available.removeLast();
    return _factory();
  }

  void release(T object) => _available.add(object);

  void clear() => _available.clear();
}
