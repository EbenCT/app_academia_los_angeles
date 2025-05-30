// lib/providers/booster_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/active_booster_model.dart';

class BoosterProvider extends ChangeNotifier {
  ActiveBoosterModel? _activeBooster;
  Timer? _updateTimer;

  // Getters
  ActiveBoosterModel? get activeBooster => _activeBooster;
  bool get hasActiveBooster => _activeBooster != null && _activeBooster!.isActive;
  double get xpMultiplier => hasActiveBooster ? _activeBooster!.xpMultiplier : 1.0;
  double get coinMultiplier => hasActiveBooster ? _activeBooster!.coinMultiplier : 1.0;

  BoosterProvider() {
    _loadActiveBooster();
    _startUpdateTimer();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  // Cargar potenciador activo desde storage
  Future<void> _loadActiveBooster() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final boosterJson = prefs.getString('active_booster');
      
      if (boosterJson != null) {
        // Parsear como query string simple
        final data = boosterJson.split('&').fold<Map<String, String>>({}, (map, item) {
          final parts = item.split('=');
          if (parts.length == 2) {
            map[Uri.decodeComponent(parts[0])] = Uri.decodeComponent(parts[1]);
          }
          return map;
        });
        
        final booster = ActiveBoosterModel.fromJson({
          'id': data['id'] ?? '',
          'name': data['name'] ?? '',
          'xp_multiplier': double.tryParse(data['xp_multiplier'] ?? '1.0') ?? 1.0,
          'coin_multiplier': double.tryParse(data['coin_multiplier'] ?? '1.0') ?? 1.0,
          'start_time': data['start_time'] ?? DateTime.now().toIso8601String(),
          'duration_seconds': int.tryParse(data['duration_seconds'] ?? '0') ?? 0,
          'icon_path': data['icon_path'] ?? '',
        });
        
        if (booster.isActive) {
          _activeBooster = booster;
        } else {
          // Limpiar potenciador expirado
          await _clearActiveBooster();
        }
      }
    } catch (e) {
      // Error silencioso en producción
    }
    notifyListeners();
  }

  // Guardar potenciador activo
  Future<void> _saveActiveBooster() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_activeBooster != null) {
        final data = _activeBooster!.toJson();
        // Convertir a string simple para evitar problemas de parsing
        final saveString = data.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
            .join('&');
        
        await prefs.setString('active_booster', saveString);
      } else {
        await prefs.remove('active_booster');
      }
    } catch (e) {
      // Error silencioso en producción
    }
  }

  // Limpiar potenciador activo
  Future<void> _clearActiveBooster() async {
    _activeBooster = null;
    await _saveActiveBooster();
    notifyListeners();
  }

  // Activar un nuevo potenciador
  Future<void> activateBooster({
    required String id,
    required String name,
    required double xpMultiplier,
    required double coinMultiplier,
    required Duration duration,
    required String iconPath,
  }) async {
    _activeBooster = ActiveBoosterModel(
      id: id,
      name: name,
      xpMultiplier: xpMultiplier,
      coinMultiplier: coinMultiplier,
      startTime: DateTime.now(),
      duration: duration,
      iconPath: iconPath,
    );
    
    await _saveActiveBooster();
    notifyListeners();
  }

  // Timer para actualizar el estado cada segundo
  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_activeBooster != null) {
        if (!_activeBooster!.isActive) {
          // Potenciador expirado
          _clearActiveBooster();
        } else {
          // Actualizar UI para mostrar tiempo restante actualizado
          notifyListeners();
        }
      }
    });
  }

  // Formatear tiempo restante para mostrar
  String getFormattedRemainingTime() {
    if (!hasActiveBooster) return '';
    
    final remaining = _activeBooster!.remainingTime;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // Cancelar potenciador activo manualmente (opcional)
  Future<void> cancelActiveBooster() async {
    await _clearActiveBooster();
  }
}