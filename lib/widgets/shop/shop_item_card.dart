// lib/widgets/shop/shop_item_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

// lib/widgets/shop/shop_item_card.dart (solo las partes modificadas)

// En el método build, cambiar la estructura:
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
      padding: EdgeInsets.zero, // Quitar padding por defecto
      child: Column(
        children: [
          // Header con rareza - Reducir padding
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reducido
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
                    fontSize: 10, // Reducido
                    fontWeight: FontWeight.bold,
                    color: item.rarityColor,
                  ),
                ),
                Spacer(),
                Text(
                  item.typeDisplayName,
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 9, // Reducido
                    color: item.rarityColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Reducido padding
              child: Column(
                children: [
                  // Icono del objeto con efectos
                  Expanded(
                    flex: 2, // Cambiar proporción
                    child: Container(
                      width: 60, // Reducir tamaño
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
                            blurRadius: 6, // Reducido
                            offset: const Offset(0, 2), // Reducido
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            item.icon,
                            color: Colors.white,
                            size: 28, // Reducido
                          ),
                          if (isEquipped)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 16, // Reducido
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
                      fontSize: 14, // Reducido
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
                    flex: 1, // Cambiar proporción
                    child: Text(
                      item.description,
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 10, // Reducido
                        color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 6), // Reducido

                  // Precio y botón de compra
                  if (isOwned) ...[
                    // Botones para objetos poseídos
                    if (item.type == ShopItemType.accessory || item.type == ShopItemType.badge)
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
                          size: 14, // Reducido
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.price.toString(),
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 12, // Reducido
                            fontWeight: FontWeight.bold,
                            color: canAfford ? AppColors.star : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6), // Reducido
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

// Actualizar también los métodos de botones para que sean más compactos:
Widget _buildPurchaseButton(BuildContext context, CoinProvider coinProvider, bool canAfford) {
  return SizedBox(
    width: double.infinity,
    height: 28, // Reducido
    child: ElevatedButton(
      onPressed: canAfford ? () => _showPurchaseDialog(context, coinProvider) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: canAfford ? item.rarityColor : Colors.grey,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade300,
        disabledForegroundColor: Colors.grey.shade600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14), // Reducido
        ),
        padding: EdgeInsets.zero,
      ),
      child: Text(
        canAfford ? 'Comprar' : 'Sin monedas',
        style: TextStyle(
          fontFamily: 'Comic Sans MS',
          fontSize: 11, // Reducido
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Widget _buildEquipButton(BuildContext context, CoinProvider coinProvider, bool isEquipped) {
  return SizedBox(
    width: double.infinity,
    height: 28, // Reducido
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
          borderRadius: BorderRadius.circular(14), // Reducido
        ),
        padding: EdgeInsets.zero,
      ),
      child: Text(
        isEquipped ? 'Desequipar' : 'Equipar',
        style: TextStyle(
          fontFamily: 'Comic Sans MS',
          fontSize: 11, // Reducido
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Widget _buildOwnedIndicator() {
  return Container(
    width: double.infinity,
    height: 28, // Reducido
    decoration: BoxDecoration(
      color: AppColors.success.withOpacity(0.2),
      borderRadius: BorderRadius.circular(14), // Reducido
      border: Border.all(color: AppColors.success, width: 1),
    ),
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 14, // Reducido
          ),
          const SizedBox(width: 4),
          Text(
            'Poseído',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 11, // Reducido
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