import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timer_manager.dart';
import '../services/game_manager.dart';

class TimerUI extends StatelessWidget {
  final ActiveTimer timer;
  
  const TimerUI({
    Key? key,
    required this.timer,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getContentIcon(timer.contentType.name),
                    color: Colors.purple.shade700,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timer.contentType.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'Time remaining: ${TimerManager.instance.formatTime(timer.remainingTime)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showSkipDialog(context),
                  icon: Icon(Icons.fast_forward, size: 16),
                  label: Text('Skip'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    textStyle: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: timer.progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              minHeight: 6,
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRewardChip(
                  Icons.people,
                  '+${timer.contentType.baseFollowerGain}',
                  Colors.blue,
                ),
                _buildRewardChip(
                  Icons.attach_money,
                  '+\$${timer.contentType.baseMoneyGain}',
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRewardChip(IconData icon, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getContentIcon(String contentName) {
    switch (contentName.toLowerCase()) {
      case 'dance video':
        return Icons.music_note;
      case 'lip sync':
        return Icons.mic;
      case 'comedy skit':
        return Icons.theater_comedy;
      case 'story post':
        return Icons.auto_stories;
      case 'photo post':
        return Icons.photo_camera;
      case 'reel':
        return Icons.video_camera_back;
      case 'short video':
        return Icons.videocam;
      case 'tutorial':
        return Icons.school;
      case 'live stream':
        return Icons.live_tv;
      default:
        return Icons.create;
    }
  }
  
  void _showSkipDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.fast_forward, color: Colors.orange),
            SizedBox(width: 8),
            Text('Skip Timer'),
          ],
        ),
        content: Text(
          'Watch an ad to instantly complete this content creation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _skipWithAd(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text('Watch Ad'),
          ),
        ],
      ),
    );
  }
  
  void _skipWithAd(BuildContext context) {
    final gameManager = Provider.of<GameManager>(context, listen: false);
    
    // Skip the timer
    TimerManager.instance.skipTimer(timer.id, gameManager);
    
    // Add rewards
    gameManager.addFollowers(timer.contentType.baseFollowerGain);
    gameManager.addMoney(timer.contentType.baseMoneyGain);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${timer.contentType.name} completed! +${timer.contentType.baseFollowerGain} followers, +\$${timer.contentType.baseMoneyGain}',
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}