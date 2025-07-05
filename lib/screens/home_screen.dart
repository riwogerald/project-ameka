import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_manager.dart';
import '../services/timer_manager.dart';
import '../widgets/top_bar.dart';
import '../widgets/platform_tabs.dart';
import '../widgets/content_creation_panel.dart';
import '../widgets/active_timers_panel.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPlatformIndex = 0;
  
  @override
  void initState() {
    super.initState();
    // Initialize the timer manager
    TimerManager.instance.initialize();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Influencer Academy'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // TODO: Add settings screen in Phase 4
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Settings coming in Phase 4!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
        ],
      ),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: TimerManager.instance),
        ],
        child: Consumer<GameManager>(
          builder: (context, gameManager, child) {
            if (gameManager.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading your influencer journey...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return Column(
              children: [
                TopBar(),
                PlatformTabs(
                  currentIndex: _currentPlatformIndex,
                  onTabChanged: (index) {
                    setState(() {
                      _currentPlatformIndex = index;
                    });
                  },
                ),
                Expanded(
                  child: ContentCreationPanel(
                    platformIndex: _currentPlatformIndex,
                  ),
                ),
                ActiveTimersPanel(),
              ],
            );
          },
        ),
      ),
    );
  }
}