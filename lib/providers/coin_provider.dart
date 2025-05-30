// lib/providers/coin_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coin_model.dart';
import '../models/shop_item_model.dart';
import '../constants/asset_paths.dart';

class CoinProvider extends ChangeNotifier {
  CoinModel _coins = CoinModel(amount: 100, lastUpdated: DateTime.now()); // Empezamos con 100 monedas
  List<ShopItemModel> _ownedItems = [];
  List<ShopItemModel> _equippedItems = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  CoinModel get coins => _coins;
  List<ShopItemModel> get ownedItems => _ownedItems;
  List<ShopItemModel> get equippedItems => _equippedItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CoinProvider() {
    _loadData();
  }

  // Obtener mascota equipada actualmente
  ShopItemModel? get equippedPet {
    final pets = _equippedItems.where((item) => item.type == ShopItemType.pet);
    return pets.isNotEmpty ? pets.first : null;
  }

  // Cargar datos desde SharedPreferences
  Future<void> _loadData() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cargar monedas
      final coinAmount = prefs.getInt('coin_amount') ?? 100;
      final lastUpdatedString = prefs.getString('coin_last_updated');
      final lastUpdated = lastUpdatedString != null 
          ? DateTime.parse(lastUpdatedString)
          : DateTime.now();
      
      _coins = CoinModel(amount: coinAmount, lastUpdated: lastUpdated);
      
      // Cargar objetos poseídos
      final ownedItemsJson = prefs.getStringList('owned_items') ?? [];
      _ownedItems = ownedItemsJson
          .map((json) => ShopItemModel.fromJson(Map<String, dynamic>.from(
              Uri.splitQueryString(json).map((k, v) => MapEntry(k, v))
          )))
          .toList();
      
