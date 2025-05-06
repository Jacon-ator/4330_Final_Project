import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _isInitialized = false;
  bool _isMuted = false;
  double _volume = 1.0; // Default volume (0.0 to 1.0)
  final StreamController<double> _volumeController = StreamController<double>.broadcast();
  final StreamController<bool> _muteController = StreamController<bool>.broadcast();

  // Streams to listen for volume and mute state changes
  Stream<double> get volumeStream => _volumeController.stream;
  Stream<bool> get muteStream => _muteController.stream;

  // Getters for current state
  bool get isMuted => _isMuted;
  double get volume => _volume;

  Future<void> initialize() async {
    if (_isInitialized) {
      print('[AUDIO] Audio manager already initialized');
      return;
    }

    try {
      print('[AUDIO] ===== Starting Audio Initialization =====');
      print('[AUDIO] Initializing BGM...');
      await FlameAudio.bgm.initialize();
      print('[AUDIO] BGM initialized successfully');
      
      print('[AUDIO] Loading main theme...');
      await FlameAudio.audioCache.load('music/Poker_Party_Main_Theme.mp3');
      print('[AUDIO] Main theme loaded successfully');
      
      print('[AUDIO] Loading shop theme...');
      await FlameAudio.audioCache.load('music/Poker_Party_Shop_Theme.ogg');
      print('[AUDIO] Shop theme loaded successfully');
      
      print('[AUDIO] Loading in-play theme...');
      await FlameAudio.audioCache.load('music/Poker_Party_In_Play_Cycle.mp3');
      print('[AUDIO] In-play theme loaded successfully');
      
      print('[AUDIO] All audio files loaded successfully');
      _isInitialized = true;
      
      // Set initial volume
      print('[AUDIO] Setting initial volume: $_volume');
      await setVolume(_volume);
      print('[AUDIO] Initial volume set successfully');
      print('[AUDIO] ===== Audio Initialization Complete =====');
    } catch (e) {
      print('[AUDIO] ERROR: Failed to initialize audio');
      print('[AUDIO] Error details: $e');
      print('[AUDIO] Stack trace: ${StackTrace.current}');
      if (e is Exception) {
        print('[AUDIO] Exception type: ${e.runtimeType}');
        print('[AUDIO] Exception message: ${e.toString()}');
      }
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

  Future<void> playShopTheme() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      print('Playing shop theme...');
      await FlameAudio.bgm.play('music/Poker_Party_Shop_Theme.ogg');
      print('Shop theme playback started');
      
      // Apply current volume settings
      if (_isMuted) {
        await FlameAudio.bgm.audioPlayer.setVolume(0);
      } else {
        await FlameAudio.bgm.audioPlayer.setVolume(_volume);
      }
    } catch (e) {
      print('Error playing shop theme: $e');
    }
  }

  Future<void> playInPlayTheme() async {
    print('[AUDIO] ===== Starting In-Play Theme Playback =====');
    if (!_isInitialized) {
      print('[AUDIO] Audio not initialized, initializing now...');
      await initialize();
    }

    try {
      print('[AUDIO] Current state:');
      print('[AUDIO] - Mute state: $_isMuted');
      print('[AUDIO] - Volume: $_volume');
      print('[AUDIO] - Initialized: $_isInitialized');
      
      // Stop any currently playing audio
      print('[AUDIO] Stopping any current audio...');
      await FlameAudio.bgm.stop();
      print('[AUDIO] Current audio stopped');
      
      print('[AUDIO] Loading in-play theme file...');
      await FlameAudio.audioCache.load('music/Poker_Party_In_Play_Cycle.mp3');
      print('[AUDIO] In-play theme file loaded successfully');
      
      print('[AUDIO] Starting playback...');
      await FlameAudio.bgm.play('music/Poker_Party_In_Play_Cycle.mp3');
      print('[AUDIO] In-play theme playback started');
      
      // Apply current volume settings
      if (_isMuted) {
        print('[AUDIO] Audio is muted, setting volume to 0');
        await FlameAudio.bgm.audioPlayer.setVolume(0);
      } else {
        print('[AUDIO] Setting volume to $_volume');
        await FlameAudio.bgm.audioPlayer.setVolume(_volume);
      }
      print('[AUDIO] Volume settings applied successfully');
      print('[AUDIO] ===== In-Play Theme Playback Complete =====');
    } catch (e) {
      print('[AUDIO] ERROR: Failed to play in-play theme');
      print('[AUDIO] Error details: $e');
      print('[AUDIO] Stack trace: ${StackTrace.current}');
      if (e is Exception) {
        print('[AUDIO] Exception type: ${e.runtimeType}');
        print('[AUDIO] Exception message: ${e.toString()}');
      }
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
