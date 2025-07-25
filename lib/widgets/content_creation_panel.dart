import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_manager.dart';
import '../services/timer_manager.dart';
import '../services/economy_manager.dart';
import '../services/ad_manager.dart';
import '../services/audio_manager.dart';
import '../models/game_data.dart';
import 'content_button.dart';

class ContentCreationPanel extends StatelessWidget {
  final int platformIndex;
  
  const ContentCreationPanel({
    Key? key,
    required this.platformIndex,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer<GameManager>(
      builder: (context, gameManager, child) {
        final platforms = gameManager.currentInfluencer.unlockedPlatforms;
        
        if (platformIndex >= platforms.length) {
          return Center(
            child: Text(
              'Platform not found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          );
        }
        
        final currentPlatform = platforms[platformIndex];
        
        if (!currentPlatform.isUnlocked) {
          return _buildLockedPlatform(currentPlatform);
        }
        
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade50, Colors.purple.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getPlatformIcon(currentPlatform.name),
                      color: Colors.purple,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Content for ${currentPlatform.name}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700,
                            ),
                          ),
                          Text(
                            EconomyManager.instance.getInfluencerTier(gameManager.currentInfluencer.followers),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.purple.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: currentPlatform.availableContent.length,
                  itemBuilder: (context, index) {
                    final content = currentPlatform.availableContent[index];
                    return ContentButton(
                      contentType: content,
                      onPressed: () => _startContentCreation(context, content, currentPlatform.name, gameManager),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildLockedPlatform(Platform platform) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24),
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              '${platform.name} is locked',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Reach ${platform.unlockFollowerRequirement} followers to unlock',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getPlatformIcon(String platformName) {
    switch (platformName.toLowerCase()) {
      case 'tippot':
        return Icons.music_note;
      case 'thegram':
        return Icons.camera_alt;
      case 'yutub':
        return Icons.play_circle_filled;
      default:
        return Icons.public;
    }
  }
  
  void _startContentCreation(BuildContext context, ContentType content, String platformName, GameManager gameManager) {
    // Play button click sound
    AudioManager.instance.playSound(SoundEffect.buttonClick);
    
    // Check if user has enough energy
    if (!gameManager.canCreateContent(content)) {
      _showNotEnoughEnergyDialog(context);
      return;
    }
    
    // Show interstitial ad before starting content (occasionally)
    AdManager.instance.showInterstitialAd(
      onComplete: () {
        // Start the timer with platform ID
        final timerId = TimerManager.instance.startContentTimer(content, platformName, gameManager);
        
        // Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Started creating ${content.name}! Check the timer below.'),
            backgroundColor: Colors.purple,
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }
  
  void _showNotEnoughEnergyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.battery_alert, color: Colors.orange),
            SizedBox(width: 8),
            Text('Not Enough Energy'),
          ],
        ),
        content: Text(
          'You need more energy to create this content. Wait for your energy to regenerate or watch an ad to restore it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _restoreEnergyWithAd(context);
            },
            child: Text('Watch Ad'),
          ),
        ],
      ),
    );
  }
  
  void _restoreEnergyWithAd(BuildContext context) {
    final gameManager = Provider.of<GameManager>(context, listen: false);
    
    AdManager.instance.showRewardedAd(
      onRewarded: () {
        gameManager.restoreEnergy(50); // Restore 50 energy
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Energy restored! +50 energy'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      },
      onFailed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ad not available. Try again later.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }
}