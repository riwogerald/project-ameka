import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/equipment.dart';
import 'game_manager.dart';

class EquipmentManager extends ChangeNotifier {
  static EquipmentManager? _instance;
  static EquipmentManager get instance => _instance ??= EquipmentManager._();
  
  EquipmentManager._();
  
  List<Equipment> _allEquipment = [];
  Map<String, EquipmentLoadout> _platformLoadouts = {};
  
  List<Equipment> get allEquipment => _allEquipment;
  List<Equipment> get ownedEquipment => _allEquipment.where((e) => e.isOwned).toList();
  Map<String, EquipmentLoadout> get platformLoadouts => _platformLoadouts;
  
  Future<void> initialize() async {
    await _loadEquipmentData();
    if (_allEquipment.isEmpty) {
      _createDefaultEquipment();
      await _saveEquipmentData();
    }
  }
  
  void _createDefaultEquipment() {
    _allEquipment = [
      // CAMERA EQUIPMENT
      Equipment(
        id: 'basic_phone_camera',
        name: 'Smartphone Camera',
        description: 'Your trusty phone camera - good enough to start',
        iconPath: 'assets/equipment/phone_camera.png',
        category: EquipmentCategory.camera,
        tier: EquipmentTier.basic,
        cost: 0, // Starting equipment
        platformBonuses: {
          'TipPot_followers': 0.05,
          'TheGram_followers': 0.03,
          'Yutub_followers': 0.02,
        },
        globalBonuses: {},
        isOwned: true,
        isEquipped: true,
      ),
      Equipment(
        id: 'dslr_camera',
        name: 'DSLR Camera',
        description: 'Professional camera for crisp, high-quality content',
        iconPath: 'assets/equipment/dslr_camera.png',
        category: EquipmentCategory.camera,
        tier: EquipmentTier.professional,
        cost: 800,
        platformBonuses: {
          'TipPot_followers': 0.15,
          'TheGram_followers': 0.25,
          'Yutub_followers': 0.20,
          'TheGram_money': 0.15,
        },
        globalBonuses: {
          'content_quality': 0.20,
        },
        prerequisites: ['basic_phone_camera'],
      ),
      Equipment(
        id: 'cinema_camera',
        name: 'Cinema Camera',
        description: 'Hollywood-grade camera for cinematic content',
        iconPath: 'assets/equipment/cinema_camera.png',
        category: EquipmentCategory.camera,
        tier: EquipmentTier.premium,
        cost: 2500,
        platformBonuses: {
          'TipPot_followers': 0.25,
          'TheGram_followers': 0.35,
          'Yutub_followers': 0.40,
          'Yutub_money': 0.30,
        },
        globalBonuses: {
          'content_quality': 0.40,
          'viral_chance': 0.15,
        },
        prerequisites: ['dslr_camera'],
      ),
      Equipment(
        id: 'legendary_camera_rig',
        name: 'Legendary Camera Rig',
        description: 'The ultimate content creation setup - used by top creators',
        iconPath: 'assets/equipment/legendary_rig.png',
        category: EquipmentCategory.camera,
        tier: EquipmentTier.legendary,
        cost: 10000,
        platformBonuses: {
          'TipPot_followers': 0.50,
          'TheGram_followers': 0.60,
          'Yutub_followers': 0.70,
          'TipPot_money': 0.25,
          'TheGram_money': 0.35,
          'Yutub_money': 0.50,
        },
        globalBonuses: {
          'content_quality': 0.75,
          'viral_chance': 0.30,
          'creation_speed': 0.25,
        },
        prerequisites: ['cinema_camera'],
      ),
      
      // AUDIO EQUIPMENT
      Equipment(
        id: 'basic_headset',
        name: 'Gaming Headset',
        description: 'Basic audio setup for clear voice recording',
        iconPath: 'assets/equipment/gaming_headset.png',
        category: EquipmentCategory.audio,
        tier: EquipmentTier.basic,
        cost: 50,
        platformBonuses: {
          'Yutub_followers': 0.10,
          'TipPot_followers': 0.05,
        },
        globalBonuses: {
          'audio_quality': 0.15,
        },
        isOwned: true,
      ),
      Equipment(
        id: 'studio_microphone',
        name: 'Studio Microphone',
        description: 'Professional microphone for crystal-clear audio',
        iconPath: 'assets/equipment/studio_mic.png',
        category: EquipmentCategory.audio,
        tier: EquipmentTier.professional,
        cost: 300,
        platformBonuses: {
          'Yutub_followers': 0.25,
          'Yutub_money': 0.20,
          'TipPot_followers': 0.15,
        },
        globalBonuses: {
          'audio_quality': 0.35,
          'engagement': 0.10,
        },
        prerequisites: ['basic_headset'],
      ),
      Equipment(
        id: 'broadcast_setup',
        name: 'Broadcast Audio Setup',
        description: 'Professional broadcasting equipment for live streams',
        iconPath: 'assets/equipment/broadcast_setup.png',
        category: EquipmentCategory.audio,
        tier: EquipmentTier.premium,
        cost: 1200,
        platformBonuses: {
          'Yutub_followers': 0.40,
          'Yutub_money': 0.35,
          'TipPot_followers': 0.20,
        },
        globalBonuses: {
          'audio_quality': 0.60,
          'engagement': 0.25,
          'live_stream_bonus': 0.50,
        },
        prerequisites: ['studio_microphone'],
      ),
      
      // LIGHTING EQUIPMENT
      Equipment(
        id: 'desk_lamp',
        name: 'Desk Lamp',
        description: 'Basic lighting to avoid looking like a shadow',
        iconPath: 'assets/equipment/desk_lamp.png',
        category: EquipmentCategory.lighting,
        tier: EquipmentTier.basic,
        cost: 25,
        platformBonuses: {
          'TipPot_followers': 0.08,
          'TheGram_followers': 0.10,
        },
        globalBonuses: {
          'visual_quality': 0.10,
        },
        isOwned: true,
      ),
      Equipment(
        id: 'ring_light',
        name: 'Ring Light',
        description: 'Popular ring light for even, flattering illumination',
        iconPath: 'assets/equipment/ring_light.png',
        category: EquipmentCategory.lighting,
        tier: EquipmentTier.professional,
        cost: 150,
        platformBonuses: {
          'TipPot_followers': 0.20,
          'TheGram_followers': 0.25,
          'Yutub_followers': 0.15,
        },
        globalBonuses: {
          'visual_quality': 0.25,
          'selfie_bonus': 0.30,
        },
        prerequisites: ['desk_lamp'],
      ),
      Equipment(
        id: 'studio_lighting_kit',
        name: 'Studio Lighting Kit',
        description: 'Professional 3-point lighting setup',
        iconPath: 'assets/equipment/studio_lighting.png',
        category: EquipmentCategory.lighting,
        tier: EquipmentTier.premium,
        cost: 600,
        platformBonuses: {
          'TipPot_followers': 0.30,
          'TheGram_followers': 0.40,
          'Yutub_followers': 0.35,
          'TheGram_money': 0.20,
        },
        globalBonuses: {
          'visual_quality': 0.50,
          'professional_look': 0.40,
        },
        prerequisites: ['ring_light'],
      ),
      
      // EDITING EQUIPMENT
      Equipment(
        id: 'basic_editing_app',
        name: 'Mobile Editing App',
        description: 'Simple editing app for quick content creation',
        iconPath: 'assets/equipment/mobile_app.png',
        category: EquipmentCategory.editing,
        tier: EquipmentTier.basic,
        cost: 10,
        platformBonuses: {
          'TipPot_followers': 0.10,
        },
        globalBonuses: {
          'creation_speed': 0.15,
        },
        isOwned: true,
      ),
      Equipment(
        id: 'pro_editing_software',
        name: 'Professional Editing Suite',
        description: 'Industry-standard editing software with advanced features',
        iconPath: 'assets/equipment/pro_editing.png',
        category: EquipmentCategory.editing,
        tier: EquipmentTier.professional,
        cost: 400,
        platformBonuses: {
          'TipPot_followers': 0.25,
          'TheGram_followers': 0.20,
          'Yutub_followers': 0.30,
        },
        globalBonuses: {
          'creation_speed': 0.30,
          'content_quality': 0.25,
        },
        prerequisites: ['basic_editing_app'],
      ),
      Equipment(
        id: 'ai_editing_suite',
        name: 'AI-Powered Editing Suite',
        description: 'Cutting-edge AI editing tools for viral content',
        iconPath: 'assets/equipment/ai_editing.png',
        category: EquipmentCategory.editing,
        tier: EquipmentTier.legendary,
        cost: 5000,
        platformBonuses: {
          'TipPot_followers': 0.60,
          'TheGram_followers': 0.50,
          'Yutub_followers': 0.70,
          'TipPot_money': 0.30,
          'TheGram_money': 0.25,
          'Yutub_money': 0.40,
        },
        globalBonuses: {
          'creation_speed': 0.75,
          'content_quality': 0.60,
          'viral_chance': 0.40,
          'auto_optimization': 0.50,
        },
        prerequisites: ['pro_editing_software'],
      ),
      
      // STREAMING EQUIPMENT
      Equipment(
        id: 'basic_streaming_setup',
        name: 'Basic Streaming Setup',
        description: 'Entry-level streaming equipment for live content',
        iconPath: 'assets/equipment/basic_stream.png',
        category: EquipmentCategory.streaming,
        tier: EquipmentTier.basic,
        cost: 200,
        platformBonuses: {
          'Yutub_followers': 0.20,
          'Yutub_money': 0.15,
        },
        globalBonuses: {
          'live_stream_bonus': 0.25,
        },
      ),
      Equipment(
        id: 'pro_streaming_rig',
        name: 'Professional Streaming Rig',
        description: 'High-end streaming setup with multiple cameras',
        iconPath: 'assets/equipment/pro_stream.png',
        category: EquipmentCategory.streaming,
        tier: EquipmentTier.premium,
        cost: 1500,
        platformBonuses: {
          'Yutub_followers': 0.45,
          'Yutub_money': 0.40,
          'TipPot_followers': 0.20,
        },
        globalBonuses: {
          'live_stream_bonus': 0.60,
          'engagement': 0.30,
          'donation_bonus': 0.50,
        },
        prerequisites: ['basic_streaming_setup'],
      ),
      
      // ACCESSORIES
      Equipment(
        id: 'phone_tripod',
        name: 'Phone Tripod',
        description: 'Stable shots without shaky hands',
        iconPath: 'assets/equipment/phone_tripod.png',
        category: EquipmentCategory.accessories,
        tier: EquipmentTier.basic,
        cost: 30,
        platformBonuses: {
          'TipPot_followers': 0.12,
          'TheGram_followers': 0.15,
        },
        globalBonuses: {
          'stability_bonus': 0.20,
        },
        isOwned: true,
      ),
      Equipment(
        id: 'green_screen',
        name: 'Green Screen Setup',
        description: 'Create content anywhere with chroma key technology',
        iconPath: 'assets/equipment/green_screen.png',
        category: EquipmentCategory.accessories,
        tier: EquipmentTier.professional,
        cost: 250,
        platformBonuses: {
          'TipPot_followers': 0.30,
          'Yutub_followers': 0.25,
        },
        globalBonuses: {
          'creativity_bonus': 0.35,
          'background_variety': 0.40,
        },
      ),
      Equipment(
        id: 'motion_capture_suit',
        name: 'Motion Capture Suit',
        description: 'Next-gen content creation with full body tracking',
        iconPath: 'assets/equipment/mocap_suit.png',
        category: EquipmentCategory.accessories,
        tier: EquipmentTier.legendary,
        cost: 8000,
        platformBonuses: {
          'TipPot_followers': 0.80,
          'Yutub_followers': 0.60,
          'TipPot_money': 0.50,
          'Yutub_money': 0.40,
        },
        globalBonuses: {
          'innovation_bonus': 1.0,
          'viral_chance': 0.50,
          'tech_content_bonus': 0.75,
        },
        prerequisites: ['green_screen'],
      ),
    ];
    
    // Initialize platform loadouts
    _platformLoadouts = {
      'TipPot': EquipmentLoadout(platformId: 'TipPot'),
      'TheGram': EquipmentLoadout(platformId: 'TheGram'),
      'Yutub': EquipmentLoadout(platformId: 'Yutub'),
    };
    
    // Equip starting equipment
    _equipStartingGear();
  }
  
