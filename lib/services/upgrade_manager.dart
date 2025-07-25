import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/platform_upgrade.dart';
import 'game_manager.dart';

class UpgradeManager extends ChangeNotifier {
  static UpgradeManager? _instance;
  static UpgradeManager get instance => _instance ??= UpgradeManager._();
  
  UpgradeManager._();
  
  Map<String, List<PlatformUpgrade>> _platformUpgrades = {};
  List<InfluencerMastery> _masteries = [];
  
  Map<String, List<PlatformUpgrade>> get platformUpgrades => _platformUpgrades;
  List<InfluencerMastery> get masteries => _masteries;
  
  Future<void> initialize() async {
    await _loadUpgradeData();
    if (_platformUpgrades.isEmpty) {
      _createDefaultUpgrades();
      await _saveUpgradeData();
    }
    _checkMasteryUnlocks();
  }
  
  void _createDefaultUpgrades() {
    _platformUpgrades = {
      'TipPot': _createTipPotUpgrades(),
      'TheGram': _createTheGramUpgrades(),
      'Yutub': _createYutubUpgrades(),
    };
    
    _masteries = _createInfluencerMasteries();
    
    // Unlock first tier upgrades
    for (var platformUpgrades in _platformUpgrades.values) {
      for (var upgrade in platformUpgrades) {
        if (upgrade.prerequisites.isEmpty) {
          upgrade.isUnlocked = true;
        }
      }
    }
  }
  
  List<PlatformUpgrade> _createTipPotUpgrades() {
    return [
      // Equipment Path
      PlatformUpgrade(
        id: 'tippot_phone_camera',
        name: 'Phone Camera Pro',
        description: 'Better video quality for dance videos',
        iconPath: 'assets/icons/phone_camera.png',
        category: UpgradeCategory.equipment,
        type: UpgradeType.camera,
        platformId: 'TipPot',
        baseCost: 100,
        maxLevel: 5,
        effectPerLevel: 0.15, // 15% more followers per level
        isUnlocked: true,
      ),
      PlatformUpgrade(
        id: 'tippot_ring_light',
        name: 'Ring Light Setup',
        description: 'Professional lighting for better content',
        iconPath: 'assets/icons/ring_light.png',
        category: UpgradeCategory.equipment,
        type: UpgradeType.lighting,
        platformId: 'TipPot',
        baseCost: 200,
        maxLevel: 3,
        effectPerLevel: 0.20,
        prerequisites: ['tippot_phone_camera'],
      ),
      PlatformUpgrade(
        id: 'tippot_editing_app',
        name: 'Pro Editing App',
        description: 'Advanced editing for viral content',
        iconPath: 'assets/icons/editing_app.png',
        category: UpgradeCategory.equipment,
        type: UpgradeType.editingSoftware,
        platformId: 'TipPot',
        baseCost: 150,
        maxLevel: 4,
        effectPerLevel: 0.25,
        prerequisites: ['tippot_phone_camera'],
      ),
      
      // Skills Path
      PlatformUpgrade(
        id: 'tippot_dance_skills',
        name: 'Dance Training',
        description: 'Learn trending dance moves faster',
        iconPath: 'assets/icons/dance_skills.png',
        category: UpgradeCategory.skills,
        type: UpgradeType.creativity,
        platformId: 'TipPot',
        baseCost: 80,
        maxLevel: 10,
        effectPerLevel: 0.10,
        isUnlocked: true,
      ),
      PlatformUpgrade(
        id: 'tippot_trend_analysis',
        name: 'Trend Spotter',
        description: 'Identify viral trends before they peak',
        iconPath: 'assets/icons/trend_analysis.png',
        category: UpgradeCategory.skills,
        type: UpgradeType.marketing,
        platformId: 'TipPot',
        baseCost: 300,
        maxLevel: 5,
        effectPerLevel: 0.30,
        prerequisites: ['tippot_dance_skills'],
      ),
      
      // Audience Path
      PlatformUpgrade(
        id: 'tippot_hashtag_master',
        name: 'Hashtag Mastery',
        description: 'Better hashtag strategy for reach',
        iconPath: 'assets/icons/hashtag.png',
        category: UpgradeCategory.audience,
        type: UpgradeType.reach,
        platformId: 'TipPot',
        baseCost: 120,
        maxLevel: 7,
        effectPerLevel: 0.12,
        isUnlocked: true,
      ),
      PlatformUpgrade(
        id: 'tippot_community_building',
        name: 'Community Builder',
        description: 'Build loyal fanbase with better engagement',
        iconPath: 'assets/icons/community.png',
        category: UpgradeCategory.audience,
        type: UpgradeType.engagement,
        platformId: 'TipPot',
        baseCost: 250,
        maxLevel: 5,
        effectPerLevel: 0.18,
        prerequisites: ['tippot_hashtag_master'],
      ),
      
      // Efficiency Path
      PlatformUpgrade(
        id: 'tippot_quick_edit',
        name: 'Quick Edit Techniques',
        description: 'Reduce video creation time',
        iconPath: 'assets/icons/quick_edit.png',
        category: UpgradeCategory.efficiency,
        type: UpgradeType.speed,
        platformId: 'TipPot',
        baseCost: 180,
        maxLevel: 5,
        effectPerLevel: 0.15, // 15% faster creation
        prerequisites: ['tippot_editing_app'],
      ),
    ];
  }
  
