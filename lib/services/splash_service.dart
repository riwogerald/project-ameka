import 'package:flutter/foundation.dart';
import 'dart:async';
import 'ad_manager.dart';
import 'shop_manager.dart';
import 'audio_manager.dart';
import 'upgrade_manager.dart';
import 'equipment_manager.dart';
import 'game_manager.dart';

enum LoadingStep {
  initializing,
  loadingAds,
  loadingShop,
  loadingAudio,
  loadingUpgrades,
  loadingEquipment,
  loadingGameData,
  finalizing,
  complete,
}

class SplashService extends ChangeNotifier {
  static SplashService? _instance;
  static SplashService get instance => _instance ??= SplashService._();
  
  SplashService._();

  LoadingStep _currentStep = LoadingStep.initializing;
  double _progress = 0.0;
  String _statusMessage = 'Initializing...';
  bool _hasError = false;
  String _errorMessage = '';

  LoadingStep get currentStep => _currentStep;
  double get progress => _progress;
  String get statusMessage => _statusMessage;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get isComplete => _currentStep == LoadingStep.complete;

  final Map<LoadingStep, String> _stepMessages = {
    LoadingStep.initializing: 'Initializing app...',
    LoadingStep.loadingAds: 'Setting up ads...',
    LoadingStep.loadingShop: 'Loading shop items...',
    LoadingStep.loadingAudio: 'Preparing audio system...',
    LoadingStep.loadingUpgrades: 'Loading upgrades...',
    LoadingStep.loadingEquipment: 'Setting up equipment...',
    LoadingStep.loadingGameData: 'Loading your progress...',
    LoadingStep.finalizing: 'Almost ready...',
    LoadingStep.complete: 'Ready to play!',
  };

  Future<void> initializeApp() async {
    try {
      _hasError = false;
      _errorMessage = '';
      
      final steps = LoadingStep.values.where((step) => step != LoadingStep.complete);
      final stepCount = steps.length;
      
      for (int i = 0; i < stepCount; i++) {
        final step = steps.elementAt(i);
        _updateStep(step, i / stepCount);
        
        switch (step) {
          case LoadingStep.initializing:
            await _initializeCore();
            break;
          case LoadingStep.loadingAds:
            await _initializeAds();
            break;
          case LoadingStep.loadingShop:
            await _initializeShop();
            break;
          case LoadingStep.loadingAudio:
            await _initializeAudio();
            break;
          case LoadingStep.loadingUpgrades:
            await _initializeUpgrades();
            break;
          case LoadingStep.loadingEquipment:
            await _initializeEquipment();
            break;
          case LoadingStep.loadingGameData:
            await _initializeGameData();
            break;
          case LoadingStep.finalizing:
            await _finalizeInitialization();
            break;
          default:
            break;
        }
        
        // Add small delay for smooth animation
        await Future.delayed(Duration(milliseconds: 200));
      }
      
      _updateStep(LoadingStep.complete, 1.0);
      
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      debugPrint('Splash initialization error: $e');
      notifyListeners();
    }
  }

  void _updateStep(LoadingStep step, double progress) {
    _currentStep = step;
    _progress = progress;
    _statusMessage = _stepMessages[step] ?? 'Loading...';
    notifyListeners();
  }

  Future<void> _initializeCore() async {
    // Basic app initialization
    await Future.delayed(Duration(milliseconds: 300));
    debugPrint('Core initialized');
  }

  Future<void> _initializeAds() async {
    try {
      await AdManager.instance.initialize();
      debugPrint('Ads initialized');
    } catch (e) {
      debugPrint('Ad initialization failed: $e');
      // Don't fail the entire initialization if ads fail
    }
  }

  Future<void> _initializeShop() async {
    try {
      await ShopManager.instance.initialize();
      debugPrint('Shop initialized');
    } catch (e) {
      debugPrint('Shop initialization failed: $e');
      throw Exception('Failed to initialize shop: $e');
    }
  }

  Future<void> _initializeAudio() async {
    try {
      await AudioManager.instance.initialize();
      debugPrint('Audio initialized');
    } catch (e) {
      debugPrint('Audio initialization failed: $e');
      // Don't fail if audio fails - game can work without sound
    }
  }

  Future<void> _initializeUpgrades() async {
    try {
      await UpgradeManager.instance.initialize();
      debugPrint('Upgrades initialized');
    } catch (e) {
      debugPrint('Upgrade initialization failed: $e');
      throw Exception('Failed to initialize upgrades: $e');
    }
  }

  Future<void> _initializeEquipment() async {
    try {
      await EquipmentManager.instance.initialize();
      debugPrint('Equipment initialized');
    } catch (e) {
      debugPrint('Equipment initialization failed: $e');
      throw Exception('Failed to initialize equipment: $e');
    }
  }

  Future<void> _initializeGameData() async {
    try {
      // Game data will be loaded by GameManager, but we can do prep work here
      await Future.delayed(Duration(milliseconds: 500));
      debugPrint('Game data preparation complete');
    } catch (e) {
      debugPrint('Game data initialization failed: $e');
      throw Exception('Failed to initialize game data: $e');
    }
  }

  Future<void> _finalizeInitialization() async {
    // Final setup and cleanup
    await Future.delayed(Duration(milliseconds: 300));
    debugPrint('Initialization finalized');
  }

  void reset() {
    _currentStep = LoadingStep.initializing;
    _progress = 0.0;
    _statusMessage = 'Initializing...';
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }

  String getStepDescription(LoadingStep step) {
    switch (step) {
      case LoadingStep.initializing:
        return 'Setting up the app environment and core systems';
      case LoadingStep.loadingAds:
        return 'Configuring ad network and monetization features';
      case LoadingStep.loadingShop:
        return 'Loading shop items, upgrades, and purchase options';
      case LoadingStep.loadingAudio:
        return 'Initializing sound effects and music system';
      case LoadingStep.loadingUpgrades:
        return 'Setting up platform upgrades and enhancements';
      case LoadingStep.loadingEquipment:
        return 'Loading equipment and boost items';
      case LoadingStep.loadingGameData:
        return 'Retrieving your saved progress and achievements';
      case LoadingStep.finalizing:
        return 'Finishing up and preparing the game interface';
      case LoadingStep.complete:
        return 'Welcome to Influencer Academy!';
    }
  }

  // Method to simulate slow loading for testing
  Future<void> initializeAppSlow() async {
    try {
      _hasError = false;
      _errorMessage = '';
      
      final steps = LoadingStep.values.where((step) => step != LoadingStep.complete);
      
      for (int i = 0; i < steps.length; i++) {
        final step = steps.elementAt(i);
        _updateStep(step, i / steps.length);
        
        // Longer delay for testing animation
        await Future.delayed(Duration(milliseconds: 800));
      }
      
      _updateStep(LoadingStep.complete, 1.0);
      
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
