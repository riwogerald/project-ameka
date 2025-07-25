import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/game_data.dart';
import '../services/economy_manager.dart';
import 'game_manager.dart';

class ActiveTimer {
  final String id;
  final ContentType contentType;
  final String platformId;
  final DateTime startTime;
  final int totalDuration; // in seconds
  int remainingTime; // in seconds
  bool isActive;
  
  ActiveTimer({
    required this.id,
    required this.contentType,
    required this.platformId,
    required this.startTime,
    required this.totalDuration,
    required this.remainingTime,
    this.isActive = true,
  });
  
  double get progress => 1.0 - (remainingTime / totalDuration);
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'contentType': contentType.toJson(),
    'platformId': platformId,
    'startTime': startTime.millisecondsSinceEpoch,
    'totalDuration': totalDuration,
    'remainingTime': remainingTime,
    'isActive': isActive,
  };
  
  factory ActiveTimer.fromJson(Map<String, dynamic> json) => ActiveTimer(
    id: json['id'] ?? '',
    contentType: ContentType.fromJson(json['contentType'] ?? {}),
    platformId: json['platformId'] ?? '',
    startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime'] ?? 0),
    totalDuration: json['totalDuration'] ?? 0,
    remainingTime: json['remainingTime'] ?? 0,
    isActive: json['isActive'] ?? true,
  );
}

class TimerManager extends ChangeNotifier {
  static TimerManager? _instance;
  static TimerManager get instance => _instance ??= TimerManager._();
  
  TimerManager._();
  
  List<ActiveTimer> _activeTimers = [];
  Timer? _updateTimer;
  
  List<ActiveTimer> get activeTimers => _activeTimers;
  bool get hasActiveTimers => _activeTimers.isNotEmpty;
  
  void initialize() {
    // Start the main update timer (updates every second)
    _updateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTimers();
    });
  }
  
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
  
  String startContentTimer(ContentType content, String platformId, GameManager gameManager) {
    // Generate unique ID for this timer
    final String timerId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Calculate duration with shop speed boosts and platform upgrades
    final int duration = EconomyManager.instance.calculateContentDuration(content, platformId);
    
    // Create new timer
    final timer = ActiveTimer(
      id: timerId,
      contentType: content,
      platformId: platformId,
      startTime: DateTime.now(),
      totalDuration: duration,
      remainingTime: duration,
    );
    
    _activeTimers.add(timer);
    
    // Consume energy
    gameManager.consumeEnergy(content.energyCost);
    
    notifyListeners();
    return timerId;
  }
  
  void _updateTimers() {
    bool hasChanges = false;
    List<ActiveTimer> completedTimers = [];
    
    for (var timer in _activeTimers) {
      if (timer.isActive && timer.remainingTime > 0) {
        timer.remainingTime--;
        hasChanges = true;
        
        if (timer.remainingTime <= 0) {
          timer.isActive = false;
          completedTimers.add(timer);
        }
      }
    }
    
    // Handle completed timers
    for (var completedTimer in completedTimers) {
      _completeTimer(completedTimer);
    }
    
    // Remove completed timers
    _activeTimers.removeWhere((timer) => !timer.isActive);
    
    if (hasChanges) {
      notifyListeners();
    }
  }
  
  void _completeTimer(ActiveTimer timer) {
    // This will be called when a timer completes
    // The UI will listen for this and show rewards
    debugPrint('Timer completed: ${timer.contentType.name} on ${timer.platformId}');
  }
  
  void skipTimer(String timerId, GameManager gameManager) {
    final timer = _activeTimers.firstWhere(
      (t) => t.id == timerId,
      orElse: () => throw Exception('Timer not found'),
    );
    
    timer.remainingTime = 0;
    timer.isActive = false;
    _completeTimer(timer);
    
    // Award rewards immediately
    EconomyManager.instance.completeContent(timer.contentType, gameManager, timer.platformId);
    
    _activeTimers.removeWhere((t) => t.id == timerId);
    
    notifyListeners();
  }
  
  ActiveTimer? getTimer(String timerId) {
    try {
      return _activeTimers.firstWhere((t) => t.id == timerId);
    } catch (e) {
      return null;
    }
  }
  
  String formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}