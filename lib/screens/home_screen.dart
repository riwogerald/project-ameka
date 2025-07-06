import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_manager.dart';
import '../services/timer_manager.dart';
import '../widgets/top_bar.dart';
import '../widgets/platform_tabs.dart';
import '../widgets/content_creation_panel.dart';
import '../widgets/active_timers_panel.dart';
import '../widgets/banner_ad_widget.dart';
import '../screens/shop_screen.dart';
import '../screens/upgrade_screen.dart';
import '../screens/equipment_screen.dart';
import '../screens/settings_screen.dart';

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
            icon: Icon(Icons.build),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EquipmentScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.upgrade),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpgradeScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShopScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
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
                BannerAdWidget(),
              ],
            );
          },
        ),
      ),
    );
  }
}