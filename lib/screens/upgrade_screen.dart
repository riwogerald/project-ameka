import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/upgrade_manager.dart';
import '../services/game_manager.dart';
import '../models/platform_upgrade.dart';
import '../utils/number_formatter.dart';

class UpgradeScreen extends StatefulWidget {
  @override
  _UpgradeScreenState createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPlatform = 'TipPot';
  UpgradeCategory _selectedCategory = UpgradeCategory.equipment;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upgrades'),
        centerTitle: true,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'TipPot'),
            Tab(text: 'TheGram'),
            Tab(text: 'Yutub'),
            Tab(text: 'Mastery'),
          ],
        ),
      ),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: UpgradeManager.instance),
        ],
        child: Consumer2<UpgradeManager, GameManager>(
          builder: (context, upgradeManager, gameManager, child) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildPlatformUpgrades('TipPot', upgradeManager, gameManager),
                _buildPlatformUpgrades('TheGram', upgradeManager, gameManager),
                _buildPlatformUpgrades('Yutub', upgradeManager, gameManager),
                _buildMasteryView(upgradeManager, gameManager),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildPlatformUpgrades(String platformId, UpgradeManager upgradeManager, GameManager gameManager) {
    final upgrades = upgradeManager.platformUpgrades[platformId] ?? [];
    
    return Column(
      children: [
        _buildCategoryFilter(),
        Expanded(
          child: _buildUpgradeGrid(upgrades, upgradeManager, gameManager),
        ),
      ],
    );
  }
  
  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: UpgradeCategory.values.map((category) {
          final isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.purple : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.purple : Colors.grey[400]!,
                ),
              ),
              child: Center(
                child: Text(
                  _getCategoryName(category),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  String _getCategoryName(UpgradeCategory category) {
    switch (category) {
      case UpgradeCategory.equipment:
        return 'Equipment';
      case UpgradeCategory.skills:
        return 'Skills';
      case UpgradeCategory.audience:
        return 'Audience';
      case UpgradeCategory.monetization:
        return 'Monetization';
      case UpgradeCategory.efficiency:
        return 'Efficiency';
    }
  }
  
  Widget _buildUpgradeGrid(List<PlatformUpgrade> allUpgrades, UpgradeManager upgradeManager, GameManager gameManager) {
    final filteredUpgrades = allUpgrades
        .where((upgrade) => upgrade.category == _selectedCategory)
        .toList();
    
    if (filteredUpgrades.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No ${_getCategoryName(_selectedCategory).toLowerCase()} upgrades available',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredUpgrades.length,
      itemBuilder: (context, index) {
        final upgrade = filteredUpgrades[index];
        return _buildUpgradeCard(upgrade, upgradeManager, gameManager);
      },
    );
  }
  
  Widget _buildUpgradeCard(PlatformUpgrade upgrade, UpgradeManager upgradeManager, GameManager gameManager) {
    final canAfford = gameManager.canAfford(upgrade.nextLevelCost);
    final canUpgrade = upgrade.canUpgrade(upgradeManager.platformUpgrades.values.expand((x) => x).fold<Map<String, PlatformUpgrade>>({}, (map, u) { map[u.id] = u; return map; }));
    final isMaxLevel = upgrade.isMaxLevel;
    
    return Card(
      elevation: upgrade.isUnlocked ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: upgrade.isUnlocked && canUpgrade && canAfford && !isMaxLevel
            ? () => _showUpgradeDialog(upgrade, upgradeManager, gameManager)
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: upgrade.isUnlocked
                  ? [Colors.white, Colors.grey.shade50]
                  : [Colors.grey.shade200, Colors.grey.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(upgrade.category).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getUpgradeIcon(upgrade.type),
                      size: 24,
                      color: upgrade.isUnlocked 
                          ? _getCategoryColor(upgrade.category)
                          : Colors.grey,
                    ),
                  ),
                  Spacer(),
                  if (!upgrade.isUnlocked)
                    Icon(Icons.lock, color: Colors.grey, size: 20),
                ],
              ),
              SizedBox(height: 8),
              Text(
                upgrade.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: upgrade.isUnlocked ? Colors.grey[800] : Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                upgrade.description,
                style: TextStyle(
                  fontSize: 11,
                  color: upgrade.isUnlocked ? Colors.grey[600] : Colors.grey,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              _buildLevelIndicator(upgrade),
              SizedBox(height: 8),
              if (upgrade.isUnlocked && !isMaxLevel)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: canAfford ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '\$${upgrade.nextLevelCost}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: canAfford ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                )
              else if (isMaxLevel)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'MAX LEVEL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLevelIndicator(PlatformUpgrade upgrade) {
    return Row(
      children: [
        Text(
          'Level ${upgrade.currentLevel}/${upgrade.maxLevel}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        Spacer(),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Colors.grey[300],
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: upgrade.currentLevel / upgrade.maxLevel,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: _getCategoryColor(upgrade.category),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMasteryView(UpgradeManager upgradeManager, GameManager gameManager) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: upgradeManager.masteries.length,
      itemBuilder: (context, index) {
        final mastery = upgradeManager.masteries[index];
        return _buildMasteryCard(mastery, upgradeManager);
      },
    );
  }
  
  Widget _buildMasteryCard(InfluencerMastery mastery, UpgradeManager upgradeManager) {
    return Card(
      elevation: mastery.isUnlocked ? 6 : 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: mastery.isUnlocked
                ? [Colors.purple.shade50, Colors.purple.shade100]
                : [Colors.grey.shade100, Colors.grey.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: mastery.isUnlocked 
                        ? Colors.purple.shade200
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    mastery.isUnlocked ? Icons.star : Icons.star_border,
                    size: 32,
                    color: mastery.isUnlocked ? Colors.purple.shade700 : Colors.grey,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mastery.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: mastery.isUnlocked ? Colors.purple.shade700 : Colors.grey,
                        ),
                      ),
                      Text(
                        mastery.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: mastery.isUnlocked ? Colors.purple.shade600 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!mastery.isUnlocked)
                  Icon(Icons.lock, color: Colors.grey, size: 24),
              ],
            ),
            SizedBox(height: 12),
            if (mastery.isUnlocked)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Bonus: +${(mastery.globalBonus * 100).toInt()}% to all relevant stats',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              )
            else
              _buildMasteryRequirements(mastery, upgradeManager),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMasteryRequirements(InfluencerMastery mastery, UpgradeManager upgradeManager) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requirements:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '• ${mastery.requiredPlatformLevels} total upgrade levels',
            style: TextStyle(fontSize: 12, color: Colors.orange.shade600),
          ),
          ...mastery.typeRequirements.entries.map((entry) => Text(
            '• ${entry.value} levels in ${_getUpgradeTypeName(entry.key)}',
            style: TextStyle(fontSize: 12, color: Colors.orange.shade600),
          )),
        ],
      ),
    );
  }
  
  String _getUpgradeTypeName(UpgradeType type) {
    return type.toString().split('.').last;
  }
  
  Color _getCategoryColor(UpgradeCategory category) {
    switch (category) {
      case UpgradeCategory.equipment:
        return Colors.blue;
      case UpgradeCategory.skills:
        return Colors.green;
      case UpgradeCategory.audience:
        return Colors.orange;
      case UpgradeCategory.monetization:
        return Colors.purple;
      case UpgradeCategory.efficiency:
        return Colors.red;
    }
  }
  
  IconData _getUpgradeIcon(UpgradeType type) {
    switch (type) {
      case UpgradeType.camera:
        return Icons.camera_alt;
      case UpgradeType.microphone:
        return Icons.mic;
      case UpgradeType.lighting:
        return Icons.lightbulb;
      case UpgradeType.editingSoftware:
        return Icons.edit;
      case UpgradeType.creativity:
        return Icons.palette;
      case UpgradeType.charisma:
        return Icons.person;
      case UpgradeType.technical:
        return Icons.settings;
      case UpgradeType.marketing:
        return Icons.trending_up;
      case UpgradeType.engagement:
        return Icons.favorite;
      case UpgradeType.reach:
        return Icons.public;
      case UpgradeType.retention:
        return Icons.repeat;
      case UpgradeType.demographics:
        return Icons.people;
      case UpgradeType.sponsorships:
        return Icons.handshake;
      case UpgradeType.merchandise:
        return Icons.shopping_bag;
      case UpgradeType.donations:
        return Icons.volunteer_activism;
      case UpgradeType.adRevenue:
        return Icons.monetization_on;
      case UpgradeType.speed:
        return Icons.speed;
      case UpgradeType.energy:
        return Icons.battery_charging_full;
      case UpgradeType.automation:
        return Icons.smart_toy;
      case UpgradeType.batch:
        return Icons.layers;
    }
  }
  
  void _showUpgradeDialog(PlatformUpgrade upgrade, UpgradeManager upgradeManager, GameManager gameManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(upgrade.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(upgrade.description),
            SizedBox(height: 16),
            Text(
              'Current Level: ${upgrade.currentLevel}/${upgrade.maxLevel}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Current Effect: +${(upgrade.currentEffect * 100).toStringAsFixed(1)}%',
              style: TextStyle(color: Colors.green),
            ),
            Text(
              'Next Level Effect: +${(upgrade.nextLevelEffect * 100).toStringAsFixed(1)}%',
              style: TextStyle(color: Colors.blue),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.green, size: 20),
                SizedBox(width: 4),
                Text(
                  'Cost: \$${upgrade.nextLevelCost}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await upgradeManager.purchaseUpgrade(
                upgrade.id,
                upgrade.platformId,
                gameManager,
              );
              
              Navigator.pop(context);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${upgrade.name} upgraded to level ${upgrade.currentLevel}!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Upgrade failed!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}