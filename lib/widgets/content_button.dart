import 'package:flutter/material.dart';
import '../models/game_data.dart';
import '../utils/number_formatter.dart';

class ContentButton extends StatelessWidget {
  final ContentType contentType;
  final VoidCallback onPressed;
  
  const ContentButton({
    Key? key,
    required this.contentType,
    required this.onPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getContentIcon(contentType.name),
                  size: 32,
                  color: Colors.purple.shade700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                contentType.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                '${contentType.baseTime}m',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatChip(
                    Icons.people,
                    '+${contentType.baseFollowerGain}',
                    Colors.blue,
                  ),
                  _buildStatChip(
                    Icons.attach_money,
                    '+${contentType.baseMoneyGain}',
                    Colors.green,
                  ),
                ],
              ),
              SizedBox(height: 4),
              _buildEnergyChip(contentType.energyCost),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEnergyChip(int energyCost) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.battery_charging_full, size: 12, color: Colors.orange),
          SizedBox(width: 2),
          Text(
            '-$energyCost',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
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
}