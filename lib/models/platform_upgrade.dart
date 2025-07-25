enum UpgradeCategory {
  equipment,
  skills,
  audience,
  monetization,
  efficiency,
}

enum UpgradeType {
  // Equipment upgrades
  camera,
  microphone,
  lighting,
  editingSoftware,
  
  // Skill upgrades
  creativity,
  charisma,
  technical,
  marketing,
  
  // Audience upgrades
  engagement,
  reach,
  retention,
  demographics,
  
  // Monetization upgrades
  sponsorships,
  merchandise,
  donations,
  adRevenue,
  
  // Efficiency upgrades
  speed,
  energy,
  automation,
  batch,
}

class PlatformUpgrade {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final UpgradeCategory category;
  final UpgradeType type;
  final String platformId;
  final int baseCost;
  final int maxLevel;
  final double effectPerLevel;
  final List<String> prerequisites;
  
  int currentLevel;
  bool isUnlocked;
  
  PlatformUpgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.category,
    required this.type,
    required this.platformId,
    required this.baseCost,
    required this.maxLevel,
    required this.effectPerLevel,
    this.prerequisites = const [],
    this.currentLevel = 0,
    this.isUnlocked = false,
  });
  
  int get nextLevelCost {
    if (currentLevel >= maxLevel) return 0;
    return (baseCost * (1.5 * (currentLevel + 1))).round();
  }
  
  bool get isMaxLevel => currentLevel >= maxLevel;
  
  double get currentEffect => currentLevel * effectPerLevel;
  
  double get nextLevelEffect => (currentLevel + 1) * effectPerLevel;
  
  bool canUpgrade(Map<String, PlatformUpgrade> allUpgrades) {
    if (isMaxLevel || !isUnlocked) return false;
    
    // Check prerequisites
    for (String prereqId in prerequisites) {
      final prereq = allUpgrades[prereqId];
      if (prereq == null || prereq.currentLevel == 0) {
        return false;
      }
    }
    
    return true;
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'iconPath': iconPath,
    'category': category.index,
    'type': type.index,
    'platformId': platformId,
    'baseCost': baseCost,
    'maxLevel': maxLevel,
    'effectPerLevel': effectPerLevel,
    'prerequisites': prerequisites,
    'currentLevel': currentLevel,
    'isUnlocked': isUnlocked,
  };
  
  factory PlatformUpgrade.fromJson(Map<String, dynamic> json) => PlatformUpgrade(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    iconPath: json['iconPath'] ?? '',
    category: UpgradeCategory.values[json['category'] ?? 0],
    type: UpgradeType.values[json['type'] ?? 0],
    platformId: json['platformId'] ?? '',
    baseCost: json['baseCost'] ?? 0,
    maxLevel: json['maxLevel'] ?? 1,
    effectPerLevel: json['effectPerLevel']?.toDouble() ?? 0.0,
    prerequisites: List<String>.from(json['prerequisites'] ?? []),
    currentLevel: json['currentLevel'] ?? 0,
    isUnlocked: json['isUnlocked'] ?? false,
  );
}

class InfluencerMastery {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final int requiredPlatformLevels;
  final Map<UpgradeType, int> typeRequirements;
  final double globalBonus;
  
  bool isUnlocked;
  int currentLevel;
  final int maxLevel;
  
  InfluencerMastery({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.requiredPlatformLevels,
    required this.typeRequirements,
    required this.globalBonus,
    required this.maxLevel,
    this.isUnlocked = false,
    this.currentLevel = 0,
  });
  
  bool canUnlock(Map<String, List<PlatformUpgrade>> platformUpgrades) {
    if (isUnlocked) return false;
    
    int totalLevels = 0;
    Map<UpgradeType, int> typeCounts = {};
    
    // Count all upgrade levels across platforms
    for (var upgrades in platformUpgrades.values) {
      for (var upgrade in upgrades) {
        totalLevels += upgrade.currentLevel;
        typeCounts[upgrade.type] = (typeCounts[upgrade.type] ?? 0) + upgrade.currentLevel;
      }
    }
    
    // Check total level requirement
    if (totalLevels < requiredPlatformLevels) return false;
    
    // Check type-specific requirements
    for (var entry in typeRequirements.entries) {
      if ((typeCounts[entry.key] ?? 0) < entry.value) {
        return false;
      }
    }
    
    return true;
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'iconPath': iconPath,
    'requiredPlatformLevels': requiredPlatformLevels,
    'typeRequirements': typeRequirements.map((k, v) => MapEntry(k.index.toString(), v)),
    'globalBonus': globalBonus,
    'maxLevel': maxLevel,
    'isUnlocked': isUnlocked,
    'currentLevel': currentLevel,
  };
  
  factory InfluencerMastery.fromJson(Map<String, dynamic> json) => InfluencerMastery(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    iconPath: json['iconPath'] ?? '',
    requiredPlatformLevels: json['requiredPlatformLevels'] ?? 0,
    typeRequirements: (json['typeRequirements'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(UpgradeType.values[int.parse(k)], v as int)),
    globalBonus: json['globalBonus']?.toDouble() ?? 0.0,
    maxLevel: json['maxLevel'] ?? 1,
    isUnlocked: json['isUnlocked'] ?? false,
    currentLevel: json['currentLevel'] ?? 0,
  );
}