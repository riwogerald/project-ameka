class InfluencerData {
  String influencerName;
  int followers;
  int money;
  int energy;
  int maxEnergy;
  List<Platform> unlockedPlatforms;
  
  InfluencerData({
    this.influencerName = "NewInfluencer",
    this.followers = 100,
    this.money = 50,
    this.energy = 100,
    this.maxEnergy = 100,
    this.unlockedPlatforms = const [],
  });
  
  Map<String, dynamic> toJson() => {
    'influencerName': influencerName,
    'followers': followers,
    'money': money,
    'energy': energy,
    'maxEnergy': maxEnergy,
    'unlockedPlatforms': unlockedPlatforms.map((p) => p.toJson()).toList(),
  };
  
  factory InfluencerData.fromJson(Map<String, dynamic> json) => InfluencerData(
    influencerName: json['influencerName'] ?? "NewInfluencer",
    followers: json['followers'] ?? 100,
    money: json['money'] ?? 50,
    energy: json['energy'] ?? 100,
    maxEnergy: json['maxEnergy'] ?? 100,
    unlockedPlatforms: (json['unlockedPlatforms'] as List? ?? [])
        .map((p) => Platform.fromJson(p))
        .toList(),
  );
}

class Platform {
  final String name;
  final String logoPath;
  final List<ContentType> availableContent;
  bool isUnlocked;
  final int unlockFollowerRequirement;
  
  Platform({
    required this.name,
    required this.logoPath,
    required this.availableContent,
    this.isUnlocked = false,
    required this.unlockFollowerRequirement,
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'logoPath': logoPath,
    'availableContent': availableContent.map((c) => c.toJson()).toList(),
    'isUnlocked': isUnlocked,
    'unlockFollowerRequirement': unlockFollowerRequirement,
  };
  
  factory Platform.fromJson(Map<String, dynamic> json) => Platform(
    name: json['name'] ?? '',
    logoPath: json['logoPath'] ?? '',
    availableContent: (json['availableContent'] as List? ?? [])
        .map((c) => ContentType.fromJson(c))
        .toList(),
    isUnlocked: json['isUnlocked'] ?? false,
    unlockFollowerRequirement: json['unlockFollowerRequirement'] ?? 0,
  );
}

class ContentType {
  final String name;
  final String iconPath;
  final int baseTime; // in minutes
  final int energyCost;
  final int baseFollowerGain;
  final int baseMoneyGain;
  
  ContentType({
    required this.name,
    required this.iconPath,
    required this.baseTime,
    required this.energyCost,
    required this.baseFollowerGain,
    required this.baseMoneyGain,
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'iconPath': iconPath,
    'baseTime': baseTime,
    'energyCost': energyCost,
    'baseFollowerGain': baseFollowerGain,
    'baseMoneyGain': baseMoneyGain,
  };
  
  factory ContentType.fromJson(Map<String, dynamic> json) => ContentType(
    name: json['name'] ?? '',
    iconPath: json['iconPath'] ?? '',
    baseTime: json['baseTime'] ?? 0,
    energyCost: json['energyCost'] ?? 0,
    baseFollowerGain: json['baseFollowerGain'] ?? 0,
    baseMoneyGain: json['baseMoneyGain'] ?? 0,
  );
}