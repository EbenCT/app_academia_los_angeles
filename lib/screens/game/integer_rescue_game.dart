// lib/screens/game/integer_rescue_game.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../constants/asset_paths.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/game/altitude_indicator.dart';
import '../../widgets/game/game_background.dart';
import '../../widgets/game/game_character.dart';
import 'game_results_screen.dart';

class IntegerRescueGame extends StatefulWidget {
  const IntegerRescueGame({Key? key}) : super(key: key);

  @override
  State<IntegerRescueGame> createState() => _IntegerRescueGameState();
}

class _IntegerRescueGameState extends State<IntegerRescueGame> with TickerProviderStateMixin {
  // Constantes del juego
  static const MAX_ALTITUDE = 400.0;
  static const MIN_ALTITUDE = -150.0;
  static const ASTRONAUT_SPEED = 5.0;

  // Estado del juego
  double _astronautAltitude = 0;
  late Timer _gameTimer;
  int _score = 0;
  int _energy = 100;
  int _remainingMissions = 5;
  bool _gameOver = false;
  bool _isPaused = false;
  
  // Misión actual
  late int _targetAltitude;
  late CharacterType _characterToRescue;
  bool _missionComplete = false;
  String _feedbackMessage = '';
  
  // Controladores de animación
  late AnimationController _astronautController;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _astronautController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _audioPlayer = AudioPlayer();
    
    // Iniciar primera misión
    _generateNewMission();
    
    // Iniciar el bucle principal del juego
    _gameTimer = Timer.periodic(Duration(milliseconds: 50), _gameLoop);
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    _astronautController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _gameLoop(Timer timer) {
    if (_isPaused || _gameOver) return;
    
    setState(() {
      // Comprobar si el astronauta está cerca del objetivo
      final distance = (_astronautAltitude - _targetAltitude).abs();
      
      // Si está muy cerca del objetivo
      if (distance < 10 && !_missionComplete) {
        _missionComplete = true;
        _score += 100;
        _energy = min(100, _energy + 20);
        _feedbackMessage = '¡Perfecto! Rescate completado';
        _playSound('success.mp3');
        
        // Programar la próxima misión
        Future.delayed(Duration(seconds: 2), () {
          if (_remainingMissions > 0) {
            _generateNewMission();
          } else {
            _endGame(true);
          }
        });
      } 
      // Si está demasiado lejos y está activamente intentando rescatar
      else if (distance > 50 && _energy > 0 && !_missionComplete) {
        _energy--;
        if (_astronautAltitude > _targetAltitude) {
          _feedbackMessage = '¡Más abajo!';
        } else {
          _feedbackMessage = '¡Más arriba!';
        }
        
        if (_energy <= 0) {
          _endGame(false);
        }
      }
    });
  }

  void _moveAstronaut(double direction) {
    if (_missionComplete || _gameOver || _isPaused) return;
    
    setState(() {
      _astronautAltitude = _astronautAltitude + (direction * ASTRONAUT_SPEED);
      
      // Limitar a los valores máximos y mínimos
      _astronautAltitude = _astronautAltitude.clamp(MIN_ALTITUDE, MAX_ALTITUDE);
    });
  }

  void _generateNewMission() {
    setState(() {
      _remainingMissions--;
      _missionComplete = false;
      
      // Generar una altitud objetivo aleatoria
      final random = Random();
      final possibleAltitudes = [350, 250, 150, 50, 0, -25, -75, -120];
      _targetAltitude = possibleAltitudes[random.nextInt(possibleAltitudes.length)];
      
      // Determinar el tipo de personaje basado en la altitud
      if (_targetAltitude > 200) {
        _characterToRescue = CharacterType.helicopter;
      } else if (_targetAltitude >= 0) {
        _characterToRescue = CharacterType.swimmer;
      } else if (_targetAltitude >= -75) {
        _characterToRescue = CharacterType.diver;
      } else {
        _characterToRescue = CharacterType.fish;
      }
      
      _feedbackMessage = '¡Nuevo rescate! Ve a ${_targetAltitude.toInt()} metros';
    });
  }

