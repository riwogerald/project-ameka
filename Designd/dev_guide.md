### **Step 5: Content Creation Interface**
**Time: 5-6 hours**

1. **widgets/platform_tabs.dart**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_manager.dart';

class PlatformTabs extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;
  
  const PlatformTabs({
    Key? key,
    required this.currentIndex,
    required this.onTabChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer<GameManager>(
      builder: (context, gameManager, child) {
        final platforms = gameManager.currentInfluencer.unlockedPlatforms;
        
        return Container(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: platforms.length,
            itemBuilder: (context, index) {
              final platform = platforms[index];
              final isSelected = index == currentIndex;
              final isUnlocked = platform.isUnlocked;
              
              return GestureDetector(
                onTap: isUnlocked ? () => onTabChanged(index) : null,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.purple : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.purple : Colors.grey[400]!,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPlatformIcon(platform.name),
                        color: isUnlocked 
                            ? (isSelected ? Colors.white : Colors.purple)
                            : Colors.grey,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        platform.name,
                        style: TextStyle(
                          color: isUnlocked 
                              ? (isSelected ? Colors.white : Colors.purple)
                              : Colors.grey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (!isUnlocked) ...[
                        SizedBox(width: 4),
                        Icon(Icons.lock, color: Colors.grey, size: 16),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  IconData _getPlatformIcon(String platformName) {
    switch (platformName.toLowerCase()) {
      case 'tiktok':
        return Icons.music_note;
      case 'instagram':
        return Icons.camera_alt;
      case 'youtube':
        return Icons.play_circle_filled;
      default:
        return Icons.public;
    }
  }
}
```

2. **widgets/content_creation_panel.dart**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_manager.dart';
import '../services/timer_manager.dart';
import '../models/content_type.dart';
import 'content_button.dart';

class ContentCreationPanel extends StatelessWidget {
  final int platformIndex;
  
  const ContentCreationPanel({
    Key? key,
    required this.platformIndex,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer<GameManager>(
      builder: (context, gameManager, child) {
        final platforms = gameManager.currentInfluencer.unlockedPlatforms;
        
        if (platformIndex >= platforms.length) {
          return Center(child: Text('Platform not found'));
        }
        
        final currentPlatform = platforms[platformIndex];
        
        if (!currentPlatform.isUnlocked) {
          return _buildLockedPlatform(currentPlatform);
        }
        
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Content for ${currentPlatform.name}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: currentPlatform.availableContent.length,
                  itemBuilder: (context, index) {
                    final content = currentPlatform.availableContent[index];
                    return ContentButton(
                      contentType: content,
                      onPressed: () => _startContentCreation(context, content),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildLockedPlatform(Platform platform) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '${platform.name} is locked',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Reach ${platform.unlockFollowerRequirement} followers to unlock',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
  
  void _startContentCreation(BuildContext context, ContentType content) {
    final gameManager = Provider.of<GameManager>(context, listen: false);
    final timerManager = Provider.of<TimerManager>(context, listen: false);
    
    // Check if user has enough energy
    if (gameManager.currentInfluencer.energy < content.energyCost) {
      _showNotEnoughEnergyDialog(context);
      return;
    }
    
    // Start content creation with timer
    timerManager.startContentTimer(content, gameManager);
  }
  
  void _showNotEnoughEnergyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Not Enough Energy'),
        content: Text('You need more energy to create this content. Wait for your energy to regenerate or watch an ad to restore it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Show rewarded ad for energy
            },
            child: Text('Watch Ad'),
          ),
        ],
      ),
    );
  }
}
```

3. **widgets/content_button.dart**
```dart
import 'package:flutter/material.dart';
import '../models/content_type.dart';
import '../utils/number_formatter.dart';

class ContentButton extends StatelessWidget {
  final ContentType contentType;
  final VoidCallback onPressed;
  
  const ContentButton({
    Key? key,
    required this.contentType,
    required this.onPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder# Influencer Academy - Detailed Development Breakdown

## **🚀 TECHNOLOGY STACK DECISION**

### **Flutter + Firebase (RECOMMENDED for Maximum Revenue)**
**Why Flutter over Unity:**
- **15-20% higher revenue share** (no Unity fees)
- **Better ad integration** with Google AdMob
- **Smaller app size** = higher download rates
- **Better performance** on low-end devices
- **Easier UI development** for simulation games

**Revenue Comparison:**
```
Unity Route: $1000 gross → ~$475 net (47.5%)
Flutter Route: $1000 gross → ~$650 net (65%)
```

## **PHASE 1: PROJECT FOUNDATION**

### **Step 1: Environment Setup**
**Time: 2-3 hours**

1. **Install Flutter**
   - Download Flutter SDK
   - Install Android Studio
   - Install Flutter and Dart plugins
   - Run `flutter doctor` to verify setup

2. **Create Project**
   ```bash
   flutter create influencer_academy
   cd influencer_academy
   ```

3. **Add Dependencies**
   ```yaml
   # pubspec.yaml
   dependencies:
     flutter:
       sdk: flutter
     firebase_core: ^2.15.1
     cloud_firestore: ^4.8.5
     google_mobile_ads: ^3.0.0
     shared_preferences: ^2.2.0
     provider: ^6.0.5
   ```

4. **Initial Project Structure**
   ```
   lib/
   ├── main.dart
   ├── models/
   ├── screens/
   ├── widgets/
   ├── services/
   └── utils/
   ```

### **Step 2: Core Data Architecture**
**Time: 3-4 hours**

Create these Dart files in order:

1. **models/game_data.dart**
```dart
class InfluencerData {
  String influencerName;
  int followers;
  int money;
  int energy;
  int maxEnergy;
  List<Platform> unlockedPlatforms;
  
  InfluencerData({
    this.influencerName = "NewInfluencer",
    this.followers = 100,
    this.money = 50,
    this.energy = 100,
    this.maxEnergy = 100,
    this.unlockedPlatforms = const [],
  });
  
  Map<String, dynamic> toJson() => {
    'influencerName': influencerName,
    'followers': followers,
    'money': money,
    'energy': energy,
    'maxEnergy': maxEnergy,
    'unlockedPlatforms': unlockedPlatforms.map((p) => p.toJson()).toList(),
  };
  
  factory InfluencerData.fromJson(Map<String, dynamic> json) => InfluencerData(
    influencerName: json['influencerName'],
    followers: json['followers'],
    money: json['money'],
    energy: json['energy'],
    maxEnergy: json['maxEnergy'],
    unlockedPlatforms: (json['unlockedPlatforms'] as List)
        .map((p) => Platform.fromJson(p))
        .toList(),
  );
}
```

2. **models/content_type.dart**
```dart
class ContentType {
  final String name;
  final String iconPath;
  final int baseTime; // in minutes
  final int energyCost;
  final int baseFollowerGain;
  final int baseMoneyGain;
  
  ContentType({
    required this.name,
    required this.iconPath,
    required this.baseTime,
    required this.energyCost,
    required this.baseFollowerGain,
    required this.baseMoneyGain,
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'iconPath': iconPath,
    'baseTime': baseTime,
    'energyCost': energyCost,
    'baseFollowerGain': baseFollowerGain,
    'baseMoneyGain': baseMoneyGain,
  };
  
  factory ContentType.fromJson(Map<String, dynamic> json) => ContentType(
    name: json['name'],
    iconPath: json['iconPath'],
    baseTime: json['baseTime'],
    energyCost: json['energyCost'],
    baseFollowerGain: json['baseFollowerGain'],
    baseMoneyGain: json['baseMoneyGain'],
  );
}
```

3. **models/platform.dart**
```dart
class Platform {
  final String name;
  final String logoPath;
  final List<ContentType> availableContent;
  bool isUnlocked;
  final int unlockFollowerRequirement;
  
  Platform({
    required this.name,
    required this.logoPath,
    required this.availableContent,
    this.isUnlocked = false,
    required this.unlockFollowerRequirement,
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'logoPath': logoPath,
    'availableContent': availableContent.map((c) => c.toJson()).toList(),
    'isUnlocked': isUnlocked,
    'unlockFollowerRequirement': unlockFollowerRequirement,
  };
  
  factory Platform.fromJson(Map<String, dynamic> json) => Platform(
    name: json['name'],
    logoPath: json['logoPath'],
    availableContent: (json['availableContent'] as List)
        .map((c) => ContentType.fromJson(c))
        .toList(),
    isUnlocked: json['isUnlocked'],
    unlockFollowerRequirement: json['unlockFollowerRequirement'],
  );
}
```

### **Step 3: Save/Load System**
**Time: 2-3 hours**

1. **services/save_system.dart**
```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/game_data.dart';

class SaveSystem {
  static const String _gameDataKey = 'game_data';
  
  static Future<void> saveGame(InfluencerData data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data.toJson());
    await prefs.setString(_gameDataKey, jsonString);
  }
  
  static Future<InfluencerData> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_gameDataKey);
    
    if (jsonString != null) {
      final jsonMap = jsonDecode(jsonString);
      return InfluencerData.fromJson(jsonMap);
    }
    
    return _createNewGame();
  }
  
  static InfluencerData _createNewGame() {
    return InfluencerData(
      influencerName: "NewInfluencer",
      followers: 100,
      money: 50,
      energy: 100,
      maxEnergy: 100,
      unlockedPlatforms: _getDefaultPlatforms(),
    );
  }
  
  static List<Platform> _getDefaultPlatforms() {
    return [
      Platform(
        name: "TikTok",
        logoPath: "assets/images/tiktok_logo.png",
        availableContent: _getTikTokContent(),
        isUnlocked: true,
        unlockFollowerRequirement: 0,
      ),
      Platform(
        name: "Instagram",
        logoPath: "assets/images/instagram_logo.png",
        availableContent: _getInstagramContent(),
        isUnlocked: false,
        unlockFollowerRequirement: 1000,
      ),
      Platform(
        name: "YouTube",
        logoPath: "assets/images/youtube_logo.png",
        availableContent: _getYouTubeContent(),
        isUnlocked: false,
        unlockFollowerRequirement: 5000,
      ),
    ];
  }
  
  static List<ContentType> _getTikTokContent() {
    return [
      ContentType(
        name: "Dance Video",
        iconPath: "assets/images/dance_icon.png",
        baseTime: 5,
        energyCost: 10,
        baseFollowerGain: 15,
        baseMoneyGain: 5,
      ),
      ContentType(
        name: "Lip Sync",
        iconPath: "assets/images/lipsync_icon.png",
        baseTime: 3,
        energyCost: 8,
        baseFollowerGain: 10,
        baseMoneyGain: 3,
      ),
      ContentType(
        name: "Comedy Skit",
        iconPath: "assets/images/comedy_icon.png",
        baseTime: 15,
        energyCost: 20,
        baseFollowerGain: 25,
        baseMoneyGain: 8,
      ),
    ];
  }
  
  static List<ContentType> _getInstagramContent() {
    return [
      ContentType(
        name: "Story Post",
        iconPath: "assets/images/story_icon.png",
        baseTime: 2,
        energyCost: 5,
        baseFollowerGain: 8,
        baseMoneyGain: 2,
      ),
      ContentType(
        name: "Photo Post",
        iconPath: "assets/images/photo_icon.png",
        baseTime: 10,
        energyCost: 15,
        baseFollowerGain: 20,
        baseMoneyGain: 6,
      ),
      ContentType(
        name: "Reel",
        iconPath: "assets/images/reel_icon.png",
        baseTime: 30,
        energyCost: 25,
        baseFollowerGain: 40,
        baseMoneyGain: 12,
      ),
    ];
  }
  
  static List<ContentType> _getYouTubeContent() {
    return [
      ContentType(
        name: "Short Video",
        iconPath: "assets/images/short_icon.png",
        baseTime: 60,
        energyCost: 30,
        baseFollowerGain: 50,
        baseMoneyGain: 15,
      ),
      ContentType(
        name: "Tutorial",
        iconPath: "assets/images/tutorial_icon.png",
        baseTime: 180,
        energyCost: 40,
        baseFollowerGain: 80,
        baseMoneyGain: 25,
      ),
      ContentType(
        name: "Live Stream",
        iconPath: "assets/images/live_icon.png",
        baseTime: 720,
        energyCost: 60,
        baseFollowerGain: 150,
        baseMoneyGain: 45,
      ),
    ];
  }
}
```

## **PHASE 2: UI FOUNDATION**

### **Step 4: Main UI Structure**
**Time: 4-5 hours**

1. **main.dart**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/game_manager.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(InfluencerAcademy());
}

class InfluencerAcademy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameManager(),
      child: MaterialApp(
        title: 'Influencer Academy',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

2. **services/game_manager.dart**
```dart
import 'package:flutter/foundation.dart';
import '../models/game_data.dart';
import 'save_system.dart';

class GameManager extends ChangeNotifier {
  InfluencerData _currentInfluencer = InfluencerData();
  
  InfluencerData get currentInfluencer => _currentInfluencer;
  
  GameManager() {
    _loadGame();
  }
  
  Future<void> _loadGame() async {
    _currentInfluencer = await SaveSystem.loadGame();
    notifyListeners();
  }
  
  Future<void> saveGame() async {
    await SaveSystem.saveGame(_currentInfluencer);
  }
  
  void addFollowers(int amount) {
    _currentInfluencer.followers += amount;
    notifyListeners();
    saveGame();
  }
  
  void addMoney(int amount) {
    _currentInfluencer.money += amount;
    notifyListeners();
    saveGame();
  }
  
  void consumeEnergy(int amount) {
    _currentInfluencer.energy = 
        (_currentInfluencer.energy - amount).clamp(0, _currentInfluencer.maxEnergy);
    notifyListeners();
    saveGame();
  }
  
  void regenerateEnergy() {
    if (_currentInfluencer.energy < _currentInfluencer.maxEnergy) {
      _currentInfluencer.energy = 
          (_currentInfluencer.energy + 1).clamp(0, _currentInfluencer.maxEnergy);
      notifyListeners();
      saveGame();
    }
  }
}
```

3. **screens/home_screen.dart**
```dart
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
        elevation: 0,
      ),
      body: Column(
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
      ),
    );
  }
}
```

4. **widgets/top_bar.dart**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_manager.dart';
import '../utils/number_formatter.dart';

class TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameManager>(
      builder: (context, gameManager, child) {
        final data = gameManager.currentInfluencer;
        
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard(
                icon: Icons.people,
                label: 'Followers',
                value: NumberFormatter.format(data.followers),
                color: Colors.blue,
              ),
              _buildStatCard(
                icon: Icons.attach_money,
                label: 'Money',
                value: '\${NumberFormatter.format(data.money)}',
                color: Colors.green,
              ),
              _buildEnergyCard(data.energy, data.maxEnergy),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
  
  Widget _buildEnergyCard(int current, int max) {
    final percentage = current / max;
    
    return Column(
      children: [
        Icon(Icons.battery_charging_full, color: Colors.orange, size: 24),
        Text('Energy', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 4),
        Container(
          width: 60,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey[300],
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: percentage > 0.3 ? Colors.orange : Colors.red,
              ),
            ),
          ),
        ),
        Text('$current/$max', style: TextStyle(fontSize: 10)),
      ],
    );
  }
}
```

### **Step 5: Content Creation Interface**
**Time: 5-6 hours**

1. **ContentCreationPanel.cs**
```csharp
public class ContentCreationPanel : MonoBehaviour
{
    [Header("UI")]
    public Transform contentButtonParent;
    public GameObject contentButtonPrefab;
    public Platform currentPlatform;
    
    void Start()
    {
        GenerateContentButtons();
    }
    
    void GenerateContentButtons()
    {
        foreach(ContentType content in currentPlatform.availableContent)
        {
            GameObject btn = Instantiate(contentButtonPrefab, contentButtonParent);
            ContentButton contentBtn = btn.GetComponent<ContentButton>();
            contentBtn.Setup(content);
        }
    }
}
```

2. **ContentButton.cs**
```csharp
public class ContentButton : MonoBehaviour
{
    public ContentType contentType;
    public Button button;
    public TextMeshProUGUI nameText;
    public TextMeshProUGUI timeText;
    public Image icon;
    
    public void Setup(ContentType content)
    {
        contentType = content;
        nameText.text = content.name;
        timeText.text = content.baseTime + "m";
        icon.sprite = content.icon;
        button.onClick.AddListener(StartContentCreation);
    }
    
    void StartContentCreation()
    {
        TimerManager.Instance.StartContentTimer(contentType);
    }
}
```

## **PHASE 3: CORE GAME MECHANICS**

### **Step 6: Timer System**
**Time: 6-7 hours**

1. **TimerManager.cs** (Complex but crucial)
```csharp
public class TimerManager : MonoBehaviour
{
    public static TimerManager Instance;
    
    [System.Serializable]
    public class ActiveTimer
    {
        public ContentType contentType;
        public float remainingTime;
        public bool isActive;
        public System.DateTime startTime;
    }
    
    public List<ActiveTimer> activeTimers = new List<ActiveTimer>();
    public Transform timerUIParent;
    public GameObject timerUIPrefab;
    
    void Update()
    {
        UpdateActiveTimers();
    }
    
    public void StartContentTimer(ContentType content)
    {
        // Check energy, show ads, start timer
        if (CanCreateContent(content))
        {
            ShowInterstitialAd(() => {
                CreateNewTimer(content);
            });
        }
    }
    
    void CreateNewTimer(ContentType content)
    {
        ActiveTimer newTimer = new ActiveTimer();
        newTimer.contentType = content;
        newTimer.remainingTime = content.baseTime * 60f; // Convert to seconds
        newTimer.isActive = true;
        newTimer.startTime = System.DateTime.Now;
        
        activeTimers.Add(newTimer);
        CreateTimerUI(newTimer);
        
        // Consume energy
        GameManager.Instance.currentInfluencer.energy -= content.energyCost;
    }
}
```

2. **TimerUI.cs**
```csharp
public class TimerUI : MonoBehaviour
{
    public Slider progressSlider;
    public TextMeshProUGUI timeRemainingText;
    public TextMeshProUGUI contentNameText;
    public Button skipButton;
    
    public ActiveTimer linkedTimer;
    
    void Update()
    {
        if (linkedTimer != null && linkedTimer.isActive)
        {
            UpdateTimerDisplay();
        }
    }
    
    public void SkipWithAd()
    {
        AdManager.Instance.ShowRewardedAd(CompleteTimer);
    }
}
```

### **Step 7: Ad Integration**
**Time: 3-4 hours**

1. **Setup Unity Ads**
   - Window → Services → Ads
   - Create Unity Gaming Services account
   - Enable ads for project

2. **AdManager.cs**
```csharp
using UnityEngine.Advertisements;

public class AdManager : MonoBehaviour, IUnityAdsInitializationListener, IUnityAdsLoadListener, IUnityAdsShowListener
{
    public static AdManager Instance;
    
    [Header("Ad Settings")]
    public string gameId = "YourGameID";
    public string interstitialAdId = "Interstitial_Android";
    public string rewardedAdId = "Rewarded_Android";
    
    private int adsShownThisHour = 0;
    private System.DateTime lastAdResetTime;
    
    void Start()
    {
        Advertisement.Initialize(gameId, false, this);
        lastAdResetTime = System.DateTime.Now;
    }
    
    public void ShowInterstitialAd(System.Action onComplete = null)
    {
        if (CanShowAd())
        {
            Advertisement.Show(interstitialAdId, this);
            adsShownThisHour++;
            // Execute callback after ad
        }
        else
        {
            onComplete?.Invoke(); // Skip ad if limit reached
        }
    }
    
    bool CanShowAd()
    {
        // Reset counter every hour
        if ((System.DateTime.Now - lastAdResetTime).TotalHours >= 1)
        {
            adsShownThisHour = 0;
            lastAdResetTime = System.DateTime.Now;
        }
        
        return adsShownThisHour < 3;
    }
}
```

### **Step 8: Game Economy**
**Time: 4-5 hours**

1. **EconomyManager.cs**
```csharp
public class EconomyManager : MonoBehaviour
{
    public static EconomyManager Instance;
    
    public void CompleteContent(ContentType content)
    {
        var influencer = GameManager.Instance.currentInfluencer;
        
        // Calculate rewards based on followers and content type
        int followerGain = CalculateFollowerGain(content);
        int moneyGain = CalculateMoneyGain(content);
        
        influencer.followers += followerGain;
        influencer.money += moneyGain;
        
        // Show reward popup
        ShowRewardPopup(followerGain, moneyGain);
        
        // Check for platform unlocks
        CheckPlatformUnlocks();
        
        // Save game
        SaveSystem.SaveGame(influencer);
    }
    
    int CalculateFollowerGain(ContentType content)
    {
        float multiplier = 1f + (GameManager.Instance.currentInfluencer.followers / 10000f);
        return Mathf.RoundToInt(content.baseFollowerGain * multiplier);
    }
}
```

## **PHASE 4: POLISH & FEATURES**

### **Step 9: Shop System**
**Time: 4-5 hours**

1. **ShopManager.cs**
```csharp
[System.Serializable]
public class ShopItem
{
    public string name;
    public string description;
    public int cost;
    public Sprite icon;
    public ShopItemType type;
    public int effectValue;
    public bool isPurchased;
}

public enum ShopItemType
{
    EnergyBoost,
    FollowerMultiplier,
    MoneyMultiplier,
    PlatformUnlock
}
```

### **Step 10: Animations & Polish**
**Time: 3-4 hours**

1. **Simple UI Animations**
```csharp
public class UIAnimations : MonoBehaviour
{
    public static void ScaleButton(Transform target)
    {
        target.DOScale(0.95f, 0.1f).OnComplete(() => {
            target.DOScale(1f, 0.1f);
        });
    }
    
    public static void CountUpText(TextMeshProUGUI text, int startValue, int endValue)
    {
        DOTween.To(() => startValue, x => {
            text.text = x.ToString();
        }, endValue, 1f);
    }
}
```

### **Step 11: Audio Integration**
**Time: 2-3 hours**

1. **AudioManager.cs**
```csharp
public class AudioManager : MonoBehaviour
{
    public static AudioManager Instance;
    
    [Header("Audio Sources")]
    public AudioSource musicSource;
    public AudioSource sfxSource;
    
    [Header("Audio Clips")]
    public AudioClip buttonClick;
    public AudioClip contentComplete;
    public AudioClip moneyEarn;
    
    public void PlaySFX(AudioClip clip)
    {
        if (clip != null)
            sfxSource.PlayOneShot(clip);
    }
}
```

## **PHASE 5: TESTING & RELEASE**

### **Step 12: Build & Test**
**Time: 2-3 hours**

1. **Android Build Settings**
   - File → Build Settings → Android
   - Set minimum API level 24
   - Set target API level 33+
   - Configure keystore for release

2. **Testing Checklist**
   - [ ] All buttons respond
   - [ ] Timers work correctly
   - [ ] Ads display properly
   - [ ] Save/load functions
   - [ ] No crashes on different screen sizes

### **Step 13: Store Preparation**
**Time: 4-5 hours**

1. **Create Store Assets**
   - App icon (512x512)
   - Screenshots (at least 2)
   - Feature graphic (1024x500)
   - Store description

2. **Google Play Console Setup**
   - Upload APK
   - Set content rating
   - Add privacy policy
   - Configure in-app products (if needed)

## **TOTAL DEVELOPMENT TIME ESTIMATE**
- **Programming**: 35-45 hours
- **Art/UI**: 15-20 hours  
- **Testing/Polish**: 10-15 hours
- **Store Setup**: 5-8 hours

**Total: 65-88 hours** (8-11 weeks part-time)

## **FREE TOOLS & RESOURCES**

### **Development**
- Unity Personal (free)
- Visual Studio Community (free)
- Git for version control (free)

### **Art & Audio**
- OpenGameArt.org - free sprites
- Freesound.org - free sound effects
- Canva - free graphics creation
- GIMP - free image editing

### **Monetization**
- Unity Ads - free, revenue share
- Unity Analytics - free
- Google Play Console - $25 one-time

## **SIMPLE STARTING FEATURES**

### **MVP (Minimum Viable Product)**
1. **Single Influencer Management**
2. **3 Platforms** (TikTok, Instagram, YouTube)
3. **8 Content Types** (Dance, Review, Tutorial, etc.)
4. **Basic Shop** (Equipment upgrades)
5. **Timer System** with ad-skip option
6. **Simple Progression** (follower milestones)

### **Update 1 Features** (Post-launch)
- Multiple influencers
- Collaborations
- Trending topics system
- More platforms and content types

## **KEY SUCCESS TIPS**

1. **Start Simple**: Build MVP first, add features later
2. **Test Early**: Get feedback from day one
3. **Focus on Fun**: Make the core loop engaging
4. **Track Metrics**: Use analytics to guide updates
5. **Community**: Build social media presence early

## **DEVELOPMENT PHASES SUMMARY**

### **Phase 1: Foundation (Week 1-2)**
- Project setup and core architecture
- Data structures and save system
- Basic UI framework

### **Phase 2: Core Mechanics (Week 3-6)**
- Timer system implementation
- Content creation mechanics
- Ad integration
- Game economy

### **Phase 3: Features & Polish (Week 7-10)**
- Shop system
- UI animations and polish
- Audio integration
- Bug fixes and optimization

### **Phase 4: Launch Preparation (Week 11-12)**
- Store assets creation
- Final testing
- Google Play Console setup
- Launch and initial marketing

## **CRITICAL DEVELOPMENT NOTES**

- **Save frequently**: Implement autosave after every major action
- **Test on different devices**: Ensure compatibility across screen sizes
- **Performance optimization**: Profile regularly, especially timer updates
- **Ad integration testing**: Test thoroughly in development mode
- **Backup strategy**: Use version control (Git) from day one

This development guide provides a comprehensive roadmap for creating Influencer Academy as a solo developer with zero budget. Follow the phases sequentially, and don't skip the testing phases - they're crucial for a successful launch.