import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/game_data.dart';
import '../services/timer_manager.dart';
import '../services/economy_manager.dart';
import 'save_system.dart';

class GameManager extends ChangeNotifier {
  InfluencerData _currentInfluencer = InfluencerData();
  bool _isLoading = true;
  Timer? _energyRegenTimer;
  Timer? _autoSaveTimer;
  
  InfluencerData get currentInfluencer => _currentInfluencer;
  bool get isLoading => _isLoading;
  
  GameManager() {
    _loadGame();
    _startEnergyRegeneration();
    _startAutoSave();
    
    // Listen to timer completions
    TimerManager.instance.addListener(_onTimerUpdate);
  }
  
  @override
  void dispose() {
    _energyRegenTimer?.cancel();
    _autoSaveTimer?.cancel();
    TimerManager.instance.removeListener(_onTimerUpdate);
    super.dispose();
  }
  
  void _onTimerUpdate() {
    // Check for completed timers and award rewards
    final completedTimers = TimerManager.instance.activeTimers
        .where((timer) => !timer.isActive && timer.remainingTime <= 0)
        .toList();
    
    for (var timer in completedTimers) {
      EconomyManager.instance.completeContent(timer.contentType, this);
    }
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
  
  void _startEnergyRegeneration() {
    _energyRegenTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      regenerateEnergy();
    });
  }
  
  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      saveGame();
    });
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
  }
  
  void addMoney(int amount) {
    _currentInfluencer.money += amount;
    notifyListeners();
  }
  
  void consumeEnergy(int amount) {
    _currentInfluencer.energy = 
        (_currentInfluencer.energy - amount).clamp(0, _currentInfluencer.maxEnergy);
    notifyListeners();
  }
  
  void regenerateEnergy() {
    if (_currentInfluencer.energy < _currentInfluencer.maxEnergy) {
      _currentInfluencer.energy = 
          (_currentInfluencer.energy + 2).clamp(0, _currentInfluencer.maxEnergy);
      notifyListeners();
    }
  }
  
  void restoreEnergy(int amount) {
    _currentInfluencer.energy = 
        (_currentInfluencer.energy + amount).clamp(0, _currentInfluencer.maxEnergy);
    notifyListeners();
  }
  
  void _checkPlatformUnlocks() {
    bool hasUnlocked = false;
    for (var platform in _currentInfluencer.unlockedPlatforms) {
      if (!platform.isUnlocked && 
          _currentInfluencer.followers >= platform.unlockFollowerRequirement) {
        platform.isUnlocked = true;
        hasUnlocked = true;
        
        // Show unlock notification
        debugPrint('Platform unlocked: ${platform.name}');
      }
    }
    if (hasUnlocked) {
      saveGame();
    }
  }
  
  bool canCreateContent(ContentType content) {
    return _currentInfluencer.energy >= content.energyCost;
  }
  
  void spendMoney(int amount) {
    _currentInfluencer.money = (_currentInfluencer.money - amount).clamp(0, _currentInfluencer.money);
    notifyListeners();
  }
  
  bool canAfford(int cost) {
    return _currentInfluencer.money >= cost;
  }
}