  List<PlatformUpgrade> _createTheGramUpgrades() {
    return [
      // Equipment Path
      PlatformUpgrade(
        id: 'thegram_dslr_camera',
        name: 'DSLR Camera',
        description: 'Professional photos that stand out',
        iconPath: 'assets/icons/dslr_camera.png',
        category: UpgradeCategory.equipment,
        type: UpgradeType.camera,
        platformId: 'TheGram',
        baseCost: 300,
        maxLevel: 5,
        effectPerLevel: 0.20,
        isUnlocked: true,
      ),
      PlatformUpgrade(
        id: 'thegram_studio_lighting',
        name: 'Studio Lighting Kit',
        description: 'Perfect lighting for every shot',
        iconPath: 'assets/icons/studio_lighting.png',
        category: UpgradeCategory.equipment,
        type: UpgradeType.lighting,
        platformId: 'TheGram',
        baseCost: 400,
        maxLevel: 4,
        effectPerLevel: 0.25,
        prerequisites: ['thegram_dslr_camera'],
      ),
      PlatformUpgrade(
        id: 'thegram_photoshop',
        name: 'Photo Editing Suite',
        description: 'Professional photo editing tools',
        iconPath: 'assets/icons/photoshop.png',
        category: UpgradeCategory.equipment,
        type: UpgradeType.editingSoftware,
        platformId: 'TheGram',
        baseCost: 250,
        maxLevel: 6,
        effectPerLevel: 0.18,
        prerequisites: ['thegram_dslr_camera'],
      ),
      
      // Skills Path
      PlatformUpgrade(
        id: 'thegram_photography',
        name: 'Photography Course',
        description: 'Master composition and aesthetics',
        iconPath: 'assets/icons/photography.png',
        category: UpgradeCategory.skills,
        type: UpgradeType.creativity,
        platformId: 'TheGram',
        baseCost: 150,
        maxLevel: 8,
        effectPerLevel: 0.12,
        isUnlocked: true,
      ),
      PlatformUpgrade(
        id: 'thegram_storytelling',
        name: 'Visual Storytelling',
        description: 'Create compelling narratives through images',
        iconPath: 'assets/icons/storytelling.png',
        category: UpgradeCategory.skills,
        type: UpgradeType.charisma,
        platformId: 'TheGram',
        baseCost: 200,
        maxLevel: 6,
        effectPerLevel: 0.15,
        prerequisites: ['thegram_photography'],
      ),
      
      // Audience Path
      PlatformUpgrade(
        id: 'thegram_aesthetic_consistency',
        name: 'Aesthetic Consistency',
        description: 'Maintain cohesive visual brand',
        iconPath: 'assets/icons/aesthetic.png',
        category: UpgradeCategory.audience,
        type: UpgradeType.retention,
        platformId: 'TheGram',
        baseCost: 180,
        maxLevel: 5,
        effectPerLevel: 0.20,
        isUnlocked: true,
      ),
      PlatformUpgrade(
        id: 'thegram_influencer_network',
        name: 'Influencer Network',
        description: 'Connect with other creators for growth',
        iconPath: 'assets/icons/network.png',
        category: UpgradeCategory.audience,
        type: UpgradeType.reach,
        platformId: 'TheGram',
        baseCost: 350,
        maxLevel: 4,
        effectPerLevel: 0.25,
        prerequisites: ['thegram_aesthetic_consistency'],
      ),
      
      // Monetization Path
      PlatformUpgrade(
        id: 'thegram_brand_partnerships',
        name: 'Brand Partnership Skills',
        description: 'Attract and manage brand deals',
        iconPath: 'assets/icons/brand_partnership.png',
        category: UpgradeCategory.monetization,
        type: UpgradeType.sponsorships,
        platformId: 'TheGram',
        baseCost: 500,
        maxLevel: 5,
        effectPerLevel: 0.30,
        prerequisites: ['thegram_influencer_network'],
      ),
    ];
  }
  
