import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static AudioManager? _instance;
  static AudioManager get instance => _instance ??= AudioManager._();
  
  AudioManager._();
  
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _musicEnabled = prefs.getBool('music_enabled') ?? true;
  }
  
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);
  }
  
  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', enabled);
  }
  
  void playSound(SoundEffect effect) {
    if (!_soundEnabled) return;
    
    // Use system sounds for now (can be replaced with actual audio files)
    switch (effect) {
      case SoundEffect.buttonClick:
        HapticFeedback.lightImpact();
        break;
      case SoundEffect.contentComplete:
        HapticFeedback.mediumImpact();
        break;
      case SoundEffect.moneyEarn:
        HapticFeedback.heavyImpact();
        break;
      case SoundEffect.levelUp:
        HapticFeedback.heavyImpact();
        break;
    }
  }
}

enum SoundEffect {
  buttonClick,
  contentComplete,
  moneyEarn,
  levelUp,
}