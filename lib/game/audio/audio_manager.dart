import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

/// Central audio manager for Fort Guardian.
/// All audio interactions go through this singleton.
class AudioManager {
  AudioManager._();

  static final AudioManager instance = AudioManager._();

  bool _initialized = false;
  String? _currentBgm;
  // On web, BGM autoplay is blocked until user interaction.
  // We store a pending track and play it on first pointer event.
  String? _pendingBgm;

  // BGM track names (under assets/audio/bgm/)
  static const String bgmMainMenu = 'bgm/main_menu.mp3';
  static const String bgmGameplay = 'bgm/gameplay_bgm.mp3';
  static const String bgmVictory = 'bgm/victory.mp3';
  static const String bgmGameOver = 'bgm/game_over.mp3';

  // SFX track names (under assets/audio/sfx/)
  static const String sfxArrowShoot = 'sfx/arrow_shoot.mp3';
  static const String sfxCannonFire = 'sfx/cannon_fire.mp3';
  static const String sfxEnemyDeathSmall = 'sfx/enemy_death_small.mp3';
  static const String sfxEnemyDeathLarge = 'sfx/enemy_death_large.mp3';
  static const String sfxMergeSuccess = 'sfx/merge_success.mp3';
  static const String sfxSkillSelect = 'sfx/skill_select.mp3';
  static const String sfxTowerPlace = 'sfx/tower_place.mp3';
  static const String sfxFortHit = 'sfx/fort_hit.mp3';
  static const String sfxGameOver = 'sfx/game_over.mp3';
  static const String sfxWaveComplete = 'sfx/wave_complete.mp3';

  /// Call once during game initialization to pre-cache all audio files.
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await FlameAudio.audioCache.loadAll([
        bgmMainMenu,
        bgmGameplay,
        bgmVictory,
        bgmGameOver,
        sfxArrowShoot,
        sfxCannonFire,
        sfxEnemyDeathSmall,
        sfxEnemyDeathLarge,
        sfxMergeSuccess,
        sfxSkillSelect,
        sfxTowerPlace,
        sfxFortHit,
        sfxGameOver,
        sfxWaveComplete,
      ]);
    } catch (_) {
      // Audio pre-cache may fail on web before user interaction; ignore.
    }
    _initialized = true;
  }

  /// On web, browsers block audio autoplay until the user has interacted.
  /// Call this after the first pointer-down event to unblock pending BGM.
  Future<void> onUserInteraction() async {
    final pending = _pendingBgm;
    if (pending == null) return;
    await _playBgmDirect(pending);
  }

  Future<void> playBgm(String trackName) async {
    if (_currentBgm == trackName) return;
    await stopBgm();
    // On web, defer BGM until user interaction to satisfy autoplay policy.
    if (kIsWeb) {
      _pendingBgm = trackName;
      return;
    }
    try {
      await FlameAudio.bgm.play(trackName, volume: 0.6);
      _currentBgm = trackName;
    } catch (_) {
      // Ignore audio errors (e.g., autoplay blocked).
    }
  }

  Future<void> _playBgmDirect(String trackName) async {
    try {
      await FlameAudio.bgm.play(trackName, volume: 0.6);
      _currentBgm = trackName;
      _pendingBgm = null;
    } catch (_) {
      // Ignore audio errors.
    }
  }

  Future<void> stopBgm() async {
    _pendingBgm = null;
    try {
      await FlameAudio.bgm.stop();
    } catch (_) {}
    _currentBgm = null;
  }

  void pauseBgm() {
    try {
      FlameAudio.bgm.pause();
    } catch (_) {}
  }

  void resumeBgm() {
    try {
      FlameAudio.bgm.resume();
    } catch (_) {}
  }

  Future<void> onMainMenu() => playBgm(bgmMainMenu);

  Future<void> onGameplayStart() => playBgm(bgmGameplay);

  Future<void> onVictory() => playBgm(bgmVictory);

  Future<void> onGameOver() async {
    await stopBgm();
    await playBgm(bgmGameOver);
    playSfx(sfxGameOver);
  }

  /// Play a short sound effect (fire-and-forget).
  void playSfx(String sfxName, {double volume = 1.0}) {
    try {
      FlameAudio.play(sfxName, volume: volume);
    } catch (_) {}
  }

  void playArrowShoot() => playSfx(sfxArrowShoot, volume: 0.7);

  void playCannonFire() => playSfx(sfxCannonFire, volume: 0.9);

  void playEnemyDeathSmall() => playSfx(sfxEnemyDeathSmall);

  void playEnemyDeathLarge() => playSfx(sfxEnemyDeathLarge);

  void playMergeSuccess() => playSfx(sfxMergeSuccess);

  void playSkillSelect() => playSfx(sfxSkillSelect, volume: 0.8);

  void playTowerPlace() => playSfx(sfxTowerPlace);

  void playFortHit() => playSfx(sfxFortHit);

  void playWaveComplete() => playSfx(sfxWaveComplete);
}
