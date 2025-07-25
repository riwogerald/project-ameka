enum EquipmentCategory {
  camera,
  audio,
  lighting,
  editing,
  streaming,
  accessories,
}

enum EquipmentTier {
  basic,
  professional,
  premium,
  legendary,
}

class Equipment {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final EquipmentCategory category;
  final EquipmentTier tier;
  final int cost;
  final Map<String, double> platformBonuses; // Platform-specific bonuses
  final Map<String, double> globalBonuses; // Global bonuses
  final List<String> prerequisites;
  
  bool isOwned;
  bool isEquipped;
  
  Equipment({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.category,
    required this.tier,
    required this.cost,
    required this.platformBonuses,
    required this.globalBonuses,
    this.prerequisites = const [],
    this.isOwned = false,
    this.isEquipped = false,
  });
  
  Color get tierColor {
    switch (tier) {
      case EquipmentTier.basic:
        return Colors.grey;
      case EquipmentTier.professional:
        return Colors.blue;
      case EquipmentTier.premium:
        return Colors.purple;
      case EquipmentTier.legendary:
        return Colors.orange;
    }
  }
  
  String get tierName {
    switch (tier) {
      case EquipmentTier.basic:
        return 'Basic';
      case EquipmentTier.professional:
        return 'Professional';
      case EquipmentTier.premium:
        return 'Premium';
      case EquipmentTier.legendary:
        return 'Legendary';
    }
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'iconPath': iconPath,
    'category': category.index,
    'tier': tier.index,
    'cost': cost,
    'platformBonuses': platformBonuses,
    'globalBonuses': globalBonuses,
    'prerequisites': prerequisites,
    'isOwned': isOwned,
    'isEquipped': isEquipped,
  };
  
  factory Equipment.fromJson(Map<String, dynamic> json) => Equipment(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    iconPath: json['iconPath'] ?? '',
    category: EquipmentCategory.values[json['category'] ?? 0],
    tier: EquipmentTier.values[json['tier'] ?? 0],
    cost: json['cost'] ?? 0,
    platformBonuses: Map<String, double>.from(json['platformBonuses'] ?? {}),
    globalBonuses: Map<String, double>.from(json['globalBonuses'] ?? {}),
    prerequisites: List<String>.from(json['prerequisites'] ?? []),
    isOwned: json['isOwned'] ?? false,
    isEquipped: json['isEquipped'] ?? false,
  );
}

class EquipmentLoadout {
  final String platformId;
  Map<EquipmentCategory, Equipment?> equippedItems;
  
  EquipmentLoadout({
    required this.platformId,
    Map<EquipmentCategory, Equipment?>? equippedItems,
  }) : equippedItems = equippedItems ?? {};
  
  double getTotalBonus(String bonusType) {
    double total = 0.0;
    for (var equipment in equippedItems.values) {
      if (equipment != null) {
        // Platform-specific bonus
        total += equipment.platformBonuses[platformId + '_' + bonusType] ?? 0.0;
        // Global bonus
        total += equipment.globalBonuses[bonusType] ?? 0.0;
      }
    }
    return total;
  }
  
  Map<String, dynamic> toJson() => {
    'platformId': platformId,
    'equippedItems': equippedItems.map((k, v) => 
        MapEntry(k.index.toString(), v?.toJson())),
  };
  
  factory EquipmentLoadout.fromJson(Map<String, dynamic> json) => EquipmentLoadout(
    platformId: json['platformId'] ?? '',
    equippedItems: (json['equippedItems'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(
            EquipmentCategory.values[int.parse(k)],
            v != null ? Equipment.fromJson(v) : null)),
  );
}