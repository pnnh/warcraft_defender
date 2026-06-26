import 'dart:math';

import 'package:flutter/foundation.dart';

enum SkillCategory { damage, range, utility, special }

abstract interface class SkillTarget {
  String get type;

  double get attackRange;
  set attackRange(double value);

  double get attackDamage;
  set attackDamage(double value);

  double get attackCooldown;
  set attackCooldown(double value);

  double get critChance;
  set critChance(double value);

  double get splashRadiusBonus;
  set splashRadiusBonus(double value);

  int get bonusProjectiles;
  set bonusProjectiles(int value);

  int get chainTargetBonus;
  set chainTargetBonus(int value);

  double get slowEffectStrength;
  set slowEffectStrength(double value);

  double get splashDamageMultiplier;
  set splashDamageMultiplier(double value);
}

class Skill {
  const Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final SkillCategory category;
  final String icon;
}

class SkillSelectionRequest {
  const SkillSelectionRequest({required this.wave, required this.options});

  final int wave;
  final List<Skill> options;
}

/// Manages roguelike skill selection pool and application.
class SkillSystem {
  SkillSystem._();

  static final SkillSystem instance = SkillSystem._();

  static final List<Skill> allSkills = <Skill>[
    Skill(
      id: 'dmg_boost_1',
      name: 'Sharp Arrows',
      description: '+20% damage to all towers',
      category: SkillCategory.damage,
      icon: '🏹',
    ),
    Skill(
      id: 'dmg_boost_2',
      name: 'Iron Cannonballs',
      description: '+25% cannon damage',
      category: SkillCategory.damage,
      icon: '💣',
    ),
    Skill(
      id: 'dmg_boost_3',
      name: 'Arcane Surge',
      description: '+30% magic tower damage',
      category: SkillCategory.damage,
      icon: '🔮',
    ),
    Skill(
      id: 'range_boost_1',
      name: 'Eagle Eye',
      description: '+25% range for all towers',
      category: SkillCategory.range,
      icon: '👁️',
    ),
    Skill(
      id: 'range_boost_2',
      name: 'Watchtower',
      description: '+40% range for archer towers',
      category: SkillCategory.range,
      icon: '🗼',
    ),
    Skill(
      id: 'speed_boost_1',
      name: 'Rapid Fire',
      description: '-20% attack cooldown for all towers',
      category: SkillCategory.utility,
      icon: '⚡',
    ),
    Skill(
      id: 'speed_boost_2',
      name: 'Siege Master',
      description: '-15% cannon cooldown',
      category: SkillCategory.utility,
      icon: '🎯',
    ),
    Skill(
      id: 'gold_1',
      name: 'Bounty Hunter',
      description: '+1 gold per enemy kill',
      category: SkillCategory.utility,
      icon: '💰',
    ),
    Skill(
      id: 'gold_2',
      name: 'Tax Collector',
      description: '+50% gold at wave start',
      category: SkillCategory.utility,
      icon: '🪙',
    ),
    Skill(
      id: 'splash_1',
      name: 'Explosive Arrows',
      description: 'Arrows deal 30% splash damage',
      category: SkillCategory.special,
      icon: '💥',
    ),
    Skill(
      id: 'chain_1',
      name: 'Chain Lightning',
      description: 'Magic chains to +1 extra enemy',
      category: SkillCategory.special,
      icon: '🌩️',
    ),
    Skill(
      id: 'slow_1',
      name: 'Frostbolt',
      description: 'Cannonballs slow enemies by 30%',
      category: SkillCategory.special,
      icon: '❄️',
    ),
    Skill(
      id: 'fort_hp_1',
      name: 'Reinforced Walls',
      description: '+20 max fort HP',
      category: SkillCategory.utility,
      icon: '🏰',
    ),
    Skill(
      id: 'merge_boost_1',
      name: 'Alchemist',
      description: 'Merged towers start with +10% stats',
      category: SkillCategory.special,
      icon: '⚗️',
    ),
    Skill(
      id: 'multi_shot_1',
      name: 'Split Arrow',
      description: 'Archers fire at 2 targets at once',
      category: SkillCategory.special,
      icon: '🎪',
    ),
    Skill(
      id: 'crit_1',
      name: 'Critical Strike',
      description: '15% chance to deal 3× damage',
      category: SkillCategory.damage,
      icon: '⚔️',
    ),
    Skill(
      id: 'aoe_1',
      name: 'Tremor',
      description: '+30% cannon splash radius',
      category: SkillCategory.special,
      icon: '🌍',
    ),
    Skill(
      id: 'tower_cost_1',
      name: 'Master Builder',
      description: '-15% tower placement gold cost',
      category: SkillCategory.utility,
      icon: '🔨',
    ),
  ];

