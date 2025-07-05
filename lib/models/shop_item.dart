enum ShopItemType {
  energyBoost,
  followerMultiplier,
  moneyMultiplier,
  platformUnlock,
  maxEnergyIncrease,
  contentSpeedBoost,
}

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int cost;
  final String iconPath;
  final ShopItemType type;
  final int effectValue;
  final int duration; // in minutes, 0 for permanent
  bool isPurchased;
  DateTime? purchaseTime;
  
  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.iconPath,
    required this.type,
    required this.effectValue,
    this.duration = 0,
    this.isPurchased = false,
    this.purchaseTime,
  });
  
  bool get isActive {
    if (!isPurchased) return false;
    if (duration == 0) return true; // Permanent
    if (purchaseTime == null) return false;
    
    return DateTime.now().difference(purchaseTime!).inMinutes < duration;
  }
  
  int get remainingTime {
    if (duration == 0 || purchaseTime == null) return 0;
    final elapsed = DateTime.now().difference(purchaseTime!).inMinutes;
    return (duration - elapsed).clamp(0, duration);
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'cost': cost,
    'iconPath': iconPath,
    'type': type.index,
    'effectValue': effectValue,
    'duration': duration,
    'isPurchased': isPurchased,
    'purchaseTime': purchaseTime?.millisecondsSinceEpoch,
  };
  
  factory ShopItem.fromJson(Map<String, dynamic> json) => ShopItem(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    cost: json['cost'] ?? 0,
    iconPath: json['iconPath'] ?? '',
    type: ShopItemType.values[json['type'] ?? 0],
    effectValue: json['effectValue'] ?? 0,
    duration: json['duration'] ?? 0,
    isPurchased: json['isPurchased'] ?? false,
    purchaseTime: json['purchaseTime'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(json['purchaseTime'])
        : null,
  );
}