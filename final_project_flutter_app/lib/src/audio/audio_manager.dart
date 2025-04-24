import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      print('Initializing audio manager...');
      await FlameAudio.audioCache.load('audio/music/Poker_Party_Main_Theme.mp3');
      print('Audio file loaded successfully');
      _isInitialized = true;
    } catch (e) {
      print('Error initializing audio: $e');
    }
  }

  Future<void> playMainTheme() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      print('Playing main theme...');
      await FlameAudio.play('audio/music/Poker_Party_Main_Theme.mp3', volume: 0.5);
      print('Main theme playback started');
    } catch (e) {
      print('Error playing main theme: $e');
    }
  }

  void stopAll() {
    try {
      FlameAudio.bgm.stop();
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }
} 