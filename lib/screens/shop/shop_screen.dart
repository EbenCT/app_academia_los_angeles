// lib/screens/shop/shop_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/coin_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/shop_item_model.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/shop/coin_display_widget.dart';
import '../../widgets/shop/shop_item_card.dart';
import '../../utils/app_snackbars.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<ShopItemModel> _allItems = [];
  Map<ShopItemType, List<ShopItemModel>> _itemsByType = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadItems() {
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    _allItems = coinProvider.getShopItems();
    
    // Agrupar items por tipo
    _itemsByType = {
      ShopItemType.pet: _allItems.where((item) => item.type == ShopItemType.pet).toList(),
      ShopItemType.booster: _allItems.where((item) => item.type == ShopItemType.booster).toList(),
      ShopItemType.theme: _allItems.where((item) => item.type == ShopItemType.theme).toList(),
      ShopItemType.badge: _allItems.where((item) => item.type == ShopItemType.badge).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar personalizada
            _buildAppBar(),
            
            // Tabs
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  _buildTab(Icons.pets, 'Mascotas'),
                  _buildTab(Icons.speed, 'Boosts'),
                  _buildTab(Icons.palette, 'Temas'),
                  _buildTab(Icons.military_tech, 'Insignias'),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                indicator: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(25),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 10,
                ),
              ),
            ),
            
            // Contenido de tabs
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildItemGrid(ShopItemType.pet),
                  _buildItemGrid(ShopItemType.booster),
                  _buildItemGrid(ShopItemType.theme),
                  _buildItemGrid(ShopItemType.badge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent,
            AppColors.accent.withOpacity(0.7),
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
            Icons.store,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tienda Galáctica',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // Display de monedas
          CoinDisplayWidget.large(
            backgroundColor: Colors.white.withOpacity(0.2),
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(IconData icon, String label) {
    return Tab(
      height: 50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemGrid(ShopItemType type) {
    final items = _itemsByType[type] ?? [];
    
    if (items.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
        _loadItems();
        setState(() {});
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return FadeAnimation(
            delay: Duration(milliseconds: 100 * index),
            child: ShopItemCard(
              item: items[index],
              onPurchase: () {
                // Mensaje especial para mascotas
                if (items[index].type == ShopItemType.pet) {
                  AppSnackbars.showSuccessSnackBar(
                    context,
                    message: '¡Has adoptado a ${items[index].name}! Ve al inicio para verla.',
                  );
                } else {
                  AppSnackbars.showSuccessSnackBar(
                    context,
                    message: '¡Has comprado ${items[index].name}!',
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ShopItemType type) {
    String message;
    IconData icon;
    
    switch (type) {
      case ShopItemType.pet:
        message = 'No hay mascotas disponibles';
        icon = Icons.pets;
        break;
      case ShopItemType.booster:
        message = 'No hay potenciadores disponibles';
        icon = Icons.speed;
        break;
      case ShopItemType.theme:
        message = 'No hay temas disponibles';
        icon = Icons.palette;
        break;
      case ShopItemType.badge:
        message = 'No hay insignias disponibles';
        icon = Icons.military_tech;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vuelve pronto para nuevos objetos',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}