  void _playSound(String soundFile) async {
    await _audioPlayer.play(AssetSource('sounds/$soundFile'));
  }

  void _endGame(bool victory) {
    setState(() {
      _gameOver = true;
    });
    
    // Mostrar pantalla de resultados
    Future.delayed(Duration(milliseconds: 1500), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameResultsScreen(
            score: _score,
            victory: victory,
            onPlayAgain: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => IntegerRescueGame()),
              );
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Calcular la posición vertical del astronauta
    final totalRange = MAX_ALTITUDE - MIN_ALTITUDE;
    final pixelsPerMeter = size.height / totalRange;
    final astronautPosition = (MAX_ALTITUDE - _astronautAltitude) * pixelsPerMeter;
    
    // Calcular la posición del personaje a rescatar
    final characterPosition = (MAX_ALTITUDE - _targetAltitude) * pixelsPerMeter;
    
    return Scaffold(
      body: Stack(
        children: [
          // Fondo del juego
          GameBackground(
            maxHeight: MAX_ALTITUDE,
            minHeight: MIN_ALTITUDE,
          ),
          
          // Personaje a rescatar
          Positioned(
            top: characterPosition - 25,
            right: 80,
            child: GameCharacter(
              altitude: _targetAltitude.toDouble(),
              type: _characterToRescue,
              isRescued: _missionComplete,
            ),
          ),
          
          // Astronauta controlable
          Positioned(
            top: astronautPosition - 50,
            left: 120,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy > 0) {
                  // Deslizamiento hacia abajo
                  _moveAstronaut(-0.2);
                } else if (details.delta.dy < 0) {
                  // Deslizamiento hacia arriba
                  _moveAstronaut(0.2);
                }
              },
              child: Container(
                width: 100,
                height: 100,
                child: Lottie.asset(
                  AssetPaths.astronautfly,
                  controller: _astronautController,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          
          // Controles en pantalla
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.arrow_upward,
                  onPressed: () => _moveAstronaut(1),
                ),
                SizedBox(width: 20),
                _buildControlButton(
                  icon: Icons.arrow_downward,
                  onPressed: () => _moveAstronaut(-1),
                ),
              ],
            ),
          ),
          
          // Indicador de altitud
          Positioned(
            top: 50,
            right: 20,
            child: AltitudeIndicator(
              currentAltitude: _astronautAltitude,
              maxAltitude: MAX_ALTITUDE,
              minAltitude: MIN_ALTITUDE,
            ),
          ),
          
          // Información del juego
          Positioned(
            top: 50,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard('Puntos', '$_score', Colors.amber),
                SizedBox(height: 10),
                _buildInfoCard('Energía', '$_energy%', 
                    _energy > 66 ? Colors.green : 
                    _energy > 33 ? Colors.orange : Colors.red),
                SizedBox(height: 10),
                _buildInfoCard('Misiones', '$_remainingMissions', AppColors.primary),
              ],
            ),
          ),
          
          // Mensaje de retroalimentación
          if (_feedbackMessage.isNotEmpty)
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _feedbackMessage,
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          
          // Botón de pausa
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
              color: Colors.white,
              onPressed: () {
                setState(() {
                  _isPaused = !_isPaused;
                });
              },
            ),
          ),
          
          // Menú de pausa
          if (_isPaused)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'PAUSA',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomButton(
                      text: 'Continuar',
                      onPressed: () {
                        setState(() {
                          _isPaused = false;
                        });
                      },
                      backgroundColor: AppColors.primary,
                      width: 200,
                    ),
                    SizedBox(height: 10),
                    CustomButton(
                      text: 'Salir',
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      backgroundColor: Colors.red,
                      width: 200,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        color: AppColors.primary,
        iconSize: 30,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}