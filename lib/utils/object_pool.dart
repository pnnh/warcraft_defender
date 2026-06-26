/// Generic object pool to recycle expensive-to-create objects.
///
/// Optionally accepts a [reset] callback to restore instances to a reusable
/// baseline before they are returned to the pool.
class ObjectPool<T> {
  ObjectPool(
    this.factory, {
    this.reset,
    this.initialSize = 0,
    this.maxSize = 50,
  }) {
    for (var i = 0; i < initialSize; i++) {
      _pool.add(_create());
    }
  }

  final T Function() factory;
  final void Function(T object)? reset;
  final int initialSize;
  final int maxSize;

  final List<T> _pool = [];
  int _acquired = 0;
  int _totalCreated = 0;

  /// Acquire an object from the pool, creating one when needed.
  T acquire() {
    _acquired++;
    if (_pool.isNotEmpty) {
      return _pool.removeLast();
    }
    return _create();
  }

  /// Return an object to the pool for reuse.
  void release(T object) {
    if (_acquired > 0) {
      _acquired--;
    }

    if (_pool.length >= maxSize) {
      return;
    }

    reset?.call(object);
    _pool.add(object);
  }

  /// Remove all cached instances from the pool.
  void clear() => _pool.clear();

  int get poolSize => _pool.length;
  int get acquiredCount => _acquired;
  int get totalCreated => _totalCreated;

  T _create() {
    _totalCreated++;
    return factory();
  }
}
