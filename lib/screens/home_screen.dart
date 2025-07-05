import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_manager.dart';
import '../widgets/top_bar.dart';
import '../widgets/platform_tabs.dart';
import '../widgets/content_creation_panel.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPlatformIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Influencer Academy'),
        centerTitle: true,
      ),
      body: Consumer<GameManager>(
        builder: (context, gameManager, child) {
          if (gameManager.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
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
            ],
          );
        },
      ),
    );
  }
}