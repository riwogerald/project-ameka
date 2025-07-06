import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/equipment_manager.dart';
import '../services/game_manager.dart';
import '../models/equipment.dart';
import '../utils/number_formatter.dart';

class EquipmentScreen extends StatefulWidget {
  @override
  _EquipmentScreenState createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  EquipmentCategory _selectedCategory = EquipmentCategory.camera;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: Text('Equipment'),
        centerTitle: true,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Shop'),
            Tab(text: 'Loadouts'),
          ],
        ),
      ),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: EquipmentManager.instance),
        ],
        child: Consumer2<EquipmentManager, GameManager>(
          builder: (context, equipmentManager, gameManager, child) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildShopView(equipmentManager, gameManager),
                _buildLoadoutView(equipmentManager, gameManager),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildShopView(EquipmentManager equipmentManager, GameManager gameManager) {
    return Column(
      children: [
        _buildMoneyHeader(gameManager),
        _buildCategoryFilter(),
        Expanded(
          child: _buildEquipmentGrid(equipmentManager, gameManager, false),
        ),
      ],
    );
  }
  
  Widget _buildLoadoutView(EquipmentManager equipmentManager, GameManager gameManager) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.purple,
            tabs: [
              Tab(text: 'TipPot'),
              Tab(text: 'TheGram'),
              Tab(text: 'Yutub'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildPlatformLoadout('TipPot', equipmentManager),
                _buildPlatformLoadout('TheGram', equipmentManager),
                _buildPlatformLoadout('Yutub', equipmentManager),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMoneyHeader(GameManager gameManager) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade100, Colors.green.shade50],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.attach_money, color: Colors.green, size: 24),
          SizedBox(width: 8),
          Text(
            'Money: \$${NumberFormatter.format(gameManager.currentInfluencer.money)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: EquipmentCategory.values.map((category) {
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
  
  String _getCategoryName(EquipmentCategory category) {
    switch (category) {
      case EquipmentCategory.camera:
        return 'Camera';
      case EquipmentCategory.audio:
        return 'Audio';
      case EquipmentCategory.lighting:
        return 'Lighting';
      case EquipmentCategory.editing:
        return 'Editing';
      case EquipmentCategory.streaming:
        return 'Streaming';
      case EquipmentCategory.accessories:
        return 'Accessories';
    }
  }
  
  Widget _buildEquipmentGrid(EquipmentManager equipmentManager, GameManager gameManager, bool ownedOnly) {
    List<Equipment> equipment;
    
    if (ownedOnly) {
      equipment = equipmentManager.ownedEquipment
          .where((e) => e.category == _selectedCategory)
          .toList();
    } else {
      equipment = equipmentManager.allEquipment
          .where((e) => e.category == _selectedCategory)
          .toList();
    }
    
    if (equipment.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              ownedOnly ? 'No equipment owned in this category' : 'No equipment available',
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
        childAspectRatio: 0.7,
      ),
      itemCount: equipment.length,
      itemBuilder: (context, index) {
        final item = equipment[index];
        return _buildEquipmentCard(item, equipmentManager, gameManager, ownedOnly);
      },
    );
  }
  
  Widget _buildEquipmentCard(Equipment equipment, EquipmentManager equipmentManager, GameManager gameManager, bool ownedOnly) {
    final canAfford = gameManager.canAfford(equipment.cost);
    final canPurchase = equipmentManager.getAvailableEquipment().contains(equipment);
    
    return Card(
      elevation: equipment.isOwned ? 6 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: equipment.isOwned || (canPurchase && canAfford)
            ? () => _showEquipmentDialog(equipment, equipmentManager, gameManager)
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: equipment.isOwned
                  ? [Colors.white, equipment.tierColor.withOpacity(0.1)]
                  : [Colors.grey.shade200, Colors.grey.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: equipment.isEquipped 
                ? Border.all(color: Colors.green, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: equipment.tierColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getEquipmentIcon(equipment.category),
                      size: 24,
                      color: equipment.isOwned ? equipment.tierColor : Colors.grey,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: equipment.tierColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      equipment.tierName,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                equipment.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: equipment.isOwned ? Colors.grey[800] : Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                equipment.description,
                style: TextStyle(
                  fontSize: 11,
                  color: equipment.isOwned ? Colors.grey[600] : Colors.grey,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              if (equipment.isEquipped)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'EQUIPPED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                )
              else if (equipment.isOwned)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'OWNED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                )
              else if (canPurchase)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: canAfford ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '\$${NumberFormatter.format(equipment.cost)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: canAfford ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'LOCKED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPlatformLoadout(String platformId, EquipmentManager equipmentManager) {
    final loadout = equipmentManager.platformLoadouts[platformId];
    if (loadout == null) return SizedBox.shrink();
    
    return Column(
      children: [
        _buildLoadoutStats(loadout),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16),
            children: EquipmentCategory.values.map((category) {
              final equippedItem = loadout.equippedItems[category];
              return _buildLoadoutSlot(category, equippedItem, platformId, equipmentManager);
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoadoutStats(EquipmentLoadout loadout) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.purple.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${loadout.platformId} Loadout Bonuses',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
          SizedBox(height: 8),
          _buildStatRow('Followers', '+${(loadout.getTotalBonus('followers') * 100).toStringAsFixed(1)}%'),
          _buildStatRow('Money', '+${(loadout.getTotalBonus('money') * 100).toStringAsFixed(1)}%'),
          _buildStatRow('Quality', '+${(loadout.getTotalBonus('content_quality') * 100).toStringAsFixed(1)}%'),
          _buildStatRow('Speed', '+${(loadout.getTotalBonus('creation_speed') * 100).toStringAsFixed(1)}%'),
        ],
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.purple.shade600),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadoutSlot(EquipmentCategory category, Equipment? equippedItem, String platformId, EquipmentManager equipmentManager) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getEquipmentIcon(category),
            color: Colors.purple.shade700,
          ),
        ),
        title: Text(_getCategoryName(category)),
        subtitle: Text(equippedItem?.name ?? 'No equipment equipped'),
        trailing: equippedItem != null
            ? IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  equipmentManager.unequipItem(platformId, category);
                },
              )
            : Icon(Icons.add_circle_outline, color: Colors.grey),
        onTap: () => _showEquipmentSelector(category, platformId, equipmentManager),
      ),
    );
  }
  
  IconData _getEquipmentIcon(EquipmentCategory category) {
    switch (category) {
      case EquipmentCategory.camera:
        return Icons.camera_alt;
      case EquipmentCategory.audio:
        return Icons.mic;
      case EquipmentCategory.lighting:
        return Icons.lightbulb;
      case EquipmentCategory.editing:
        return Icons.edit;
      case EquipmentCategory.streaming:
        return Icons.live_tv;
      case EquipmentCategory.accessories:
        return Icons.build;
    }
  }
  
  void _showEquipmentDialog(Equipment equipment, EquipmentManager equipmentManager, GameManager gameManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(equipment.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(equipment.description),
              SizedBox(height: 16),
              Text(
                'Tier: ${equipment.tierName}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: equipment.tierColor,
                ),
              ),
              SizedBox(height: 12),
              if (equipment.platformBonuses.isNotEmpty) ...[
                Text(
                  'Platform Bonuses:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...equipment.platformBonuses.entries.map((entry) => Text(
                  '• ${entry.key}: +${(entry.value * 100).toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 12),
                )),
                SizedBox(height: 8),
              ],
              if (equipment.globalBonuses.isNotEmpty) ...[
                Text(
                  'Global Bonuses:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...equipment.globalBonuses.entries.map((entry) => Text(
                  '• ${entry.key}: +${(entry.value * 100).toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 12),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          if (!equipment.isOwned && equipmentManager.getAvailableEquipment().contains(equipment))
            ElevatedButton(
              onPressed: gameManager.canAfford(equipment.cost)
                  ? () async {
                      final success = await equipmentManager.purchaseEquipment(equipment.id, gameManager);
                      Navigator.pop(context);
                      
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${equipment.name} purchased!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  : null,
              child: Text('Buy for \$${NumberFormatter.format(equipment.cost)}'),
            ),
        ],
      ),
    );
  }
  
  void _showEquipmentSelector(EquipmentCategory category, String platformId, EquipmentManager equipmentManager) {
    final availableEquipment = equipmentManager.ownedEquipment
        .where((e) => e.category == category)
        .toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select ${_getCategoryName(category)}'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: availableEquipment.isEmpty
              ? Center(child: Text('No equipment owned in this category'))
              : ListView.builder(
                  itemCount: availableEquipment.length,
                  itemBuilder: (context, index) {
                    final equipment = availableEquipment[index];
                    return ListTile(
                      leading: Icon(
                        _getEquipmentIcon(category),
                        color: equipment.tierColor,
                      ),
                      title: Text(equipment.name),
                      subtitle: Text(equipment.tierName),
                      onTap: () {
                        equipmentManager.equipItem(equipment.id, platformId);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
}