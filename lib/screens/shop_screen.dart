import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/shop_manager.dart';
import '../services/game_manager.dart';
import '../models/shop_item.dart';
import '../utils/number_formatter.dart';

class ShopScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop'),
        centerTitle: true,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: ShopManager.instance),
        ],
        child: Consumer2<ShopManager, GameManager>(
          builder: (context, shopManager, gameManager, child) {
            return Column(
              children: [
                _buildHeader(gameManager),
                _buildActiveBoosts(shopManager),
                Expanded(
                  child: _buildShopGrid(context, shopManager, gameManager),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildHeader(GameManager gameManager) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade100, Colors.purple.shade50],
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
  
  Widget _buildActiveBoosts(ShopManager shopManager) {
    final activeItems = shopManager.activeItems;
    
    if (activeItems.isEmpty) {
      return SizedBox.shrink();
    }
    
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Boosts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
          SizedBox(height: 8),
          Container(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: activeItems.length,
              itemBuilder: (context, index) {
                final item = activeItems[index];
                return _buildActiveBoostCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActiveBoostCard(ShopItem item) {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.duration > 0) ...[
            SizedBox(height: 2),
            Text(
              '${item.remainingTime}m left',
              style: TextStyle(
                fontSize: 10,
                color: Colors.green.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildShopGrid(BuildContext context, ShopManager shopManager, GameManager gameManager) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: shopManager.shopItems.length,
        itemBuilder: (context, index) {
          final item = shopManager.shopItems[index];
          return _buildShopItemCard(context, item, shopManager, gameManager);
        },
      ),
    );
  }
  
  Widget _buildShopItemCard(BuildContext context, ShopItem item, ShopManager shopManager, GameManager gameManager) {
    final canAfford = gameManager.canAfford(item.cost);
    final isPermanentAndOwned = item.isPurchased && item.duration == 0;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: isPermanentAndOwned ? null : () => _showPurchaseDialog(context, item, shopManager, gameManager),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isPermanentAndOwned 
                  ? [Colors.grey.shade200, Colors.grey.shade300]
                  : [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getItemTypeColor(item.type).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getItemTypeIcon(item.type),
                  size: 32,
                  color: _getItemTypeColor(item.type),
                ),
              ),
              SizedBox(height: 8),
              Text(
                item.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isPermanentAndOwned ? Colors.grey : Colors.grey[800],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Expanded(
                child: Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: isPermanentAndOwned ? Colors.grey : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 8),
              if (isPermanentAndOwned)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'OWNED',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: canAfford ? Colors.purple.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '\$${item.cost}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: canAfford ? Colors.purple.shade700 : Colors.red.shade700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getItemTypeColor(ShopItemType type) {
    switch (type) {
      case ShopItemType.energyBoost:
        return Colors.orange;
      case ShopItemType.followerMultiplier:
        return Colors.blue;
      case ShopItemType.moneyMultiplier:
        return Colors.green;
      case ShopItemType.maxEnergyIncrease:
        return Colors.red;
      case ShopItemType.contentSpeedBoost:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getItemTypeIcon(ShopItemType type) {
    switch (type) {
      case ShopItemType.energyBoost:
        return Icons.battery_charging_full;
      case ShopItemType.followerMultiplier:
        return Icons.trending_up;
      case ShopItemType.moneyMultiplier:
        return Icons.attach_money;
      case ShopItemType.maxEnergyIncrease:
        return Icons.fitness_center;
      case ShopItemType.contentSpeedBoost:
        return Icons.speed;
      default:
        return Icons.shopping_cart;
    }
  }
  
  void _showPurchaseDialog(BuildContext context, ShopItem item, ShopManager shopManager, GameManager gameManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.green, size: 20),
                SizedBox(width: 4),
                Text(
                  'Cost: \$${item.cost}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            if (item.duration > 0) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer, color: Colors.orange, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'Duration: ${item.duration} minutes',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: gameManager.canAfford(item.cost)
                ? () async {
                    final success = await shopManager.purchaseItem(item.id, gameManager);
                    Navigator.pop(context);
                    
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.name} purchased!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Purchase failed!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                : null,
            child: Text('Purchase'),
          ),
        ],
      ),
    );
  }
}