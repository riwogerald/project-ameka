import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/shop_item.dart';
import 'game_manager.dart';

class ShopManager extends ChangeNotifier {
  static ShopManager? _instance;
  static ShopManager get instance => _instance ??= ShopManager._();
  
  ShopManager._();
  
  List<ShopItem> _shopItems = [];
  
  List<ShopItem> get shopItems => _shopItems;
  List<ShopItem> get activeItems => _shopItems.where((item) => item.isActive).toList();
  
  Future<void> initialize() async {
    await _loadShopData();
    if (_shopItems.isEmpty) {
      _createDefaultShopItems();
      await _saveShopData();
    }
  }
  
  void _createDefaultShopItems() {
    _shopItems = [
      // Energy Items
      ShopItem(
        id: 'energy_drink',
        name: 'Energy Drink',
        description: 'Instantly restore 50 energy',
        cost: 25,
        iconPath: 'assets/icons/energy_drink.png',
        type: ShopItemType.energyBoost,
        effectValue: 50,
      ),
      ShopItem(
        id: 'energy_meal',
        name: 'Power Meal',
        description: 'Instantly restore 100 energy',
        cost: 45,
        iconPath: 'assets/icons/power_meal.png',
        type: ShopItemType.energyBoost,
        effectValue: 100,
      ),
      
      // Multiplier Items
      ShopItem(
        id: 'follower_boost',
        name: 'Viral Boost',
        description: '2x followers for 60 minutes',
        cost: 100,
        iconPath: 'assets/icons/viral_boost.png',
        type: ShopItemType.followerMultiplier,
        effectValue: 2,
        duration: 60,
      ),
      ShopItem(
        id: 'money_boost',
        name: 'Sponsor Deal',
        description: '3x money for 30 minutes',
        cost: 150,
        iconPath: 'assets/icons/sponsor_deal.png',
        type: ShopItemType.moneyMultiplier,
        effectValue: 3,
        duration: 30,
      ),
      
      // Permanent Upgrades
      ShopItem(
        id: 'max_energy_1',
        name: 'Fitness Training',
        description: 'Permanently increase max energy by 25',
        cost: 200,
        iconPath: 'assets/icons/fitness.png',
        type: ShopItemType.maxEnergyIncrease,
        effectValue: 25,
      ),
      ShopItem(
        id: 'speed_boost_1',
        name: 'Better Equipment',
        description: 'Reduce all content creation time by 20%',
        cost: 300,
        iconPath: 'assets/icons/equipment.png',
        type: ShopItemType.contentSpeedBoost,
        effectValue: 20,
      ),
      
      // Premium Items
      ShopItem(
        id: 'mega_boost',
        name: 'Mega Viral Package',
        description: '5x followers and money for 15 minutes',
        cost: 500,
        iconPath: 'assets/icons/mega_boost.png',
        type: ShopItemType.followerMultiplier,
        effectValue: 5,
        duration: 15,
      ),
    ];
  }
  
  Future<bool> purchaseItem(String itemId, GameManager gameManager) async {
    final item = _shopItems.firstWhere(
      (item) => item.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );
    
    // Check if already purchased (for permanent items)
    if (item.isPurchased && item.duration == 0) {
      return false;
    }
    
    // Check if can afford
    if (!gameManager.canAfford(item.cost)) {
      return false;
    }
    
    // Purchase item
    gameManager.spendMoney(item.cost);
    item.isPurchased = true;
    item.purchaseTime = DateTime.now();
    
    // Apply effects
    _applyItemEffect(item, gameManager);
    
    await _saveShopData();
    notifyListeners();
    
    return true;
  }
  
  void _applyItemEffect(ShopItem item, GameManager gameManager) {
    switch (item.type) {
      case ShopItemType.energyBoost:
        gameManager.restoreEnergy(item.effectValue);
        break;
      case ShopItemType.maxEnergyIncrease:
        gameManager.increaseMaxEnergy(item.effectValue);
        break;
      case ShopItemType.followerMultiplier:
      case ShopItemType.moneyMultiplier:
      case ShopItemType.contentSpeedBoost:
        // These are handled in the economy calculations
        break;
      case ShopItemType.platformUnlock:
        // Handle platform unlocks if needed
        break;
    }
  }
  
  double getFollowerMultiplier() {
    double multiplier = 1.0;
    for (var item in activeItems) {
      if (item.type == ShopItemType.followerMultiplier) {
        multiplier *= item.effectValue;
      }
    }
    return multiplier;
  }
  
  double getMoneyMultiplier() {
    double multiplier = 1.0;
    for (var item in activeItems) {
      if (item.type == ShopItemType.moneyMultiplier) {
        multiplier *= item.effectValue;
      }
    }
    return multiplier;
  }
  
  double getSpeedMultiplier() {
    double reduction = 0.0;
    for (var item in activeItems) {
      if (item.type == ShopItemType.contentSpeedBoost) {
        reduction += item.effectValue / 100.0;
      }
    }
    return 1.0 - reduction.clamp(0.0, 0.8); // Max 80% reduction
  }
  
  Future<void> _saveShopData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_shopItems.map((item) => item.toJson()).toList());
    await prefs.setString('shop_data', jsonString);
  }
  
  Future<void> _loadShopData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('shop_data');
    
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _shopItems = jsonList.map((json) => ShopItem.fromJson(json)).toList();
      } catch (e) {
        debugPrint('Error loading shop data: $e');
        _shopItems = [];
      }
    }
  }
}