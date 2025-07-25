import 'package:flutter/material.dart';
import 'dart:math' as math;

class PlaceholderAssets {
  // Platform colors for consistent theming
  static const Map<String, Color> platformColors = {
    'TipPot': Color(0xFF00F2EA), // Cyan like TikTok
    'TheGram': Color(0xFFE4405F), // Pink like Instagram
    'Yutub': Color(0xFFFF0000), // Red like YouTube
    'TikTok': Color(0xFF00F2EA),
    'Instagram': Color(0xFFE4405F),
    'YouTube': Color(0xFFFF0000),
  };

  // Content type colors
  static const Map<String, Color> contentColors = {
    'Dance Video': Color(0xFFFF6B6B),
    'Lip Sync': Color(0xFF4ECDC4),
    'Comedy Skit': Color(0xFFFFE66D),
    'Story Post': Color(0xFF95E1D3),
    'Photo Post': Color(0xFFF38BA8),
    'Reel': Color(0xFFA8E6CF),
    'Short Video': Color(0xFFFFB3BA),
    'Tutorial': Color(0xFFB5EAD7),
    'Live Stream': Color(0xFFC7CEEA),
  };

  // Equipment colors
  static const Map<String, Color> equipmentColors = {
    'Camera': Color(0xFF6C5CE7),
    'Microphone': Color(0xFFA29BFE),
    'Lighting': Color(0xFFFFD93D),
    'Tripod': Color(0xFF74B9FF),
    'Editing Software': Color(0xFF00B894),
  };

  /// Generate a platform logo widget
  static Widget platformLogo(String platformName, {double size = 40}) {
    final color = platformColors[platformName] ?? Colors.purple;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        _getPlatformIcon(platformName),
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }

  /// Generate a content type icon widget
  static Widget contentIcon(String contentType, {double size = 32}) {
    final color = contentColors[contentType] ?? Colors.blue;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        _getContentIcon(contentType),
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }

  /// Generate equipment icon widget
  static Widget equipmentIcon(String equipmentType, {double size = 32}) {
    final color = equipmentColors[equipmentType] ?? Colors.grey;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        _getEquipmentIcon(equipmentType),
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }

  /// Generate app logo widget
  static Widget appLogo({double size = 80}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade400,
            Colors.purple.shade600,
            Colors.purple.shade800,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        Icons.star,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }

  /// Generate avatar placeholder
  static Widget avatarPlaceholder({double size = 40, String? name}) {
    final colors = [
      Colors.red.shade300,
      Colors.blue.shade300,
      Colors.green.shade300,
      Colors.orange.shade300,
      Colors.purple.shade300,
      Colors.teal.shade300,
    ];
    
    final color = colors[name?.hashCode.abs() % colors.length ?? 0];
    final initial = name?.isNotEmpty == true ? name![0].toUpperCase() : '?';
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Generate gradient background
  static Widget gradientBackground({
    required Widget child,
    List<Color>? colors,
    Alignment begin = Alignment.topCenter,
    Alignment end = Alignment.bottomCenter,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ?? [
            Colors.purple.shade800,
            Colors.purple.shade600,
            Colors.purple.shade400,
          ],
          begin: begin,
          end: end,
        ),
      ),
      child: child,
    );
  }

  /// Generate loading placeholder
  static Widget loadingPlaceholder({
    double width = 100,
    double height = 20,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade100,
            Colors.grey.shade300,
          ],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }

  /// Generate card placeholder
  static Widget cardPlaceholder({
    double width = 150,
    double height = 100,
    String? title,
    String? subtitle,
    Color? color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color ?? Colors.grey.shade200,
            (color ?? Colors.grey.shade200).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            if (subtitle != null) ...[
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Generate chart placeholder
  static Widget chartPlaceholder({
    double width = 200,
    double height = 100,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: CustomPaint(
        painter: ChartPlaceholderPainter(),
        size: Size(width, height),
      ),
    );
  }

  // Helper methods for icons
  static IconData _getPlatformIcon(String platformName) {
    switch (platformName.toLowerCase()) {
      case 'tippot':
      case 'tiktok':
        return Icons.music_note;
      case 'thegram':
      case 'instagram':
        return Icons.camera_alt;
      case 'yutub':
      case 'youtube':
        return Icons.play_circle_filled;
      default:
        return Icons.public;
    }
  }

  static IconData _getContentIcon(String contentType) {
    switch (contentType.toLowerCase()) {
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
        return Icons.movie;
      case 'short video':
        return Icons.video_library;
      case 'tutorial':
        return Icons.school;
      case 'live stream':
        return Icons.live_tv;
      default:
        return Icons.create;
    }
  }

  static IconData _getEquipmentIcon(String equipmentType) {
    switch (equipmentType.toLowerCase()) {
      case 'camera':
        return Icons.camera_alt;
      case 'microphone':
        return Icons.mic;
      case 'lighting':
        return Icons.lightbulb;
      case 'tripod':
        return Icons.camera_enhance;
      case 'editing software':
        return Icons.edit;
      default:
        return Icons.build;
    }
  }
}

/// Custom painter for chart placeholder
class ChartPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = size.width / 6;
    
    // Generate random-looking chart data
    final points = [
      Offset(0, size.height * 0.8),
      Offset(stepX, size.height * 0.6),
      Offset(stepX * 2, size.height * 0.4),
      Offset(stepX * 3, size.height * 0.7),
      Offset(stepX * 4, size.height * 0.3),
      Offset(stepX * 5, size.height * 0.5),
      Offset(size.width, size.height * 0.2),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw data points
    paint.style = PaintingStyle.fill;
    for (final point in points) {
      canvas.drawCircle(point, 3, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Animated placeholder for loading states
class AnimatedPlaceholder extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const AnimatedPlaceholder({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  _AnimatedPlaceholderState createState() => _AnimatedPlaceholderState();
}

class _AnimatedPlaceholderState extends State<AnimatedPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [0.0, 0.5, 1.0],
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
            ),
          ),
        );
      },
    );
  }
}