  void _equipStartingGear() {
    final startingEquipment = _allEquipment.where((e) => e.isOwned).toList();
    
    for (var equipment in startingEquipment) {
      for (var loadout in _platformLoadouts.values) {
        if (loadout.equippedItems[equipment.category] == null) {
          loadout.equippedItems[equipment.category] = equipment;
        }
      }
    }
  }
  
  Future<bool> purchaseEquipment(String equipmentId, GameManager gameManager) async {
    final equipment = _allEquipment.firstWhere(
      (e) => e.id == equipmentId,
      orElse: () => throw Exception('Equipment not found'),
    );
    
    if (equipment.isOwned || !gameManager.canAfford(equipment.cost)) {
      return false;
    }
    
    // Check prerequisites
    for (String prereqId in equipment.prerequisites) {
      final prereq = _allEquipment.firstWhere((e) => e.id == prereqId);
      if (!prereq.isOwned) {
        return false;
      }
    }
    
    // Purchase equipment
    gameManager.spendMoney(equipment.cost);
    equipment.isOwned = true;
    
    await _saveEquipmentData();
    notifyListeners();
    
    return true;
  }
  
  void equipItem(String equipmentId, String platformId) {
    final equipment = _allEquipment.firstWhere(
      (e) => e.id == equipmentId && e.isOwned,
      orElse: () => throw Exception('Equipment not found or not owned'),
    );
    
    final loadout = _platformLoadouts[platformId];
    if (loadout == null) return;
    
    // Unequip current item in this category
    final currentEquipped = loadout.equippedItems[equipment.category];
    if (currentEquipped != null) {
      currentEquipped.isEquipped = false;
    }
    
    // Equip new item
    loadout.equippedItems[equipment.category] = equipment;
    equipment.isEquipped = true;
    
    _saveEquipmentData();
    notifyListeners();
  }
  
