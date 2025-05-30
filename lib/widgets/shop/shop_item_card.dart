// lib/widgets/shop/shop_item_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../models/shop_item_model.dart';
import '../../providers/coin_provider.dart';
import '../../providers/booster_provider.dart';
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
    // Para potenciadores, mostrar diálogo especial
    if (item.type == ShopItemType.booster) {
      _showBoosterConfirmationDialog(context, coinProvider);
    } else {
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

  void _showBoosterConfirmationDialog(BuildContext context, CoinProvider coinProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: item.colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Animación del potenciador
                      if (item.animationPath != null)
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: Lottie.asset(
                            item.animationPath!,
                            fit: BoxFit.contain,
                          ),
                        )
                      else
                        Icon(
                          item.icon,
                          color: Colors.white,
                          size: 48,
                        ),
                      const SizedBox(height: 12),
                      Text(
                        '¿Activar ${item.name}?',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Contenido
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Descripción del potenciador
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: item.rarityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: item.rarityColor.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              item.description,
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontSize: 14,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            
                            // Efectos del potenciador
                            if (item.effects != null) ...[
                              _buildBoosterEffects(item.effects!, context),
                              const SizedBox(height: 12),
                            ],
                            
                            // Advertencia sobre potenciador activo
                            Consumer<BoosterProvider>(
                              builder: (context, boosterProvider, child) {
                                if (boosterProvider.hasActiveBooster) {
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.warning, color: Colors.orange, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Esto reemplazará tu potenciador activo',
                                            style: TextStyle(
                                              fontFamily: 'Comic Sans MS',
                                              fontSize: 12,
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Precio
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.star.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.star.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Precio: ',
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontSize: 16,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                            Icon(
                              Icons.monetization_on,
                              color: AppColors.star,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.price.toString(),
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.star,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botones
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontFamily: 'Comic Sans MS',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _activateBooster(context, coinProvider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: item.rarityColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                '¡Activar!',
                                style: TextStyle(
                                  fontFamily: 'Comic Sans MS',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBoosterEffects(Map<String, dynamic> effects, BuildContext context) {
    List<Widget> effectWidgets = [];
    
    if (effects.containsKey('xp_multiplier')) {
      effectWidgets.add(
        _buildEffectBadge(
          icon: Icons.star,
          color: Colors.blue,
          text: 'XP x${effects['xp_multiplier']}',
        ),
      );
    }
    
    if (effects.containsKey('coin_multiplier')) {
      effectWidgets.add(
        _buildEffectBadge(
          icon: Icons.monetization_on,
          color: Colors.amber,
          text: 'Monedas x${effects['coin_multiplier']}',
        ),
      );
    }
    
    String duration = '';
    if (effects.containsKey('duration_minutes')) {
      duration = '${effects['duration_minutes']} min';
    } else if (effects.containsKey('duration_hours')) {
      duration = '${effects['duration_hours']} h';
    }
    
    if (duration.isNotEmpty) {
      effectWidgets.add(
        _buildEffectBadge(
          icon: Icons.access_time,
          color: Colors.green,
          text: duration,
        ),
      );
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: effectWidgets,
    );
  }

  Widget _buildEffectBadge({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _activateBooster(BuildContext context, CoinProvider coinProvider) async {
    if (coinProvider.coins.amount < item.price) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No tienes suficientes monedas',
            style: TextStyle(fontFamily: 'Comic Sans MS'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Gastar monedas
    final success = await coinProvider.spendCoins(item.price);
    if (!success) {
      Navigator.pop(context);
      return;
    }

    // Activar potenciador
    final boosterProvider = Provider.of<BoosterProvider>(context, listen: false);
    
    final xpMultiplier = (item.effects?['xp_multiplier'] ?? 1.0).toDouble();
    final coinMultiplier = (item.effects?['coin_multiplier'] ?? 1.0).toDouble();
    
    int durationMinutes = 0;
    if (item.effects?.containsKey('duration_minutes') == true) {
      durationMinutes = item.effects!['duration_minutes'];
    } else if (item.effects?.containsKey('duration_hours') == true) {
      durationMinutes = item.effects!['duration_hours'] * 60;
    }
    
    await boosterProvider.activateBooster(
      id: item.id,
      name: item.name,
      xpMultiplier: xpMultiplier,
      coinMultiplier: coinMultiplier,
      duration: Duration(minutes: durationMinutes),
      iconPath: item.animationPath ?? 'assets/animations/exp.json',
    );

    Navigator.pop(context);
    
    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '¡${item.name} activado!',
          style: TextStyle(fontFamily: 'Comic Sans MS'),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    if (onPurchase != null) {
      onPurchase!();
    }
  }
}