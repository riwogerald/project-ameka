import 'package:flutter/foundation.dart';
import '../models/game_data.dart';
import '../services/shop_manager.dart';
import '../services/upgrade_manager.dart';
import 'game_manager.dart';

class EconomyManager {
  static EconomyManager? _instance;
  static EconomyManager get instance => _instance ??= EconomyManager._();
  
  EconomyManager._();
  
  void completeContent(ContentType content, GameManager gameManager, String platformId) {
    final influencer = gameManager.currentInfluencer;
    
    // Calculate base rewards
    int followerGain = calculateFollowerGain(content, influencer.followers);
    int moneyGain = calculateMoneyGain(content, influencer.followers);
    
    // Apply shop multipliers
    followerGain = (followerGain * ShopManager.instance.getFollowerMultiplier()).round();
    moneyGain = (moneyGain * ShopManager.instance.getMoneyMultiplier()).round();
    
    // Apply platform-specific upgrade multipliers
    followerGain = (followerGain * UpgradeManager.instance.getFollowerMultiplier(platformId)).round();
    moneyGain = (moneyGain * UpgradeManager.instance.getMoneyMultiplier(platformId)).round();
    
    // Add rewards
    gameManager.addFollowers(followerGain);
    gameManager.addMoney(moneyGain);
    
    debugPrint('Content completed: ${content.name} on $platformId');
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
  
  int calculateContentDuration(ContentType content, String platformId) {
    // Apply speed multipliers from shop items and platform upgrades
    double speedMultiplier = ShopManager.instance.getSpeedMultiplier();
    speedMultiplier *= UpgradeManager.instance.getSpeedMultiplier(platformId);
    
    return (content.baseTime * 60 * speedMultiplier).round(); // Convert to seconds
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
  
  Map<String, dynamic> getProgressionStats(GameManager gameManager) {
    final influencer = gameManager.currentInfluencer;
    final milestones = getFollowerMilestones();
    
    // Find next milestone
    int nextMilestone = milestones.firstWhere(
      (milestone) => milestone > influencer.followers,
      orElse: () => milestones.last,
    );
    
    // Calculate progress to next milestone
    int previousMilestone = 0;
    for (int milestone in milestones) {
      if (milestone <= influencer.followers) {
        previousMilestone = milestone;
      } else {
        break;
      }
    }
    
    double progress = previousMilestone == nextMilestone 
        ? 1.0 
        : (influencer.followers - previousMilestone) / (nextMilestone - previousMilestone);
    
    return {
      'currentTier': getInfluencerTier(influencer.followers),
      'nextMilestone': nextMilestone,
      'progress': progress,
      'followersToNext': nextMilestone - influencer.followers,
    };
  }
}