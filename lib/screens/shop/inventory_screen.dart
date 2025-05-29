// lib/screens/shop/inventory_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../providers/coin_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/shop_item_model.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/shop/coin_display_widget.dart';
import '../../widgets/common/app_card.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final coinProvider = Provider.of<CoinProvider>(context);
    final ownedItems = coinProvider.ownedItems;
    final equippedItems = coinProvider.equippedItems;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context),
            
            // Contenido
            Expanded(
              child: ownedItems.isEmpty
                  ? _buildEmptyInventory(context)
                  : _buildInventoryContent(ownedItems, equippedItems, coinProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.7),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.inventory,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mi Inventario',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          CoinDisplayWidget.large(
            backgroundColor: Colors.white.withOpacity(0.2),
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyInventory(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              '¡Tu inventario está vacío!',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Visita la tienda para adoptar mascotas y comprar objetos geniales',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/shop');
              },
              icon: Icon(Icons.pets),
              label: Text(
                'Ir a la Tienda',
                style: TextStyle(fontFamily: 'Comic Sans MS'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryContent(
    List<ShopItemModel> ownedItems,
    List<ShopItemModel> equippedItems,
    CoinProvider coinProvider,
  ) {
    // Agrupar items por tipo
    final Map<ShopItemType, List<ShopItemModel>> itemsByType = {};
    for (var item in ownedItems) {
      if (!itemsByType.containsKey(item.type)) {
        itemsByType[item.type] = [];
      }
      itemsByType[item.type]!.add(item);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen de objetos equipados
          if (equippedItems.isNotEmpty) ...[
            FadeAnimation(
              child: _buildEquippedSection(equippedItems),
            ),
            const SizedBox(height: 24),
          ],

          // Items por categoría
          ...itemsByType.entries.map((entry) {
            return FadeAnimation(
              delay: Duration(milliseconds: 200),
              child: _buildItemTypeSection(entry.key, entry.value, coinProvider),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEquippedSection(List<ShopItemModel> equippedItems) {
    return AppCard(
      backgroundColor: AppColors.success.withOpacity(0.1),
      borderColor: AppColors.success.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Objetos Equipados',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: equippedItems.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: item.colors),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Para mascotas, mostrar animación pequeña
                    if (item.type == ShopItemType.pet && item.animationPath != null)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Lottie.asset(
                          item.animationPath!,
                          fit: BoxFit.contain,
                        ),
                      )
                    else
                      Icon(
                        item.icon,
                        color: Colors.white,
                        size: 16,
                      ),
                    const SizedBox(width: 4),
                    Text(
                      item.name,
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTypeSection(
    ShopItemType type,
    List<ShopItemModel> items,
    CoinProvider coinProvider,
  ) {
    String typeName;
    IconData typeIcon;
    
    switch (type) {
      case ShopItemType.pet:
        typeName = 'Mascotas';
        typeIcon = Icons.pets;
        break;
      case ShopItemType.booster:
        typeName = 'Potenciadores';
        typeIcon = Icons.speed;
        break;
      case ShopItemType.theme:
        typeName = 'Temas';
        typeIcon = Icons.palette;
        break;
      case ShopItemType.badge:
        typeName = 'Insignias';
        typeIcon = Icons.military_tech;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                typeIcon,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                typeName,
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isEquipped = coinProvider.isItemEquipped(item.id);
              
              return _buildInventoryItemCard(item, isEquipped, coinProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItemCard(
    ShopItemModel item,
    bool isEquipped,
    CoinProvider coinProvider,
  ) {
    return AppCard(
      borderColor: item.rarityColor.withOpacity(0.5),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: item.colors),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Para mascotas y potenciadores, mostrar animación circular
                  if ((item.type == ShopItemType.pet || item.type == ShopItemType.booster) && item.animationPath != null)
                    ClipOval(
                      child: Container(
                        width: 50,
                        height: 50,
                        child: Transform.scale(
                          scale: 1.3, // Escalamos para llenar mejor el círculo
                          child: Lottie.asset(
                            item.animationPath!,
                            fit: BoxFit.cover, // Cover para llenar todo el espacio
                          ),
                        ),
                      ),
                    )
                  else
                    Icon(
                      item.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  if (isEquipped)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          if (item.type == ShopItemType.pet || item.type == ShopItemType.badge)
            SizedBox(
              width: double.infinity,
              height: 24,
              child: ElevatedButton(
                onPressed: () {
                  if (isEquipped) {
                    coinProvider.unequipItem(item);
                  } else {
                    coinProvider.equipItem(item);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEquipped ? AppColors.error : AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  isEquipped ? 'Quitar' : 'Usar',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 24,
              decoration: BoxDecoration(
                color: item.rarityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  item.typeDisplayName,
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: item.rarityColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}