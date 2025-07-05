import 'package:flutter/foundation.dart';
import '../models/game_data.dart';
import 'game_manager.dart';

class EconomyManager {
  static EconomyManager? _instance;
  static EconomyManager get instance => _instance ??= EconomyManager._();
  
  EconomyManager._();
  
  void completeContent(ContentType content, GameManager gameManager) {
    final influencer = gameManager.currentInfluencer;
    
    // Calculate rewards based on followers and content type
    int followerGain = calculateFollowerGain(content, influencer.followers);
    int moneyGain = calculateMoneyGain(content, influencer.followers);
    
    // Add rewards
    gameManager.addFollowers(followerGain);
    gameManager.addMoney(moneyGain);
    
    debugPrint('Content completed: ${content.name}');
    debugPrint('Rewards: +$followerGain followers, +\$$moneyGain money');
  }
  
  int calculateFollowerGain(ContentType content, int currentFollowers) {
    // Base gain with scaling based on current followers
    double multiplier = 1.0 + (currentFollowers / 50000.0); // Scales up slowly
    
    // Add some randomness (±20%)
    double randomFactor = 0.8 + (0.4 * (DateTime.now().millisecond / 1000.0));
    
    int gain = (content.baseFollowerGain * multiplier * randomFactor).round();
    return gain.clamp(1, content.baseFollowerGain * 3); // Cap at 3x base
  }
  
  int calculateMoneyGain(ContentType content, int currentFollowers) {
    // Money scales more with followers (sponsorship deals)
    double followerMultiplier = 1.0 + (currentFollowers / 10000.0);
    
    // Add some randomness
    double randomFactor = 0.8 + (0.4 * (DateTime.now().millisecond / 1000.0));
    
    int gain = (content.baseMoneyGain * followerMultiplier * randomFactor).round();
    return gain.clamp(1, content.baseMoneyGain * 5); // Cap at 5x base
  }
  
  bool canAfford(int cost, int currentMoney) {
    return currentMoney >= cost;
  }
  
  List<int> getFollowerMilestones() {
    return [
      500, 1000, 2500, 5000, 10000, 25000, 50000, 
      100000, 250000, 500000, 1000000
    ];
  }
  
  String getInfluencerTier(int followers) {
    if (followers < 1000) return 'Nano Influencer';
    if (followers < 10000) return 'Micro Influencer';
    if (followers < 100000) return 'Mid-tier Influencer';
    if (followers < 1000000) return 'Macro Influencer';
    return 'Mega Influencer';
  }
}