  final Random _rng = Random();
  final List<Skill> _activeSkills = <Skill>[];
  final ValueNotifier<SkillSelectionRequest?> _pendingSelection =
      ValueNotifier<SkillSelectionRequest?>(null);

  int bonusGoldPerKill = 0;
  double waveStartGoldMultiplier = 1.0;
  int fortHpBonus = 0;
  double mergedTowerStatMultiplier = 1.0;
  double towerCostMultiplier = 1.0;

  List<Skill> get activeSkills => List<Skill>.unmodifiable(_activeSkills);
  ValueListenable<SkillSelectionRequest?> get selectionListenable =>
      _pendingSelection;
  SkillSelectionRequest? get pendingSelection => _pendingSelection.value;

  void reset() {
    _activeSkills.clear();
    bonusGoldPerKill = 0;
    waveStartGoldMultiplier = 1.0;
    fortHpBonus = 0;
    mergedTowerStatMultiplier = 1.0;
    towerCostMultiplier = 1.0;
    _pendingSelection.value = null;
  }

  /// Draws unique random skills that have not already been selected.
  List<Skill> drawOptions({int count = 3}) {
    final available = allSkills
        .where((skill) => !_activeSkills.any((active) => active.id == skill.id))
        .toList();
    final pool = available.isEmpty ? List<Skill>.of(allSkills) : available;
    pool.shuffle(_rng);
    final safeCount = count.clamp(0, pool.length);
    return pool.take(safeCount).toList(growable: false);
  }

  SkillSelectionRequest? requestSelection({required int wave, int count = 3}) {
    if (_pendingSelection.value != null) {
      return _pendingSelection.value;
    }

    final options = drawOptions(count: count);
    if (options.isEmpty) {
      return null;
    }

    final request = SkillSelectionRequest(wave: wave, options: options);
    _pendingSelection.value = request;
    return request;
  }

  void completeSelection(Skill skill) {
    applySkill(skill);
    _pendingSelection.value = null;
  }

  void applySkill(Skill skill) {
    if (hasSkill(skill.id)) {
      return;
    }

    _activeSkills.add(skill);
    switch (skill.id) {
      case 'gold_1':
        bonusGoldPerKill += 1;
        break;
      case 'gold_2':
        waveStartGoldMultiplier += 0.5;
        break;
      case 'fort_hp_1':
        fortHpBonus += 20;
        break;
      case 'merge_boost_1':
        mergedTowerStatMultiplier += 0.1;
        break;
      case 'tower_cost_1':
        towerCostMultiplier *= 0.85;
        break;
      default:
        break;
    }
  }

  void applyBuffsToTarget(SkillTarget target) {
    for (final skill in _activeSkills) {
      applySkillToTarget(skill, target);
    }
  }

  void applySkillToTarget(Skill skill, SkillTarget target) {
    switch (skill.id) {
      case 'dmg_boost_1':
        target.attackDamage *= 1.20;
        break;
      case 'dmg_boost_2':
        if (target.type == 'cannon') {
          target.attackDamage *= 1.25;
        }
        break;
      case 'dmg_boost_3':
        if (target.type == 'magic') {
          target.attackDamage *= 1.30;
        }
        break;
      case 'range_boost_1':
        target.attackRange *= 1.25;
        break;
      case 'range_boost_2':
        if (target.type == 'archer') {
          target.attackRange *= 1.40;
        }
        break;
      case 'speed_boost_1':
        target.attackCooldown = (target.attackCooldown * 0.80)
            .clamp(0.1, double.infinity)
            .toDouble();
        break;
      case 'speed_boost_2':
        if (target.type == 'cannon') {
          target.attackCooldown = (target.attackCooldown * 0.85)
              .clamp(0.1, double.infinity)
              .toDouble();
        }
        break;
      case 'splash_1':
        if (target.type == 'archer') {
          target.splashDamageMultiplier += 0.30;
        }
        break;
      case 'chain_1':
        if (target.type == 'magic') {
          target.chainTargetBonus += 1;
        }
        break;
      case 'slow_1':
        if (target.type == 'cannon') {
          target.slowEffectStrength = max(target.slowEffectStrength, 0.30);
        }
        break;
      case 'multi_shot_1':
        if (target.type == 'archer') {
          target.bonusProjectiles += 1;
        }
        break;
      case 'crit_1':
        target.critChance += 0.15;
        break;
      case 'aoe_1':
        if (target.type == 'cannon') {
          target.splashRadiusBonus += 0.30;
        }
        break;
      default:
        break;
    }
  }

  bool hasSkill(String id) => _activeSkills.any((skill) => skill.id == id);
}
