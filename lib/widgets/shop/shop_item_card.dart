// lib/widgets/shop/shop_item_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../models/shop_item_model.dart';
import '../../providers/coin_provider.dart';
import '../../theme/app_colors.dart';
import '../animations/bounce_animation.dart';
import '../common/app_card.dart';
import 'purchase_confirmation_dialog.dart';

class ShopItemCard extends StatelessWidget {
  final ShopItemModel item;
  final VoidCallback? onPurchase;

  const ShopItemCard({
    Key? key,
    required this.item,
    this.onPurchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final coinProvider = Provider.of<CoinProvider>(context);
    final isOwned = coinProvider.isItemOwned(item.id);
    final isEquipped = coinProvider.isItemEquipped(item.id);
    final canAfford = coinProvider.coins.amount >= item.price;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BounceAnimation(
      child: AppCard(
        borderColor: item.rarityColor.withOpacity(0.5),
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Header con rareza
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.rarityColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    item.rarityDisplayName,
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: item.rarityColor,
                    ),
                  ),
                  Spacer(),
                  Text(
                    item.typeDisplayName,
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 9,
                      color: item.rarityColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Icono del objeto con efectos
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: item.colors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: item.rarityColor.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Para mascotas y potenciadores, mostrar animación Lottie circular
                            if ((item.type == ShopItemType.pet || item.type == ShopItemType.booster) && item.animationPath != null)
                              ClipOval(
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  child: Transform.scale(
                                    scale: 1.3, // Escalamos para llenar mejor el círculo
                                    child: Lottie.asset(
                                      item.animationPath!,
                                      fit: BoxFit.cover, // Cover para llenar todo el espacio
                                      repeat: true,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Icon(
                                item.icon,
                                color: Colors.white,
                                size: 28,
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

                    // Nombre del objeto
                    Text(
                      item.name,
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Descripción
                    Expanded(
                      flex: 1,
                      child: Text(
                        item.description,
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 10,
                          color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Precio y botón de compra
                    if (isOwned) ...[
                      // Botones para objetos poseídos
                      if (item.type == ShopItemType.pet || item.type == ShopItemType.badge)
                        _buildEquipButton(context, coinProvider, isEquipped)
                      else
                        _buildOwnedIndicator(),
                    ] else ...[
                      // Precio
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: canAfford ? AppColors.star : AppColors.error,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.price.toString(),
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: canAfford ? AppColors.star : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Botón de compra
                      _buildPurchaseButton(context, coinProvider, canAfford),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButton(BuildContext context, CoinProvider coinProvider, bool canAfford) {
    return SizedBox(
      width: double.infinity,
      height: 28,
      child: ElevatedButton(
        onPressed: canAfford ? () => _showPurchaseDialog(context, coinProvider) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canAfford ? item.rarityColor : Colors.grey,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          canAfford ? 'Comprar' : 'Sin monedas',
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEquipButton(BuildContext context, CoinProvider coinProvider, bool isEquipped) {
    return SizedBox(
      width: double.infinity,
      height: 28,
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
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          isEquipped ? 'Desequipar' : 'Equipar',
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOwnedIndicator() {
    return Container(
      width: double.infinity,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success, width: 1),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              'Poseído',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, CoinProvider coinProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PurchaseConfirmationDialog(
          item: item,
          onConfirm: () async {
            final success = await coinProvider.purchaseItem(item);
            if (success && onPurchase != null) {
              onPurchase!();
            }
          },
        );
      },
    );
  }
}