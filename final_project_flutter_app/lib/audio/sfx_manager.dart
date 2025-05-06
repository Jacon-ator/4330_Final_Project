import 'package:flame_audio/flame_audio.dart';

class SFXManager {
  static final SFXManager _instance = SFXManager._internal();
  factory SFXManager() => _instance;
  SFXManager._internal();

  bool _isInitialized = false;
  bool _isMuted = false;
  double _volume = 1.0;

  // Getters for current state
  bool get isMuted => _isMuted;
  double get volume => _volume;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('Initializing SFX manager...');
      await FlameAudio.audioCache.load('assets/audio/sfx/General_SFX/Button_Select.mp3');
      print('SFX files loaded successfully');
      _isInitialized = true;
    } catch (e) {
      print('Error initializing SFX: $e');
    }
  }

  Future<void> playButtonSelect() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (!_isMuted) {
        await FlameAudio.play('assets/audio/sfx/General_SFX/Button_Select.mp3', volume: _volume);
      }
    } catch (e) {
      print('Error playing button select sound: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
  }

  Future<void> dispose() async {
    try {
      await FlameAudio.audioCache.clearAll();
    } catch (e) {
      print('Error disposing SFX: $e');
    }
  }
} 