  List<PlatformUpgrade> _createYutubUpgrades() {
    return [
      // Equipment Path
      PlatformUpgrade(
        id: 'yutub_4k_camera',
        name: '4K Video Camera',
        description: 'Ultra-high quality video production',
        iconPath: 'assets/icons/4k_camera.png',
        category: UpgradeCategory.equipment,
        type: UpgradeType.camera,
        platformId: 'Yutub',
        baseCost: 800,
        maxLevel: 4,
        effectPerLevel: 0.25,
        isUnlocked: true,
      ),
      PlatformUpgrade(
        id: 'yutub_professional_mic',
        name: 'Professional Microphone',
        description: 'Crystal clear audio quality',
        iconPath: 'assets/icons/professional_mic.png',
        category: UpgradeCategory.equipment,
        type: UpgradeType.microphone,
        platformId: 'Yutub',
        baseCost: 300,
        maxLevel: 5,
        effectPerLevel: 0.20,
        isUnlocked: true,
      ),
      PlatformUpgrade(
        id: 'yutub_editing_suite',
        name: 'Video Editing Suite',
        description: 'Professional video editing software',
        iconPath: 'assets/icons/video_editing.png',
        category: UpgradeCategory.equipment,
        type: UpgradeType.editingSoftware,
        platformId: 'Yutub',
        baseCost: 600,
        maxLevel: 6,
        effectPerLevel: 0.18,
        prerequisites: ['yutub_4k_camera'],
      ),
      
      // Skills Path
      PlatformUpgrade(
        id: 'yutub_presentation',
        name: 'Presentation Skills',
        description: 'Engage viewers with confident delivery',
        iconPath: 'assets/icons/presentation.png',
        category: UpgradeCategory.skills,
        type: UpgradeType.charisma,
        platformId: 'Yutub',
        baseCost: 200,
        maxLevel: 10,
        effectPerLevel: 0.10,
        isUnlocked: true,
      ),
      PlatformUpgrade(
        id: 'yutub_research_skills',
        name: 'Content Research',
        description: 'Create well-researched, valuable content',
        iconPath: 'assets/icons/research.png',
        category: UpgradeCategory.skills,
        type: UpgradeType.technical,
        platformId: 'Yutub',
        baseCost: 250,
        maxLevel: 7,
        effectPerLevel: 0.15,
        prerequisites: ['yutub_presentation'],
      ),
      
      // Audience Path
      PlatformUpgrade(
        id: 'yutub_seo_optimization',
        name: 'SEO Optimization',
        description: 'Optimize videos for search discovery',
        iconPath: 'assets/icons/seo.png',
        category: UpgradeCategory.audience,
        type: UpgradeType.reach,
        platformId: 'Yutub',
        baseCost: 300,
        maxLevel: 6,
        effectPerLevel: 0.18,
        isUnlocked: true,
      ),
      PlatformUpgrade(
        id: 'yutub_community_management',
        name: 'Community Management',
        description: 'Build and maintain engaged subscriber base',
        iconPath: 'assets/icons/community_mgmt.png',
        category: UpgradeCategory.audience,
        type: UpgradeType.engagement,
        platformId: 'Yutub',
        baseCost: 400,
        maxLevel: 5,
        effectPerLevel: 0.22,
        prerequisites: ['yutub_seo_optimization'],
      ),
      
      // Monetization Path
      PlatformUpgrade(
        id: 'yutub_ad_revenue',
        name: 'Ad Revenue Optimization',
        description: 'Maximize earnings from video ads',
        iconPath: 'assets/icons/ad_revenue.png',
        category: UpgradeCategory.monetization,
        type: UpgradeType.adRevenue,
        platformId: 'Yutub',
        baseCost: 500,
        maxLevel: 5,
        effectPerLevel: 0.25,
        prerequisites: ['yutub_community_management'],
      ),
      PlatformUpgrade(
        id: 'yutub_merchandise',
        name: 'Merchandise Strategy',
        description: 'Create and sell branded merchandise',
        iconPath: 'assets/icons/merchandise.png',
        category: UpgradeCategory.monetization,
        type: UpgradeType.merchandise,
        platformId: 'Yutub',
        baseCost: 700,
        maxLevel: 4,
        effectPerLevel: 0.30,
        prerequisites: ['yutub_ad_revenue'],
      ),
      
      // Efficiency Path
      PlatformUpgrade(
        id: 'yutub_batch_recording',
        name: 'Batch Recording',
        description: 'Record multiple videos efficiently',
        iconPath: 'assets/icons/batch_recording.png',
        category: UpgradeCategory.efficiency,
        type: UpgradeType.batch,
        platformId: 'Yutub',
        baseCost: 400,
        maxLevel: 5,
        effectPerLevel: 0.20,
        prerequisites: ['yutub_editing_suite'],
      ),
    ];
  }
  
