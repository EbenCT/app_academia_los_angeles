// lib/providers/coin_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coin_model.dart';
import '../models/shop_item_model.dart';

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
      // Accesorios
      ShopItemModel(
        id: 'hat_space',
        name: 'Casco Espacial',
        description: 'Un casco futurista para verdaderos exploradores',
        price: 150,
        type: ShopItemType.accessory,
        rarity: ShopItemRarity.common,
        icon: Icons.construction,
        colors: [Colors.blue, Colors.cyan],
      ),
      ShopItemModel(
        id: 'cape_hero',
        name: 'Capa de Héroe',
        description: 'Una capa que ondea con cada aventura',
        price: 300,
        type: ShopItemType.accessory,
        rarity: ShopItemRarity.rare,
        icon: Icons.flag,
        colors: [Colors.red, Colors.orange],
      ),
      ShopItemModel(
        id: 'crown_math',
        name: 'Corona de Matemáticas',
        description: 'Corona dorada para los maestros de números',
        price: 500,
        type: ShopItemType.accessory,
        rarity: ShopItemRarity.epic,
        icon: Icons.diamond,
        colors: [Colors.amber, Colors.yellow],
      ),
      
      // Potenciadores
      ShopItemModel(
        id: 'boost_xp_2x',
        name: 'Doblar XP',
        description: 'Duplica la experiencia ganada por 1 hora',
        price: 75,
        type: ShopItemType.booster,
        rarity: ShopItemRarity.common,
        icon: Icons.speed,
        colors: [Colors.green, Colors.lightGreen],
        effects: {'xp_multiplier': 2.0, 'duration_hours': 1},
      ),
      ShopItemModel(
        id: 'boost_coins_2x',
        name: 'Doblar Monedas',
        description: 'Duplica las monedas ganadas por 30 minutos',
        price: 100,
        type: ShopItemType.booster,
        rarity: ShopItemRarity.rare,
        icon: Icons.monetization_on,
        colors: [Colors.amber, Colors.orange],
        effects: {'coin_multiplier': 2.0, 'duration_minutes': 30},
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