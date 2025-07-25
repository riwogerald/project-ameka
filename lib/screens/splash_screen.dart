import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../services/splash_service.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _spinnerController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  
  late Animation<double> _logoScale;
  late Animation<double> _spinnerRotation;
  late Animation<double> _textFade;
  late Animation<double> _containerScale;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    // Logo pulsing animation
    _logoController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _logoScale = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    // Spinner rotation
    _spinnerController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _spinnerRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _spinnerController,
      curve: Curves.linear,
    ));

    // Text fade animation
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Scale animation for completion
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _containerScale = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _logoController.repeat();
    _spinnerController.repeat();
    _fadeController.forward();
  }

  void _startInitialization() async {
    final splashService = SplashService.instance;
    
    // Listen for completion
    splashService.addListener(_onInitializationUpdate);
    
    // Start the initialization process
    await splashService.initializeApp();
  }

  void _onInitializationUpdate() {
    final splashService = SplashService.instance;
    
    if (splashService.isComplete && mounted) {
      _completeInitialization();
    } else if (splashService.hasError && mounted) {
      _showErrorDialog();
    }
  }

  void _completeInitialization() async {
    // Play completion animation
    _scaleController.forward();
    await Future.delayed(Duration(milliseconds: 500));
    
    if (mounted) {
      // Navigate to home screen
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 600),
        ),
      );
    }
  }

  void _showErrorDialog() {
    final splashService = SplashService.instance;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Initialization Error'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Failed to initialize the app:'),
            SizedBox(height: 8),
            Text(
              splashService.errorMessage,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _retryInitialization();
            },
            child: Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _skipToHome();
            },
            child: Text('Skip'),
          ),
        ],
      ),
    );
  }

  void _retryInitialization() {
    final splashService = SplashService.instance;
    splashService.reset();
    _startInitialization();
  }

  void _skipToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  void dispose() {
    SplashService.instance.removeListener(_onInitializationUpdate);
    _logoController.dispose();
    _spinnerController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SplashService>(
        builder: (context, splashService, child) {
          return AnimatedBuilder(
            animation: _containerScale,
            builder: (context, child) {
              return Transform.scale(
                scale: _containerScale.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.purple.shade900,
                        Colors.purple.shade700,
                        Colors.purple.shade500,
                        Colors.deepPurple.shade400,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Main content area
                        Expanded(
                          flex: 5,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Animated logo
                                AnimatedBuilder(
                                  animation: _logoScale,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _logoScale.value,
                                      child: Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 25,
                                              spreadRadius: 8,
                                            ),
                                            BoxShadow(
                                              color: Colors.purple.withOpacity(0.2),
                                              blurRadius: 40,
                                              spreadRadius: 15,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.star,
                                          size: 70,
                                          color: Colors.purple.shade600,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 32),
                                
                                // App title with glow effect
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 24),
                                  child: Column(
                                    children: [
                                      Text(
                                        'INFLUENCER',
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 4,
                                          shadows: [
                                            Shadow(
                                              color: Colors.purple.shade300,
                                              offset: Offset(0, 0),
                                              blurRadius: 20,
                                            ),
                                            Shadow(
                                              color: Colors.black.withOpacity(0.8),
                                              offset: Offset(2, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'ACADEMY',
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.white.withOpacity(0.95),
                                          letterSpacing: 2,
                                          shadows: [
                                            Shadow(
                                              color: Colors.purple.shade200,
                                              offset: Offset(0, 0),
                                              blurRadius: 15,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                
                                // Subtitle
                                Text(
                                  'Build Your Social Empire',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.8),
                                    fontStyle: FontStyle.italic,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Loading section
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Loading spinner
                              AnimatedBuilder(
                                animation: _spinnerRotation,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _spinnerRotation.value,
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      child: CustomPaint(
                                        painter: EnhancedSpinnerPainter(
                                          progress: splashService.progress,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 32),
                              
                              // Status text
                              AnimatedBuilder(
                                animation: _textFade,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _textFade.value,
                                    child: Column(
                                      children: [
                                        Text(
                                          splashService.statusMessage,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white.withOpacity(0.9),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          splashService.getStepDescription(splashService.currentStep),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 40),
                              
                              // Progress bar
                              Container(
                                width: MediaQuery.of(context).size.width * 0.75,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Stack(
                                  children: [
                                    // Background glow
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.75 * splashService.progress,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.3),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Progress fill
                                    FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: splashService.progress,
                                      child: Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white,
                                              Colors.purple.shade100,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(3),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.6),
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              
                              // Progress percentage
                              Text(
                                '${(splashService.progress * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Footer
                        Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Column(
                            children: [
                              Text(
                                'Version 1.0.0',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '© 2024 Influencer Academy',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EnhancedSpinnerPainter extends CustomPainter {
  final double progress;
  
  EnhancedSpinnerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Draw outer ring
    final outerPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, outerPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw spinning segments
    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi / 6);
      final opacity = (i + 1) / 12 * 0.7;
      
      final segmentPaint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final startRadius = radius - 8;
      final endRadius = radius - 2;
      
      final start = Offset(
        center.dx + startRadius * math.cos(angle),
        center.dy + startRadius * math.sin(angle),
      );
      
      final end = Offset(
        center.dx + endRadius * math.cos(angle),
        center.dy + endRadius * math.sin(angle),
      );

      canvas.drawLine(start, end, segmentPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
