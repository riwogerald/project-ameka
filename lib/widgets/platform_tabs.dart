import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_manager.dart';

class PlatformTabs extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;
  
  const PlatformTabs({
    Key? key,
    required this.currentIndex,
    required this.onTabChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer<GameManager>(
      builder: (context, gameManager, child) {
        final platforms = gameManager.currentInfluencer.unlockedPlatforms;
        
        return Container(
          height: 70,
          padding: EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: platforms.length,
            itemBuilder: (context, index) {
              final platform = platforms[index];
              final isSelected = index == currentIndex;
              final isUnlocked = platform.isUnlocked;
              
              return GestureDetector(
                onTap: isUnlocked ? () => onTabChanged(index) : null,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: 6),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected 
                        ? LinearGradient(
                            colors: [Colors.purple, Colors.purple.shade700],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.purple.shade700 : Colors.grey[400]!,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ] : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPlatformIcon(platform.name),
                        color: isUnlocked 
                            ? (isSelected ? Colors.white : Colors.purple)
                            : Colors.grey,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        platform.name,
                        style: TextStyle(
                          color: isUnlocked 
                              ? (isSelected ? Colors.white : Colors.purple)
                              : Colors.grey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (!isUnlocked) ...[
                        SizedBox(width: 4),
                        Icon(Icons.lock, color: Colors.grey, size: 16),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  IconData _getPlatformIcon(String platformName) {
    switch (platformName.toLowerCase()) {
      case 'tiktok':
        return Icons.music_note;
      case 'instagram':
        return Icons.camera_alt;
      case 'youtube':
        return Icons.play_circle_filled;
      default:
        return Icons.public;
    }
  }
}