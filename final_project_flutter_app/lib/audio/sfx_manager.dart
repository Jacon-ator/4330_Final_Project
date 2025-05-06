import 'package:flame_audio/flame_audio.dart';

class SFXManager {
  static final SFXManager _instance = SFXManager._internal();
  factory SFXManager() => _instance;
  SFXManager._internal();

  bool _isInitialized = false;
  bool _isMuted = false;
  double _volume = 0.5;

  // Getters for current state
  bool get isMuted => _isMuted;
  double get volume => _volume;

  Future<void> initialize() async {
    if (_isInitialized) {
      print('[SFX] SFX manager already initialized');
      return;
    }

    try {
      print('[SFX] ===== Starting SFX Initialization =====');
      print('[SFX] Loading button select sound...');
      await FlameAudio.audioCache.load('audio/sfx/General_SFX/Button_Select.mp3');
      print('[SFX] Button select sound loaded successfully');
      
      print('[SFX] Loading riffle shuffle sound...');
      await FlameAudio.audioCache.load('audio/sfx/Card_SFX/riffle-shuffle-46706.mp3');
      print('[SFX] Riffle shuffle sound loaded successfully');
      
      _isInitialized = true;
      print('[SFX] ===== SFX Initialization Complete =====');
    } catch (e) {
      print('[SFX] ERROR: Failed to initialize SFX');
      print('[SFX] Error details: $e');
      print('[SFX] Stack trace: ${StackTrace.current}');
      if (e is Exception) {
        print('[SFX] Exception type: ${e.runtimeType}');
        print('[SFX] Exception message: ${e.toString()}');
      }
    }
  }

  Future<void> playButtonSelect() async {
    print('[SFX] Attempting to play button select sound...');
    if (!_isInitialized) {
      print('[SFX] SFX not initialized, initializing now...');
      await initialize();
    }

    try {
      if (!_isMuted) {
        print('[SFX] Playing button select sound...');
        await FlameAudio.play('audio/sfx/General_SFX/Button_Select.mp3');
        print('[SFX] Button select sound played successfully');
      } else {
        print('[SFX] Sound is muted, not playing button select sound');
      }
    } catch (e) {
      print('[SFX] ERROR: Failed to play button select sound');
      print('[SFX] Error details: $e');
      print('[SFX] Stack trace: ${StackTrace.current}');
      if (e is Exception) {
        print('[SFX] Exception type: ${e.runtimeType}');
        print('[SFX] Exception message: ${e.toString()}');
      }
    }
  }

  Future<void> playRiffleShuffle() async {
    print('[SFX] Attempting to play riffle shuffle sound...');
    if (!_isInitialized) {
      print('[SFX] SFX not initialized, initializing now...');
      await initialize();
    }

    try {
      if (!_isMuted) {
        print('[SFX] Playing riffle shuffle sound...');
        await FlameAudio.play('audio/sfx/Card_SFX/riffle-shuffle-46706.mp3');
        print('[SFX] Riffle shuffle sound played successfully');
      } else {
        print('[SFX] Sound is muted, not playing riffle shuffle sound');
      }
    } catch (e) {
      print('[SFX] ERROR: Failed to play riffle shuffle sound');
      print('[SFX] Error details: $e');
      print('[SFX] Stack trace: ${StackTrace.current}');
      if (e is Exception) {
        print('[SFX] Exception type: ${e.runtimeType}');
        print('[SFX] Exception message: ${e.toString()}');
      }
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    print('[SFX] Volume set to: $_volume');
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    print('[SFX] Mute toggled: $_isMuted');
  }

  Future<void> dispose() async {
    try {
      print('[SFX] Disposing SFX manager...');
      await FlameAudio.audioCache.clearAll();
      print('[SFX] SFX manager disposed successfully');
    } catch (e) {
      print('[SFX] ERROR: Failed to dispose SFX manager');
      print('[SFX] Error details: $e');
    }
  }
} 