  void unequipItem(String platformId, EquipmentCategory category) {
    final loadout = _platformLoadouts[platformId];
    if (loadout == null) return;
    
    final currentEquipped = loadout.equippedItems[category];
    if (currentEquipped != null) {
      currentEquipped.isEquipped = false;
      loadout.equippedItems[category] = null;
    }
    
    _saveEquipmentData();
    notifyListeners();
  }
  
  double getPlatformBonus(String platformId, String bonusType) {
    final loadout = _platformLoadouts[platformId];
    if (loadout == null) return 1.0;
    
    return 1.0 + loadout.getTotalBonus(bonusType);
  }
  
  double getGlobalBonus(String bonusType) {
    double total = 0.0;
    for (var loadout in _platformLoadouts.values) {
      total += loadout.getTotalBonus(bonusType);
    }
    return 1.0 + (total / _platformLoadouts.length); // Average across platforms
  }
  
  List<Equipment> getEquipmentByCategory(EquipmentCategory category) {
    return _allEquipment.where((e) => e.category == category).toList();
  }
  
  List<Equipment> getAvailableEquipment() {
    return _allEquipment.where((e) => !e.isOwned && _canPurchase(e)).toList();
  }
  
  bool _canPurchase(Equipment equipment) {
    // Check prerequisites
    for (String prereqId in equipment.prerequisites) {
      final prereq = _allEquipment.firstWhere((e) => e.id == prereqId);
      if (!prereq.isOwned) {
        return false;
      }
    }
    return true;
  }
  
  Future<void> _saveEquipmentData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final equipmentData = {
      'allEquipment': _allEquipment.map((e) => e.toJson()).toList(),
      'platformLoadouts': _platformLoadouts.map((k, v) => 
          MapEntry(k, v.toJson())),
    };
    
    await prefs.setString('equipment_data', jsonEncode(equipmentData));
  }
  
  Future<void> _loadEquipmentData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('equipment_data');
    
    if (jsonString != null) {
      try {
        final data = jsonDecode(jsonString);
        
        _allEquipment = (data['allEquipment'] as List)
            .map((e) => Equipment.fromJson(e))
            .toList();
        
        _platformLoadouts = (data['platformLoadouts'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, EquipmentLoadout.fromJson(v)));
      } catch (e) {
        debugPrint('Error loading equipment data: $e');
        _allEquipment = [];
        _platformLoadouts = {};
      }
    }
  }
}