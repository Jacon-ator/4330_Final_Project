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
      await FlameAudio.bgm.initialize();
      await FlameAudio.audioCache.load('music/Poker_Party_Main_Theme.mp3');
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
      await FlameAudio.bgm.play('music/Poker_Party_Main_Theme.mp3');
      print('Main theme playback started');
    } catch (e) {
      print('Error playing main theme: $e');
    }
  }

  Future<void> stopAll() async {
    try {
      await FlameAudio.bgm.stop();
      await FlameAudio.audioCache.clearAll();
      await FlameAudio.bgm.dispose();
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }
}
