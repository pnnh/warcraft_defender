import 'dart:math';

import 'package:flutter/material.dart';

import '../../ads/ads_manager.dart';
import '../../game/systems/skill_system.dart';

class SkillSelectOverlay extends StatefulWidget {
  const SkillSelectOverlay({
    super.key,
    required this.options,
    required this.onSelected,
  });

  final List<Skill> options;
  final void Function(Skill) onSelected;

  @override
  State<SkillSelectOverlay> createState() => _SkillSelectOverlayState();
}

class _SkillSelectOverlayState extends State<SkillSelectOverlay> {
  late final List<Skill> _options = List<Skill>.of(widget.options);
  bool _rewardConsumed = false;
  bool _showingRewardedAd = false;

  @override
  Widget build(BuildContext context) {
    final canWatchAd =
        !_rewardConsumed &&
        !_showingRewardedAd &&
        AdsManager.instance.isRewardedReady;

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Choose a Skill',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select one permanent buff for this run',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ..._options.map(
                (skill) => _SkillCard(
                  skill: skill,
                  onTap: () => widget.onSelected(skill),
                ),
              ),
              if (canWatchAd) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _watchAdForExtraChoice,
                  icon: const Text('📺'),
                  label: const Text('Watch Ad for Extra Choice'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFD700),
                    side: const BorderSide(color: Color(0xFFFFD700)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _watchAdForExtraChoice() async {
    if (_rewardConsumed || _showingRewardedAd) {
      return;
    }

    setState(() {
      _showingRewardedAd = true;
    });

    try {
      await AdsManager.instance.showRewarded(
        onEarned: (_) {
          final extraSkill = _drawExtraSkill();
          if (extraSkill == null || !mounted) {
            return;
          }
          setState(() {
            _options.add(extraSkill);
            _rewardConsumed = true;
          });
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _showingRewardedAd = false;
        });
      }
    }
  }

  Skill? _drawExtraSkill() {
    final excludedIds = _options.map((skill) => skill.id).toSet();
    final candidates = SkillSystem.instance
        .drawOptions(count: SkillSystem.allSkills.length)
        .where((skill) => !excludedIds.contains(skill.id))
        .toList();

    if (candidates.isEmpty) {
      return null;
    }

    return candidates[Random().nextInt(candidates.length)];
  }
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({required this.skill, required this.onTap});

  final Skill skill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final catColor = switch (skill.category) {
      SkillCategory.damage => const Color(0xFFFF6644),
      SkillCategory.range => const Color(0xFF44AAFF),
      SkillCategory.utility => const Color(0xFF44FF88),
      SkillCategory.special => const Color(0xFFFF44FF),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A3E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: catColor.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: <Widget>[
              Text(skill.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      skill.name,
                      style: TextStyle(
                        color: catColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      skill.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: catColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
