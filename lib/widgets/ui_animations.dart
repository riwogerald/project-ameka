import 'package:flutter/material.dart';

class UIAnimations {
  static void scaleButton(TickerProvider vsync, Widget child, VoidCallback onPressed) {
    // This would be implemented with AnimationController
    // For now, we'll use simple InkWell effects
  }
  
  static Widget buildScaleAnimation({
    required Widget child,
    required VoidCallback onPressed,
    double scaleFactor = 0.95,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 100),
      tween: Tween(begin: 1.0, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) {
          // Scale down animation would go here
        },
        onTapUp: (_) {
          // Scale up animation would go here
          onPressed();
        },
        onTapCancel: () {
          // Reset scale animation would go here
        },
        child: child,
      ),
    );
  }
  
  static Widget buildCountUpText({
    required int startValue,
    required int endValue,
    required TextStyle style,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return TweenAnimationBuilder<int>(
      duration: duration,
      tween: IntTween(begin: startValue, end: endValue),
      builder: (context, value, child) {
        return Text(
          value.toString(),
          style: style,
        );
      },
    );
  }
  
  static Widget buildSlideInAnimation({
    required Widget child,
    required AnimationController controller,
    Offset begin = const Offset(0, 1),
    Offset end = Offset.zero,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }
  
  static Widget buildFadeInAnimation({
    required Widget child,
    required AnimationController controller,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: controller,
        curve: Curves.easeIn,
      ),
      child: child,
    );
  }
}