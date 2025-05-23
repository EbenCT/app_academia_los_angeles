// lib/widgets/shop/purchase_confirmation_dialog.dart
import 'package:flutter/material.dart';
import '../../models/shop_item_model.dart';
import '../../theme/app_colors.dart';

class PurchaseConfirmationDialog extends StatelessWidget {
  final ShopItemModel item;
  final VoidCallback onConfirm;

  const PurchaseConfirmationDialog({
    Key? key,
    required this.item,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  Icon(
                    item.icon,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '¿Comprar ${item.name}?',
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
                  // Descripción del item
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: item.rarityColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.rarityDisplayName,
                                style: TextStyle(
                                  fontFamily: 'Comic Sans MS',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Spacer(),
                            Text(
                              item.typeDisplayName,
                              style: TextStyle(
                                fontFamily: 'Comic Sans MS',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: item.rarityColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
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
                          onPressed: () {
                            Navigator.pop(context);
                            onConfirm();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: item.rarityColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            '¡Comprar!',
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
  }
}