  List<InfluencerMastery> _createInfluencerMasteries() {
    return [
      InfluencerMastery(
        id: 'content_creator',
        name: 'Content Creator',
        description: 'Master of creative content across platforms',
        iconPath: 'assets/icons/content_creator.png',
        requiredPlatformLevels: 10,
        typeRequirements: {
          UpgradeType.creativity: 5,
          UpgradeType.camera: 3,
        },
        globalBonus: 0.15, // 15% bonus to all content creation
        maxLevel: 5,
      ),
      InfluencerMastery(
        id: 'viral_expert',
        name: 'Viral Expert',
        description: 'Understands what makes content go viral',
        iconPath: 'assets/icons/viral_expert.png',
        requiredPlatformLevels: 20,
        typeRequirements: {
          UpgradeType.marketing: 8,
          UpgradeType.reach: 6,
        },
        globalBonus: 0.25, // 25% bonus to follower gain
        maxLevel: 3,
      ),
      InfluencerMastery(
        id: 'business_mogul',
        name: 'Business Mogul',
        description: 'Monetization master across all platforms',
        iconPath: 'assets/icons/business_mogul.png',
        requiredPlatformLevels: 35,
        typeRequirements: {
          UpgradeType.sponsorships: 5,
          UpgradeType.adRevenue: 3,
          UpgradeType.merchandise: 2,
        },
        globalBonus: 0.40, // 40% bonus to money gain
        maxLevel: 3,
      ),
      InfluencerMastery(
        id: 'efficiency_master',
        name: 'Efficiency Master',
        description: 'Optimized workflow across all platforms',
        iconPath: 'assets/icons/efficiency_master.png',
        requiredPlatformLevels: 25,
        typeRequirements: {
          UpgradeType.speed: 8,
          UpgradeType.batch: 4,
          UpgradeType.automation: 3,
        },
        globalBonus: 0.30, // 30% faster content creation
        maxLevel: 4,
      ),
      InfluencerMastery(
        id: 'social_media_legend',
        name: 'Social Media Legend',
        description: 'The ultimate influencer across all platforms',
        iconPath: 'assets/icons/legend.png',
        requiredPlatformLevels: 100,
        typeRequirements: {
          UpgradeType.creativity: 15,
          UpgradeType.charisma: 15,
          UpgradeType.marketing: 15,
          UpgradeType.sponsorships: 10,
        },
        globalBonus: 1.0, // 100% bonus to everything!
        maxLevel: 1,
      ),
    ];
  }
  
  Future<bool> purchaseUpgrade(String upgradeId, String platformId, GameManager gameManager) async {
    final upgrades = _platformUpgrades[platformId];
    if (upgrades == null) return false;
    
    final upgrade = upgrades.firstWhere(
      (u) => u.id == upgradeId,
      orElse: () => throw Exception('Upgrade not found'),
    );
    
    if (!upgrade.canUpgrade(_getAllUpgradesMap()) || !gameManager.canAfford(upgrade.nextLevelCost)) {
      return false;
    }
    
    // Purchase upgrade
    gameManager.spendMoney(upgrade.nextLevelCost);
    upgrade.currentLevel++;
    
    // Unlock dependent upgrades
    _unlockDependentUpgrades(upgradeId, platformId);
    
    // Check for mastery unlocks
    _checkMasteryUnlocks();
    
    await _saveUpgradeData();
    notifyListeners();
    
    return true;
  }
  
