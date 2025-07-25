import 'package:flutter/material.dart';
import '../utils/placeholder_assets.dart';
import 'dart:io';

/// Enum for different asset types
enum AssetType {
  platformLogo,
  contentIcon,
  equipmentIcon,
  appLogo,
  avatar,
  background,
  chart,
  generic,
}

/// Widget that handles both real assets and placeholder generation
class AssetWidget extends StatelessWidget {
  final String assetPath;
  final AssetType type;
  final double width;
  final double height;
  final String? name; // For dynamic content (platform name, content type, etc.)
  final Color? color;
  final Widget? fallback;
  final BoxFit fit;
  final bool useCache;

  const AssetWidget({
    Key? key,
    required this.assetPath,
    required this.type,
    this.width = 40,
    this.height = 40,
    this.name,
    this.color,
    this.fallback,
    this.fit = BoxFit.cover,
    this.useCache = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Try to load real asset first, fallback to placeholder if not found
    return FutureBuilder<bool>(
      future: _assetExists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingPlaceholder();
        }

        if (snapshot.data == true) {
          return _buildRealAsset();
        } else {
          return _buildPlaceholder();
        }
      },
    );
  }

  Future<bool> _assetExists() async {
    try {
      // Check if asset exists in bundle
      await DefaultAssetBundle.of(context as BuildContext).load(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _buildRealAsset() {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    switch (type) {
      case AssetType.platformLogo:
        return PlaceholderAssets.platformLogo(
          name ?? _extractNameFromPath(),
          size: width,
        );
      case AssetType.contentIcon:
        return PlaceholderAssets.contentIcon(
          name ?? _extractNameFromPath(),
          size: width,
        );
      case AssetType.equipmentIcon:
        return PlaceholderAssets.equipmentIcon(
          name ?? _extractNameFromPath(),
          size: width,
        );
      case AssetType.appLogo:
        return PlaceholderAssets.appLogo(size: width);
      case AssetType.avatar:
        return PlaceholderAssets.avatarPlaceholder(
          size: width,
          name: name,
        );
      case AssetType.chart:
        return PlaceholderAssets.chartPlaceholder(
          width: width,
          height: height,
        );
      case AssetType.background:
        return PlaceholderAssets.gradientBackground(
          child: Container(width: width, height: height),
          colors: color != null ? [color!, color!.withOpacity(0.7)] : null,
        );
      case AssetType.generic:
      default:
        return fallback ?? _buildGenericPlaceholder();
    }
  }

  Widget _buildLoadingPlaceholder() {
    return PlaceholderAssets.loadingPlaceholder(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(8),
    );
  }

  Widget _buildGenericPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade400,
          width: 1,
        ),
      ),
      child: Icon(
        Icons.image,
        color: Colors.grey.shade600,
        size: width * 0.4,
      ),
    );
  }

  String _extractNameFromPath() {
    // Extract name from asset path for intelligent placeholder generation
    final fileName = assetPath.split('/').last.split('.').first;
    return fileName.replaceAll('_', ' ').replaceAll('-', ' ');
  }
}

/// Convenience widgets for specific asset types
class PlatformLogoWidget extends StatelessWidget {
  final String platformName;
  final double size;
  final String? assetPath;

  const PlatformLogoWidget({
    Key? key,
    required this.platformName,
    this.size = 40,
    this.assetPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AssetWidget(
      assetPath: assetPath ?? 'assets/images/${platformName.toLowerCase()}_logo.png',
      type: AssetType.platformLogo,
      width: size,
      height: size,
      name: platformName,
    );
  }
}

class ContentIconWidget extends StatelessWidget {
  final String contentType;
  final double size;
  final String? assetPath;

  const ContentIconWidget({
    Key? key,
    required this.contentType,
    this.size = 32,
    this.assetPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AssetWidget(
      assetPath: assetPath ?? 'assets/images/${contentType.toLowerCase().replaceAll(' ', '_')}_icon.png',
      type: AssetType.contentIcon,
      width: size,
      height: size,
      name: contentType,
    );
  }
}

class EquipmentIconWidget extends StatelessWidget {
  final String equipmentType;
  final double size;
  final String? assetPath;

  const EquipmentIconWidget({
    Key? key,
    required this.equipmentType,
    this.size = 32,
    this.assetPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AssetWidget(
      assetPath: assetPath ?? 'assets/images/${equipmentType.toLowerCase().replaceAll(' ', '_')}_icon.png',
      type: AssetType.equipmentIcon,
      width: size,
      height: size,
      name: equipmentType,
    );
  }
}

class AppLogoWidget extends StatelessWidget {
  final double size;
  final String? assetPath;

  const AppLogoWidget({
    Key? key,
    this.size = 80,
    this.assetPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AssetWidget(
      assetPath: assetPath ?? 'assets/images/app_logo.png',
      type: AssetType.appLogo,
      width: size,
      height: size,
    );
  }
}

class AvatarWidget extends StatelessWidget {
  final String? name;
  final double size;
  final String? assetPath;

  const AvatarWidget({
    Key? key,
    this.name,
    this.size = 40,
    this.assetPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AssetWidget(
      assetPath: assetPath ?? 'assets/images/default_avatar.png',
      type: AssetType.avatar,
      width: size,
      height: size,
      name: name,
    );
  }
}

/// Widget for handling background images with gradient fallbacks
class BackgroundWidget extends StatelessWidget {
  final Widget child;
  final String? assetPath;
  final List<Color>? gradientColors;
  final Alignment begin;
  final Alignment end;

  const BackgroundWidget({
    Key? key,
    required this.child,
    this.assetPath,
    this.gradientColors,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (assetPath != null) {
      return FutureBuilder<bool>(
        future: _assetExists(context),
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(assetPath!),
                  fit: BoxFit.cover,
                ),
              ),
              child: child,
            );
          } else {
            return _buildGradientBackground();
          }
        },
      );
    } else {
      return _buildGradientBackground();
    }
  }

  Widget _buildGradientBackground() {
    return PlaceholderAssets.gradientBackground(
      child: child,
      colors: gradientColors,
      begin: begin,
      end: end,
    );
  }

  Future<bool> _assetExists(BuildContext context) async {
    if (assetPath == null) return false;
    try {
      await DefaultAssetBundle.of(context).load(assetPath!);
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Utility class for easy asset management
class AssetManager {
  static const String _basePath = 'assets/images/';
  
  // Platform assets
  static String platformLogo(String platformName) =>
      '${_basePath}${platformName.toLowerCase()}_logo.png';
  
  // Content type assets
  static String contentIcon(String contentType) =>
      '${_basePath}${contentType.toLowerCase().replaceAll(' ', '_')}_icon.png';
  
  // Equipment assets
  static String equipmentIcon(String equipmentType) =>
      '${_basePath}${equipmentType.toLowerCase().replaceAll(' ', '_')}_icon.png';
  
  // Common assets
  static const String appLogo = '${_basePath}app_logo.png';
  static const String defaultAvatar = '${_basePath}default_avatar.png';
  static const String backgroundImage = '${_basePath}background.png';
  
  // Check if we should use placeholders (for development)
  static bool get usePlaceholders => true; // Set to false when real assets are added
}
