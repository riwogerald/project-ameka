import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/game_manager.dart';
import 'services/ad_manager.dart';
import 'services/shop_manager.dart';
import 'services/audio_manager.dart';
import 'services/upgrade_manager.dart';
import 'services/equipment_manager.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await AdManager.instance.initialize();
  await ShopManager.instance.initialize();
  await AudioManager.instance.initialize();
  await UpgradeManager.instance.initialize();
  await EquipmentManager.instance.initialize();
  
  runApp(InfluencerAcademy());
}

class InfluencerAcademy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GameManager()),
        ChangeNotifierProvider.value(value: AdManager.instance),
        ChangeNotifierProvider.value(value: ShopManager.instance),
        ChangeNotifierProvider.value(value: UpgradeManager.instance),
        ChangeNotifierProvider.value(value: EquipmentManager.instance),
      ],
      child: MaterialApp(
        title: 'Influencer Academy',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Roboto',
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}