      // Cargar objetos equipados
      final equippedItemsJson = prefs.getStringList('equipped_items') ?? [];
      _equippedItems = equippedItemsJson
          .map((json) => ShopItemModel.fromJson(Map<String, dynamic>.from(
              Uri.splitQueryString(json).map((k, v) => MapEntry(k, v))
          )))
          .toList();
      
    } catch (e) {
      _error = 'Error al cargar datos: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Guardar datos en SharedPreferences
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Guardar monedas
      await prefs.setInt('coin_amount', _coins.amount);
      await prefs.setString('coin_last_updated', _coins.lastUpdated.toIso8601String());
      
      // Guardar objetos poseídos (simplificado para demo)
      final ownedItemsJson = _ownedItems.map((item) => item.id).toList();
      await prefs.setStringList('owned_items', ownedItemsJson);
      
      // Guardar objetos equipados
      final equippedItemsJson = _equippedItems.map((item) => item.id).toList();
      await prefs.setStringList('equipped_items', equippedItemsJson);
      
    } catch (e) {
      _error = 'Error al guardar datos: $e';
    }
  }

  // Agregar monedas
  Future<void> addCoins(int amount, {String? reason}) async {
    _coins = _coins.copyWith(
      amount: _coins.amount + amount,
      lastUpdated: DateTime.now(),
    );
    await _saveData();
    notifyListeners();
  }

  // Gastar monedas
  Future<bool> spendCoins(int amount) async {
    if (_coins.amount < amount) {
      _error = 'No tienes suficientes monedas';
      notifyListeners();
      return false;
    }
    
    _coins = _coins.copyWith(
      amount: _coins.amount - amount,
      lastUpdated: DateTime.now(),
    );
    await _saveData();
    notifyListeners();
    return true;
  }

  // Comprar objeto
  Future<bool> purchaseItem(ShopItemModel item) async {
    if (_coins.amount < item.price) {
      _error = 'No tienes suficientes monedas para comprar este objeto';
      notifyListeners();
      return false;
    }
    
    if (_ownedItems.any((owned) => owned.id == item.id)) {
      _error = 'Ya posees este objeto';
      notifyListeners();
      return false;
    }
    
    final success = await spendCoins(item.price);
    if (success) {
      _ownedItems.add(item.copyWith(isOwned: true));
      
      // Si es la primera mascota, equiparla automáticamente
      if (item.type == ShopItemType.pet && 
          !_equippedItems.any((equipped) => equipped.type == ShopItemType.pet)) {
        _equippedItems.add(item.copyWith(isEquipped: true));
      }
      
      await _saveData();
      _clearError();
      return true;
    }
    
    return false;
  }

  // Equipar objeto
  Future<void> equipItem(ShopItemModel item) async {
    if (!_ownedItems.any((owned) => owned.id == item.id)) {
      _error = 'No posees este objeto';
      notifyListeners();
      return;
    }
    
    // Desequipar objetos del mismo tipo
    _equippedItems.removeWhere((equipped) => equipped.type == item.type);
    
    // Equipar el nuevo objeto
    _equippedItems.add(item.copyWith(isEquipped: true));
    await _saveData();
    notifyListeners();
  }

  // Desequipar objeto
  Future<void> unequipItem(ShopItemModel item) async {
    _equippedItems.removeWhere((equipped) => equipped.id == item.id);
    await _saveData();
    notifyListeners();
  }

  // Verificar si un objeto está equipado
  bool isItemEquipped(String itemId) {
    return _equippedItems.any((item) => item.id == itemId);
  }

  // Verificar si un objeto es poseído
  bool isItemOwned(String itemId) {
    return _ownedItems.any((item) => item.id == itemId);
  }

  // Obtener objetos de la tienda (datos estáticos por ahora)
  List<ShopItemModel> getShopItems() {
    return [
      // Mascotas
      ShopItemModel(
        id: 'pet_red',
        name: 'Mascota Roja',
        description: 'Una adorable mascota roja que te acompañará en tus aventuras',
        price: 100,
        type: ShopItemType.pet,
        rarity: ShopItemRarity.common,
        icon: Icons.pets,
        colors: [Colors.red, Colors.red.shade700],
        animationPath: AssetPaths.petRed,
      ),
      ShopItemModel(
        id: 'pet_blue',
        name: 'Mascota Azul',
        description: 'Una tranquila mascota azul perfecta para estudiar',
        price: 100,
        type: ShopItemType.pet,
        rarity: ShopItemRarity.common,
        icon: Icons.pets,
        colors: [Colors.blue, Colors.blue.shade700],
        animationPath: AssetPaths.petBlue,
      ),
      ShopItemModel(
        id: 'pet_orange',
        name: 'Mascota Naranja',
        description: 'Una energética mascota naranja llena de vitalidad',
        price: 100,
        type: ShopItemType.pet,
        rarity: ShopItemRarity.common,
        icon: Icons.pets,
        colors: [Colors.orange, Colors.orange.shade700],
        animationPath: AssetPaths.petOrange,
      ),
      ShopItemModel(
        id: 'pet_yellow',
        name: 'Mascota Amarilla',
        description: 'Una alegre mascota amarilla que iluminará tus días',
        price: 100,
        type: ShopItemType.pet,
        rarity: ShopItemRarity.common,
        icon: Icons.pets,
        colors: [Colors.yellow, Colors.yellow.shade700],
        animationPath: AssetPaths.petYellow,
      ),
      ShopItemModel(
        id: 'pet_green',
        name: 'Mascota Verde',
        description: 'Una sabia mascota verde que te ayudará en matemáticas',
        price: 100,
        type: ShopItemType.pet,
        rarity: ShopItemRarity.rare,
        icon: Icons.pets,
        colors: [Colors.green, Colors.green.shade700],
        animationPath: AssetPaths.petGreen,
      ),
      
            // Potenciadores de XP
      ShopItemModel(
        id: 'boost_xp_1_5x',
        name: 'Potenciador XP Básico',
        description: 'Aumenta la experiencia ganada x1.5 por 5 minutos',
        price: 50,
        type: ShopItemType.booster,
        rarity: ShopItemRarity.common,
        icon: Icons.trending_up,
        colors: [Colors.green, Colors.lightGreen],
        animationPath: AssetPaths.exp,
        effects: {'xp_multiplier': 1.5, 'duration_minutes': 5},
      ),
      ShopItemModel(
        id: 'boost_xp_2x',
        name: 'Potenciador XP Avanzado',
        description: 'Duplica la experiencia ganada por 10 minutos',
        price: 100,
        type: ShopItemType.booster,
        rarity: ShopItemRarity.rare,
        icon: Icons.trending_up,
        colors: [Colors.blue, Colors.lightBlue],
        animationPath: AssetPaths.exp,
        effects: {'xp_multiplier': 2.0, 'duration_minutes': 10},
      ),
      ShopItemModel(
        id: 'boost_xp_3x',
        name: 'Potenciador XP Épico',
        description: 'Triplica la experiencia ganada por 15 minutos',
        price: 200,
        type: ShopItemType.booster,
        rarity: ShopItemRarity.epic,
        icon: Icons.trending_up,
        colors: [Colors.purple, Colors.deepPurple],
        animationPath: AssetPaths.exp,
        effects: {'xp_multiplier': 3.0, 'duration_minutes': 15},
      ),
      
      // Potenciadores de Monedas
      ShopItemModel(
        id: 'boost_coins_1_5x',
        name: 'Potenciador Monedas Básico',
        description: 'Aumenta las monedas ganadas x1.5 por 5 minutos',
        price: 50,
        type: ShopItemType.booster,
        rarity: ShopItemRarity.common,
        icon: Icons.monetization_on,
        colors: [Colors.amber, Colors.orange],
        animationPath: AssetPaths.coins,
        effects: {'coin_multiplier': 1.5, 'duration_minutes': 5},
      ),
      ShopItemModel(
        id: 'boost_coins_2x',
        name: 'Potenciador Monedas Avanzado',
        description: 'Duplica las monedas ganadas por 10 minutos',
        price: 100,
        type: ShopItemType.booster,
        rarity: ShopItemRarity.rare,
        icon: Icons.monetization_on,
        colors: [Colors.amber, Colors.orange],
        animationPath: AssetPaths.coins,
        effects: {'coin_multiplier': 2.0, 'duration_minutes': 10},
      ),
      ShopItemModel(
        id: 'boost_coins_3x',
        name: 'Potenciador Monedas Épico',
        description: 'Triplica las monedas ganadas por 15 minutos',
        price: 200,
        type: ShopItemType.booster,
        rarity: ShopItemRarity.epic,
        icon: Icons.monetization_on,
        colors: [Colors.deepOrange, Colors.red],
        animationPath: AssetPaths.coins,
        effects: {'coin_multiplier': 3.0, 'duration_minutes': 15},
      ),
      
      // Potenciador Legendario (XP + Monedas)
      ShopItemModel(
        id: 'boost_ultimate',
        name: 'Potenciador Supremo',
        description: 'Triplica XP y monedas por 30 minutos',
        price: 500,
        type: ShopItemType.booster,
        rarity: ShopItemRarity.legendary,
        icon: Icons.auto_awesome,
        colors: [Colors.amber, Colors.deepOrange],
        animationPath: AssetPaths.exp,
        effects: {'xp_multiplier': 3.0, 'coin_multiplier': 3.0, 'duration_minutes': 30},
      ),
      
      // Temas
      ShopItemModel(
        id: 'theme_galaxy',
        name: 'Tema Galaxia',
        description: 'Un tema oscuro con estrellas brillantes',
        price: 250,
        type: ShopItemType.theme,
        rarity: ShopItemRarity.rare,
        icon: Icons.dark_mode,
        colors: [Colors.indigo, Colors.purple],
      ),
      
      // Insignias
      ShopItemModel(
        id: 'badge_explorer',
        name: 'Insignia de Explorador',
        description: 'Demuestra tu amor por la aventura',
        price: 200,
        type: ShopItemType.badge,
        rarity: ShopItemRarity.rare,
        icon: Icons.explore,
        colors: [Colors.teal, Colors.cyan],
      ),
      ShopItemModel(
        id: 'badge_legend',
        name: 'Insignia Legendaria',
        description: 'Solo para los mejores estudiantes',
        price: 1000,
        type: ShopItemType.badge,
        rarity: ShopItemRarity.legendary,
        icon: Icons.military_tech,
        colors: [Colors.amber, Colors.deepOrange],
      ),
    ];
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}