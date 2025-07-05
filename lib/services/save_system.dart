import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/game_data.dart';

class SaveSystem {
  static const String _gameDataKey = 'game_data';
  
  static Future<void> saveGame(InfluencerData data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data.toJson());
    await prefs.setString(_gameDataKey, jsonString);
  }
  
  static Future<InfluencerData> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_gameDataKey);
    
    if (jsonString != null) {
      try {
        final jsonMap = jsonDecode(jsonString);
        return InfluencerData.fromJson(jsonMap);
      } catch (e) {
        // If there's an error loading, create new game
        return _createNewGame();
      }
    }
    
    return _createNewGame();
  }
  
  static InfluencerData _createNewGame() {
    return InfluencerData(
      influencerName: "NewInfluencer",
      followers: 100,
      money: 50,
      energy: 100,
      maxEnergy: 100,
      unlockedPlatforms: _getDefaultPlatforms(),
    );
  }
  
  static List<Platform> _getDefaultPlatforms() {
    return [
      Platform(
        name: "TipPot",
        logoPath: "assets/images/tippot_logo.png",
        availableContent: _getTipPotContent(),
        isUnlocked: true,
        unlockFollowerRequirement: 0,
      ),
      Platform(
        name: "TheGram",
        logoPath: "assets/images/thegram_logo.png",
        availableContent: _getTheGramContent(),
        isUnlocked: false,
        unlockFollowerRequirement: 1000,
      ),
      Platform(
        name: "Yutub",
        logoPath: "assets/images/yutub_logo.png",
        availableContent: _getYutubContent(),
        isUnlocked: false,
        unlockFollowerRequirement: 5000,
      ),
    ];
  }
  
  static List<ContentType> _getTipPotContent() {
    return [
      ContentType(
        name: "Dance Video",
        iconPath: "assets/images/dance_icon.png",
        baseTime: 5,
        energyCost: 10,
        baseFollowerGain: 15,
        baseMoneyGain: 5,
      ),
      ContentType(
        name: "Lip Sync",
        iconPath: "assets/images/lipsync_icon.png",
        baseTime: 3,
        energyCost: 8,
        baseFollowerGain: 10,
        baseMoneyGain: 3,
      ),
      ContentType(
        name: "Comedy Skit",
        iconPath: "assets/images/comedy_icon.png",
        baseTime: 15,
        energyCost: 20,
        baseFollowerGain: 25,
        baseMoneyGain: 8,
      ),
    ];
  }
  
  static List<ContentType> _getTheGramContent() {
    return [
      ContentType(
        name: "Story Post",
        iconPath: "assets/images/story_icon.png",
        baseTime: 2,
        energyCost: 5,
        baseFollowerGain: 8,
        baseMoneyGain: 2,
      ),
      ContentType(
        name: "Photo Post",
        iconPath: "assets/images/photo_icon.png",
        baseTime: 10,
        energyCost: 15,
        baseFollowerGain: 20,
        baseMoneyGain: 6,
      ),
      ContentType(
        name: "Reel",
        iconPath: "assets/images/reel_icon.png",
        baseTime: 30,
        energyCost: 25,
        baseFollowerGain: 40,
        baseMoneyGain: 12,
      ),
    ];
  }
  
  static List<ContentType> _getYutubContent() {
    return [
      ContentType(
        name: "Short Video",
        iconPath: "assets/images/short_icon.png",
        baseTime: 60,
        energyCost: 30,
        baseFollowerGain: 50,
        baseMoneyGain: 15,
      ),
      ContentType(
        name: "Tutorial",
        iconPath: "assets/images/tutorial_icon.png",
        baseTime: 180,
        energyCost: 40,
        baseFollowerGain: 80,
        baseMoneyGain: 25,
      ),
      ContentType(
        name: "Live Stream",
        iconPath: "assets/images/live_icon.png",
        baseTime: 720,
        energyCost: 60,
        baseFollowerGain: 150,
        baseMoneyGain: 45,
      ),
    ];
  }
}