import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/animation.dart';

final _random = Random();

class ParticleEffects {
  ParticleEffects._();

  static const List<Color> _explosionColors = [
    Color(0xFFFF6600),
    Color(0xFFFFAA00),
    Color(0xFFFFFF00),
    Color(0xFFFF3300),
  ];

  static const List<Color> _mergeColors = [
    Color(0xFFFFD700),
    Color(0xFFFFAA00),
    Color(0xFFFFFF88),
  ];

  static const List<Color> _glowColors = [
    Color(0xFF00FFFF),
    Color(0xFFFFFFFF),
    Color(0xFF88FFFF),
  ];

  static void spawnExplosion(Component parent, Vector2 position) {
    parent.add(
      ParticleSystemComponent(
        position: position.clone(),
        particle: Particle.generate(
          count: 14,
          generator: (_) {
            final angle = _random.nextDouble() * pi * 2;
            final speed = 80 + _random.nextDouble() * 120;
            final lifespan = 0.6 + _random.nextDouble() * 0.2;

            return ScalingParticle(
              to: 0.85,
              curve: Curves.easeOut,
              lifespan: lifespan,
              child: AcceleratedParticle(
                acceleration: Vector2(0, 120),
                speed: Vector2(cos(angle) * speed, sin(angle) * speed),
                lifespan: lifespan,
                child: _fadingCircleParticle(
                  radius: 3 + _random.nextDouble() * 3,
                  color:
                      _explosionColors[_random.nextInt(
                        _explosionColors.length,
                      )],
                  lifespan: lifespan,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static void spawnMergeShimmer(Component parent, Vector2 position) {
    parent.add(
      ParticleSystemComponent(
        position: position.clone(),
        particle: Particle.generate(
          count: 9,
          generator: (_) {
            final lifespan = 0.8 + _random.nextDouble() * 0.2;

            return ScalingParticle(
              to: 0.4,
              curve: Curves.easeOut,
              lifespan: lifespan,
              child: AcceleratedParticle(
                acceleration: Vector2(0, -8),
                speed: Vector2(
                  _random.nextDouble() * 40 - 20,
                  -(50 + _random.nextDouble() * 80),
                ),
                lifespan: lifespan,
                child: _fadingCircleParticle(
                  radius: 2 + _random.nextDouble() * 2,
                  color: _mergeColors[_random.nextInt(_mergeColors.length)],
                  lifespan: lifespan,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static void spawnLevelUpGlow(
    Component parent,
    Vector2 position, {
    double cellSize = 64.0,
  }) {
    const count = 20;
    final ringRadius = cellSize * 0.26;

    parent.add(
      ParticleSystemComponent(
        position: position.clone(),
        particle: Particle.generate(
          count: count,
          generator: (index) {
            final angle = (index / count) * pi * 2;
            final direction = Vector2(cos(angle), sin(angle));
            final startOffset = direction.clone()..scale(ringRadius);
            final outwardSpeed = direction.clone()
              ..scale(60 + _random.nextDouble() * 40);

            return ScalingParticle(
              to: 0.3,
              curve: Curves.easeOut,
              lifespan: 0.5,
              child: AcceleratedParticle(
                position: startOffset,
                speed: outwardSpeed,
                acceleration: Vector2.zero(),
                lifespan: 0.5,
                child: _fadingCircleParticle(
                  radius: 2 + _random.nextDouble(),
                  color: _glowColors[_random.nextInt(_glowColors.length)],
                  lifespan: 0.5,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static Particle _fadingCircleParticle({
    required double radius,
    required Color color,
    required double lifespan,
  }) {
    final circle = CircleParticle(
      radius: radius,
      paint: Paint()..color = color,
      lifespan: lifespan,
    );

    return ComputedParticle(
      lifespan: lifespan,
      renderer: (canvas, particle) {
        final alpha = ((1 - particle.progress).clamp(0.0, 1.0) * 255).round();
        circle.paint.color = color.withAlpha(alpha);
        circle.render(canvas);
      },
    );
  }
}
