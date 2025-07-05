import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timer_manager.dart';
import 'timer_ui.dart';

class ActiveTimersPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TimerManager>(
      builder: (context, timerManager, child) {
        if (!timerManager.hasActiveTimers) {
          return SizedBox.shrink();
        }
        
        return Container(
          constraints: BoxConstraints(maxHeight: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: Colors.purple, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Active Content Creation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${timerManager.activeTimers.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: timerManager.activeTimers.length,
                  itemBuilder: (context, index) {
                    final timer = timerManager.activeTimers[index];
                    return TimerUI(timer: timer);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}