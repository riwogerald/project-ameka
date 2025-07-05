import 'package:flutter/foundation.dart';
import '../models/game_data.dart';
import 'save_system.dart';

class GameManager extends ChangeNotifier {
  InfluencerData _currentInfluencer = InfluencerData();
  bool _isLoading = true;
  
  InfluencerData get currentInfluencer => _currentInfluencer;
  bool get isLoading => _isLoading;
  
  GameManager() {
    _loadGame();
  }
  
  Future<void> _loadGame() async {
    try {
      _currentInfluencer = await SaveSystem.loadGame();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading game: $e');
      _currentInfluencer = InfluencerData();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> saveGame() async {
    try {
      await SaveSystem.saveGame(_currentInfluencer);
    } catch (e) {
      debugPrint('Error saving game: $e');
    }
  }
  
  void addFollowers(int amount) {
    _currentInfluencer.followers += amount;
    _checkPlatformUnlocks();
    notifyListeners();
    saveGame();
  }
  
  void addMoney(int amount) {
    _currentInfluencer.money += amount;
    notifyListeners();
    saveGame();
  }
  
  void consumeEnergy(int amount) {
    _currentInfluencer.energy = 
        (_currentInfluencer.energy - amount).clamp(0, _currentInfluencer.maxEnergy);
    notifyListeners();
    saveGame();
  }
  
  void regenerateEnergy() {
    if (_currentInfluencer.energy < _currentInfluencer.maxEnergy) {
      _currentInfluencer.energy = 
          (_currentInfluencer.energy + 1).clamp(0, _currentInfluencer.maxEnergy);
      notifyListeners();
      saveGame();
    }
  }
  
  void _checkPlatformUnlocks() {
    bool hasUnlocked = false;
    for (var platform in _currentInfluencer.unlockedPlatforms) {
      if (!platform.isUnlocked && 
          _currentInfluencer.followers >= platform.unlockFollowerRequirement) {
        platform.isUnlocked = true;
        hasUnlocked = true;
      }
    }
    if (hasUnlocked) {
      // Could show unlock notification here
      saveGame();
    }
  }
  
  bool canCreateContent(ContentType content) {
    return _currentInfluencer.energy >= content.energyCost;
  }
}