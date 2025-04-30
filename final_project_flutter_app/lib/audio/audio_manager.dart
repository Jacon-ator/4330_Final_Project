import 'package:flame_audio/flame_audio.dart';
import 'dart:async';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _isInitialized = false;
  bool _isMuted = false;
  double _volume = 1.0; // Default volume (0.0 to 1.0)
  StreamController<double> _volumeController = StreamController<double>.broadcast();
  StreamController<bool> _muteController = StreamController<bool>.broadcast();

  // Streams to listen for volume and mute state changes
  Stream<double> get volumeStream => _volumeController.stream;
  Stream<bool> get muteStream => _muteController.stream;

  // Getters for current state
  bool get isMuted => _isMuted;
  double get volume => _volume;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('Initializing audio manager...');
      await FlameAudio.bgm.initialize();
      await FlameAudio.audioCache.load('music/Poker_Party_Main_Theme.mp3');
      print('Audio file loaded successfully');
      _isInitialized = true;
      
      // Set initial volume
      await setVolume(_volume);
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
      
      // Apply current volume settings
      if (_isMuted) {
        await FlameAudio.bgm.audioPlayer.setVolume(0);
      } else {
        await FlameAudio.bgm.audioPlayer.setVolume(_volume);
      }
    } catch (e) {
      print('Error playing main theme: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      // Ensure volume is between 0 and 1
      _volume = volume.clamp(0.0, 1.0);
      
      // Auto-mute when volume is set to 0
      if (_volume == 0.0 && !_isMuted) {
        await toggleMute();
        return; // toggleMute will handle setting volume to 0
      }
      
      // Auto-unmute when volume is changed from 0
      if (_volume > 0.0 && _isMuted) {
        await toggleMute();
        // Continue to apply the volume below
      }
      
      // Apply volume if not muted
      if (!_isMuted && _isInitialized) {
        await FlameAudio.bgm.audioPlayer.setVolume(_volume);
      }
      
      // Notify listeners
      _volumeController.add(_volume);
      print('Volume set to: $_volume');
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  Future<void> toggleMute() async {
    try {
      _isMuted = !_isMuted;
      
      if (_isInitialized) {
        if (_isMuted) {
          await FlameAudio.bgm.audioPlayer.setVolume(0);
        } else {
          await FlameAudio.bgm.audioPlayer.setVolume(_volume);
        }
      }
      
      // Notify listeners
      _muteController.add(_isMuted);
      print('Mute toggled: $_isMuted');
    } catch (e) {
      print('Error toggling mute: $e');
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
  
  void dispose() {
    _volumeController.close();
    _muteController.close();
  }
}