  void _unlockDependentUpgrades(String upgradeId, String platformId) {
    final upgrades = _platformUpgrades[platformId];
    if (upgrades == null) return;
    
    for (var upgrade in upgrades) {
      if (upgrade.prerequisites.contains(upgradeId) && !upgrade.isUnlocked) {
        // Check if all prerequisites are met
        bool canUnlock = true;
        for (String prereqId in upgrade.prerequisites) {
          final prereq = upgrades.firstWhere((u) => u.id == prereqId);
          if (prereq.currentLevel == 0) {
            canUnlock = false;
            break;
          }
        }
        if (canUnlock) {
          upgrade.isUnlocked = true;
        }
      }
    }
  }
  
  void _checkMasteryUnlocks() {
    for (var mastery in _masteries) {
      if (mastery.canUnlock(_platformUpgrades)) {
        mastery.isUnlocked = true;
      }
    }
  }
  
  Map<String, PlatformUpgrade> _getAllUpgradesMap() {
    Map<String, PlatformUpgrade> allUpgrades = {};
    for (var upgrades in _platformUpgrades.values) {
      for (var upgrade in upgrades) {
        allUpgrades[upgrade.id] = upgrade;
      }
    }
    return allUpgrades;
  }
  
  double getFollowerMultiplier(String platformId) {
    double multiplier = 1.0;
    final upgrades = _platformUpgrades[platformId] ?? [];
    
    for (var upgrade in upgrades) {
      if (upgrade.type == UpgradeType.creativity || 
          upgrade.type == UpgradeType.reach ||
          upgrade.type == UpgradeType.engagement) {
        multiplier += upgrade.currentEffect;
      }
    }
    
    // Add mastery bonuses
    for (var mastery in _masteries) {
      if (mastery.isUnlocked) {
        multiplier += mastery.globalBonus * mastery.currentLevel;
      }
    }
    
    return multiplier;
  }
  
  double getMoneyMultiplier(String platformId) {
    double multiplier = 1.0;
    final upgrades = _platformUpgrades[platformId] ?? [];
    
    for (var upgrade in upgrades) {
      if (upgrade.type == UpgradeType.sponsorships || 
          upgrade.type == UpgradeType.adRevenue ||
          upgrade.type == UpgradeType.merchandise) {
        multiplier += upgrade.currentEffect;
      }
    }
    
    // Add mastery bonuses
    for (var mastery in _masteries) {
      if (mastery.isUnlocked && mastery.id == 'business_mogul') {
        multiplier += mastery.globalBonus * mastery.currentLevel;
      }
    }
    
    return multiplier;
  }
  
  double getSpeedMultiplier(String platformId) {
    double multiplier = 1.0;
    final upgrades = _platformUpgrades[platformId] ?? [];
    
    for (var upgrade in upgrades) {
      if (upgrade.type == UpgradeType.speed || 
          upgrade.type == UpgradeType.batch ||
          upgrade.type == UpgradeType.automation) {
        multiplier -= upgrade.currentEffect; // Speed reduces time
      }
    }
    
    // Add mastery bonuses
    for (var mastery in _masteries) {
      if (mastery.isUnlocked && mastery.id == 'efficiency_master') {
        multiplier -= mastery.globalBonus * mastery.currentLevel;
      }
    }
    
    return multiplier.clamp(0.1, 1.0); // Never go below 10% of original time
  }
  
  Future<void> _saveUpgradeData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final upgradeData = {
      'platformUpgrades': _platformUpgrades.map((k, v) => 
          MapEntry(k, v.map((u) => u.toJson()).toList())),
      'masteries': _masteries.map((m) => m.toJson()).toList(),
    };
    
    await prefs.setString('upgrade_data', jsonEncode(upgradeData));
  }
  
  Future<void> _loadUpgradeData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('upgrade_data');
    
    if (jsonString != null) {
      try {
        final data = jsonDecode(jsonString);
        
        _platformUpgrades = (data['platformUpgrades'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as List)
                .map((u) => PlatformUpgrade.fromJson(u))
                .toList()));
        
        _masteries = (data['masteries'] as List)
            .map((m) => InfluencerMastery.fromJson(m))
            .toList();
      } catch (e) {
        debugPrint('Error loading upgrade data: $e');
        _platformUpgrades = {};
        _masteries = [];
      }
    }
  }
}