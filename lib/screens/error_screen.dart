import 'package:flutter/material.dart';
import '../services/splash_service.dart';
import 'splash_screen.dart';

class ErrorScreen extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const ErrorScreen({
    Key? key,
    required this.errorMessage,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade800,
              Colors.red.shade600,
              Colors.orange.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 50,
                    color: Colors.red.shade600,
                  ),
                ),
                SizedBox(height: 32),
                
                // Error title
                Text(
                  'Oops! Something went wrong',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                
                // Error message
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 40),
                
                // Action buttons
                Column(
                  children: [
                    // Retry button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (onRetry != null) {
                            onRetry!();
                          } else {
                            _defaultRetry(context);
                          }
                        },
                        icon: Icon(Icons.refresh),
                        label: Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red.shade600,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    // Skip button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _skipToApp(context),
                        icon: Icon(Icons.skip_next),
                        label: Text('Skip and Continue'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withOpacity(0.7)),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                
                // Help text
                Text(
                  'If the problem persists, please check your internet connection or restart the app.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _defaultRetry(BuildContext context) {
    // Reset splash service and restart initialization
    SplashService.instance.reset();
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
  }

  void _skipToApp(BuildContext context) {
    // Import the home screen and navigate directly
    // This should be handled carefully to ensure the app still works
    Navigator.of(context).pushReplacementNamed('/home');
  }
}

// Alternative error widget for inline display
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool compact;

  const InlineErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade600,
                size: compact ? 20 : 24,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  compact ? 'Error occurred' : 'Something went wrong',
                  style: TextStyle(
                    fontSize: compact ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ),
            ],
          ),
          if (!compact) ...[
            SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade700,
                height: 1.3,
              ),
            ),
          ],
          if (onRetry != null) ...[
            SizedBox(height: compact ? 8 : 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh, size: compact ? 16 : 20),
                label: Text(compact ? 'Retry' : 'Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: compact ? 8 : 12,
                  ),
                  minimumSize: Size(0, compact ? 32 : 40),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
