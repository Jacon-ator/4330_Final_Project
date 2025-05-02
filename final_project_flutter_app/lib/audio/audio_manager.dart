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
  Timer? _themeTransitionTimer;
  final List<String> _inPlayThemes = [
    'music/Poker_Party_In_Play_Theme_1.ogg',
    'music/Poker_Party_In_Play_Theme_2.ogg',
    'music/Poker_Party_In_Play_Theme_3.ogg',
  ];
  int _currentThemeIndex = 0;

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
      print('Loading main theme...');
      await FlameAudio.audioCache.load('music/Poker_Party_Main_Theme.mp3');
      print('Loading shop theme...');
      await FlameAudio.audioCache.load('music/Poker_Party_Shop_Theme.ogg');
      print('Loading in-play themes...');
      for (final theme in _inPlayThemes) {
        print('Loading $theme...');
        await FlameAudio.audioCache.load(theme);
      }
      print('Audio files loaded successfully');
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
    if (!_isInitialized) {
      print('Audio not initialized, initializing now...');
      await initialize();
    }

    try {
      print('Starting in-play theme sequence...');
      // Cancel any existing transition timer
      _themeTransitionTimer?.cancel();
      print('Previous transition timer cancelled');
      
      // Play the current theme
      print('Attempting to play theme: ${_inPlayThemes[_currentThemeIndex]}');
      await FlameAudio.bgm.play(_inPlayThemes[_currentThemeIndex]);
      print('In-play theme playback started successfully');
      
      // Apply current volume settings
      if (_isMuted) {
        print('Audio is muted, setting volume to 0');
        await FlameAudio.bgm.audioPlayer.setVolume(0);
      } else {
        print('Setting volume to $_volume');
        await FlameAudio.bgm.audioPlayer.setVolume(_volume);
      }

      // Set up the transition timer
      print('Setting up theme transition timer (2 minutes)');
      _themeTransitionTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
        print('Theme transition timer triggered');
        _transitionToNextTheme();
      });
    } catch (e) {
      print('Error playing in-play theme: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _transitionToNextTheme() async {
    try {
      print('Starting theme transition...');
      // Stop current theme
      await FlameAudio.bgm.stop();
      print('Current theme stopped');
      
      // Select a new random theme (different from current)
      int newIndex;
      do {
        newIndex = DateTime.now().millisecondsSinceEpoch % _inPlayThemes.length;
      } while (newIndex == _currentThemeIndex);
      
      _currentThemeIndex = newIndex;
      print('Selected new theme index: $_currentThemeIndex');
      
      // Play the new theme
      print('Attempting to play new theme: ${_inPlayThemes[_currentThemeIndex]}');
      await FlameAudio.bgm.play(_inPlayThemes[_currentThemeIndex]);
      print('New theme playback started');
      
      // Apply current volume settings
      if (_isMuted) {
        await FlameAudio.bgm.audioPlayer.setVolume(0);
      } else {
        await FlameAudio.bgm.audioPlayer.setVolume(_volume);
      }
    } catch (e) {
      print('Error transitioning themes: $e');
      print('Stack trace: ${StackTrace.current}');
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
      _themeTransitionTimer?.cancel();
      _themeTransitionTimer = null;
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
