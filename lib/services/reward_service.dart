// lib/services/reward_service.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../providers/coin_provider.dart';
import '../widgets/rewards/reward_popup.dart';

class RewardService {
  /// Otorga recompensas por completar una lección
  static Future<void> completeLesson({
    required BuildContext context,
    required String lessonId,
    int? customXp,
    int? customCoins,
    bool showPopup = true,
  }) async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    
    // Recompensas base para lecciones
    final xpEarned = customXp ?? 75;
    final coinsEarned = customCoins ?? 40;
    
    // Verificar nivel antes
    final oldLevel = studentProvider.level;
    
    // Otorgar XP usando el método existente del StudentProvider
    await studentProvider.completeLesson(lessonId, context: context);
    
    // Verificar si subió de nivel
    final newLevel = studentProvider.level;
    final leveledUp = newLevel > oldLevel;
    final levelBonus = leveledUp ? newLevel * 15 : 0;
    
    // Las monedas ya se otorgan en completeLesson, pero podemos agregar bonus
    if (levelBonus > 0) {
      await coinProvider.addCoins(levelBonus, reason: 'Bonus por subida de nivel');
    }
    
    // Mostrar popup de recompensas si está habilitado
    if (showPopup && context.mounted) {
      await _showRewardPopup(
        context: context,
        title: '¡Lección Completada!',
        xpEarned: xpEarned,
        coinsEarned: coinsEarned + levelBonus,
        leveledUp: leveledUp,
        newLevel: newLevel,
        icon: Icons.school,
      );
    }
  }
  
  /// Otorga recompensas por completar un juego
  static Future<void> completeGame({
    required BuildContext context,
    required String gameId,
    required int score,
    bool showPopup = true,
  }) async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    
    // Verificar nivel antes
    final oldLevel = studentProvider.level;
    
    // Otorgar recompensas usando el método existente del StudentProvider
    await studentProvider.completeGame(gameId, score, context: context);
    
    // Verificar si subió de nivel
    final newLevel = studentProvider.level;
    final leveledUp = newLevel > oldLevel;
    
    // Calcular XP y monedas mostradas (aproximadas, ya que el StudentProvider las calcula)
    final baseXp = 100;
    final scoreBonus = (score * 0.1).round();
    final xpEarned = baseXp + scoreBonus;
    
    final baseCoins = 60;
    final coinBonus = (score * 0.05).round();
    final levelBonus = leveledUp ? newLevel * 20 : 0;
    final coinsEarned = baseCoins + coinBonus + levelBonus;
    
    // Mostrar popup de recompensas si está habilitado
    if (showPopup && context.mounted) {
      await _showRewardPopup(
        context: context,
        title: '¡Juego Completado!',
        subtitle: 'Puntuación: $score',
        xpEarned: xpEarned,
        coinsEarned: coinsEarned,
        leveledUp: leveledUp,
        newLevel: newLevel,
        icon: Icons.videogame_asset,
      );
    }
  }
  
  /// Otorga recompensas por completar un desafío diario
  static Future<void> completeChallenge({
    required BuildContext context,
    int xpEarned = 50,
    int coinsEarned = 25,
    bool showPopup = true,
  }) async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    
    // Verificar nivel antes
    final oldLevel = studentProvider.level;
    
    // Otorgar recompensas usando el método existente del StudentProvider
    await studentProvider.completeChallenge(xpEarned, context: context);
    
    // Verificar si subió de nivel
    final newLevel = studentProvider.level;
    final leveledUp = newLevel > oldLevel;
    final levelBonus = leveledUp ? newLevel * 10 : 0;
    
    // Mostrar popup de recompensas si está habilitado
    if (showPopup && context.mounted) {
      await _showRewardPopup(
        context: context,
        title: '¡Desafío Completado!',
        xpEarned: xpEarned,
        coinsEarned: coinsEarned + levelBonus,
        leveledUp: leveledUp,
        newLevel: newLevel,
        icon: Icons.emoji_events,
      );
    }
  }
  
  /// Otorga recompensas rápidas sin usar los métodos del StudentProvider
  static Future<void> giveQuickReward({
    required BuildContext context,
    required int xp,
    required int coins,
    String reason = 'Actividad completada',
    bool showPopup = false,
  }) async {
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    
    // Solo otorgar monedas directamente para recompensas rápidas
    await coinProvider.addCoins(coins, reason: reason);
    
    // Para XP, tendríamos que usar completeChallenge o crear un método más simple
    if (xp > 0) {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      await studentProvider.completeChallenge(xp, context: context);
    }
    
    if (showPopup && context.mounted) {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      await _showRewardPopup(
        context: context,
        title: '¡Recompensa!',
        xpEarned: xp,
        coinsEarned: coins,
        leveledUp: false,
        newLevel: studentProvider.level,
        icon: Icons.star,
      );
    }
  }
  
  /// Muestra el popup de recompensas
  static Future<void> _showRewardPopup({
    required BuildContext context,
    required String title,
    String? subtitle,
    required int xpEarned,
    required int coinsEarned,
    required bool leveledUp,
    required int newLevel,
    required IconData icon,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RewardPopup(
        title: title,
        subtitle: subtitle,
        xpEarned: xpEarned,
        coinsEarned: coinsEarned,
        leveledUp: leveledUp,
        newLevel: newLevel,
        icon: icon,
      ),
    );
  }
}