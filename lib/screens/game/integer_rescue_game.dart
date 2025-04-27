// lib/screens/game/integer_rescue_game.dart (con mejoras)
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../constants/asset_paths.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/custom_button.dart';
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
  static const MAX_ALTITUDE = 500.0;
  static const MIN_ALTITUDE = -180.0;
  static const ASTRONAUT_SPEED = 3.0; // Reducido para más control
  static const ENERGY_DRAIN_RATE = 0.5; // Energía se agota más lentamente

  // Estado del juego
  double _astronautAltitude = 0;
  late Timer _gameTimer;
  int _score = 0;
  double _energy = 100;
  int _remainingMissions = 5;
  bool _gameOver = false;
  bool _isPaused = false;
  
  // Control de movimiento continuo
  bool _isMovingUp = false;
  bool _isMovingDown = false;
  Timer? _continuousMovementTimer;
  
  // Misión actual
  late double _targetAltitude;
  late CharacterType _characterToRescue;
  bool _missionComplete = false;
  String _feedbackMessage = '';
  
  // Controladores de animación
  late AnimationController _astronautController;

  @override
  void initState() {
    super.initState();
    _astronautController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Iniciar primera misión
    _generateNewMission();
    
    // Iniciar el bucle principal del juego
    _gameTimer = Timer.periodic(Duration(milliseconds: 50), _gameLoop);
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    _continuousMovementTimer?.cancel();
    _astronautController.dispose();
    super.dispose();
  }

  void _gameLoop(Timer timer) {
    if (_isPaused || _gameOver) return;
    
    setState(() {
      // Control de movimiento continuo
      if (_isMovingUp) {
        _astronautAltitude = min(MAX_ALTITUDE, _astronautAltitude + ASTRONAUT_SPEED);
      } else if (_isMovingDown) {
        _astronautAltitude = max(MIN_ALTITUDE, _astronautAltitude - ASTRONAUT_SPEED);
      }
      
      // Comprobar si el astronauta está cerca del objetivo
      final distance = (_astronautAltitude - _targetAltitude).abs();
      
      // Si está muy cerca del objetivo
      if (distance < 10 && !_missionComplete) { // Tolerancia aumentada
        _missionComplete = true;
        _score += 100;
        _energy = min(100, _energy + 20);
        _feedbackMessage = '¡Perfecto! Rescate completado';
        
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
        _energy = max(0, _energy - ENERGY_DRAIN_RATE);
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

  void _startMovingUp() {
    if (_missionComplete || _gameOver || _isPaused) return;
    
    setState(() {
      _isMovingUp = true;
      _isMovingDown = false;
    });
    
    _continuousMovementTimer?.cancel();
    _continuousMovementTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (!_isMovingUp) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _astronautAltitude = min(MAX_ALTITUDE, _astronautAltitude + ASTRONAUT_SPEED);
      });
    });
  }

  void _startMovingDown() {
    if (_missionComplete || _gameOver || _isPaused) return;
    
    setState(() {
      _isMovingDown = true;
      _isMovingUp = false;
    });
    
    _continuousMovementTimer?.cancel();
    _continuousMovementTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (!_isMovingDown) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _astronautAltitude = max(MIN_ALTITUDE, _astronautAltitude - ASTRONAUT_SPEED);
      });
    });
  }

  void _stopMoving() {
    setState(() {
      _isMovingUp = false;
      _isMovingDown = false;
    });
    _continuousMovementTimer?.cancel();
  }

  void _generateNewMission() {
    setState(() {
      _remainingMissions--;
      _missionComplete = false;
      
      // Generar una altitud objetivo aleatoria
      final random = Random();
      final possibleAltitudes = [300.0, 250.0, 150.0, 50.0, 0.0, -25.0, -75.0, -120.0];
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
          // Fondo del juego mejorado
          _buildGameBackground(),
          
          // Personaje a rescatar (ahora más grande)
          Positioned(
            top: characterPosition - 50, // Ajustado para mayor visibilidad
            right: 100,
            child: SizedBox(
              width: 100, // Tamaño aumentado
              height: 100,
              child: GameCharacter(
                altitude: _targetAltitude,
                type: _characterToRescue,
                isRescued: _missionComplete,
              ),
            ),
          ),
          
          // Astronauta controlable (ahora más grande)
          Positioned(
            top: astronautPosition - 75, // Ajustado para mayor visibilidad
            left: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Astronauta
                GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (_missionComplete || _gameOver || _isPaused) return;
                    
                    setState(() {
                      // Movimiento más preciso con deslizamiento
                      _astronautAltitude += details.delta.dy * -0.5; // Velocidad reducida para más control
                      _astronautAltitude = _astronautAltitude.clamp(MIN_ALTITUDE, MAX_ALTITUDE);
                    });
                  },
                  child: Container(
                    width: 180, // Tamaño aumentado pero no tanto como 200
                    height: 180,
                    child: Lottie.asset(
                      AssetPaths.astronautfly,
                      controller: _astronautController,
                      fit: BoxFit.contain,
                    ),               
                  ),
                ),
                
                // Indicador de altura del astronauta
                Positioned(
                  bottom: -1,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getAltitudeColor(_astronautAltitude),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '${_astronautAltitude.toInt()} m',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Barra superior con información del juego (reorganizada y más compacta)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Primera fila: Puntos, Energía y Misiones
                    Row(
                      children: [
                        // Puntos (izquierda)
                        Expanded(
                          child: _buildInfoPill('Puntos', '$_score', Colors.amber),
                        ),
                        
                        // Misiones (centro)
                        Expanded(
                          child: _buildInfoPill('Misiones', '$_remainingMissions', AppColors.primary),
                        ),
                        
                        // Botón de pausa (derecha)
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white24,
                          ),
                          child: IconButton(
                            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                            color: Colors.white,
                            iconSize: 20,
                            padding: EdgeInsets.all(6),
                            constraints: BoxConstraints(), // Sin restricciones mínimas
                            onPressed: () {
                              setState(() {
                                _isPaused = !_isPaused;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 4),
                    
                    // Segunda fila: Barra de energía y altitud
                    Row(
                      children: [
                        // Barra de energía (ocupa 2/3)
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white, width: 1),
                              color: Colors.black26,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                children: [
                                  // Barra de energía
                                  FractionallySizedBox(
                                    widthFactor: _energy / 100,
                                    child: Container(
                                      color: _energy > 66 
                                          ? Colors.green 
                                          : _energy > 33 
                                              ? Colors.orange 
                                              : Colors.red,
                                    ),
                                  ),
                                  
                                  // Texto de energía
                                  Center(
                                    child: Text(
                                      'Energía: ${_energy.toInt()}%',
                                      style: TextStyle(
                                        fontFamily: 'Comic Sans MS',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            blurRadius: 2,
                                            offset: Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(width: 8),
                        
                        // Indicador de altitud (ocupa 1/3)
                        Expanded(
                          flex: 1,
                          child: _buildAltitudeBadge(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Controles en pantalla (reubicados a los lados)
          Positioned(
            bottom: 40,
            left: 30,
            child: _buildControlButton(
              icon: Icons.arrow_upward,
              onPressed: _startMovingUp,
              onPressedEnd: _stopMoving,
            ),
          ),
          
          Positioned(
            bottom: 40,
            right: 30,
            child: _buildControlButton(
              icon: Icons.arrow_downward,
              onPressed: _startMovingDown,
              onPressedEnd: _stopMoving,
            ),
          ),
          
          // Mensaje de retroalimentación (ahora más visible)
          if (_feedbackMessage.isNotEmpty)
            Positioned(
              top: 150, // Ajustado para no superponerse con la barra superior
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white30,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _feedbackMessage,
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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

  // Construir el fondo del juego mejorado
  Widget _buildGameBackground() {
    return GameBackground(
      maxHeight: MAX_ALTITUDE,
      minHeight: MIN_ALTITUDE,
      mountainHeight: 100, // Montañas más altas
      cloudDensity: 15, // Más nubes
    );
  }

  // Botón de control mejorado con soporte para mantener presionado
  Widget _buildControlButton({
    required IconData icon, 
    required VoidCallback onPressed,
    required VoidCallback onPressedEnd,
  }) {
    return GestureDetector(
      onTapDown: (_) => onPressed(),
      onTapUp: (_) => onPressedEnd(),
      onTapCancel: onPressedEnd,
      child: Container(
        width: 80, // Botones más grandes
        height: 80,
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
          border: Border.all(
            color: AppColors.primary,
            width: 3,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 40,
        ),
      ),
    );
  }

  // Indicador de información compacto
  Widget _buildInfoPill(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Insignia de altitud mejorada y más compacta
  Widget _buildAltitudeBadge() {
    final altitudeColor = _getAltitudeColor(_astronautAltitude);
                
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: altitudeColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _astronautAltitude >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                color: Colors.white,
                size: 12,
              ),
              SizedBox(width: 4),
              Text(
                '${_astronautAltitude.toInt()}m',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Obtener color basado en la altitud
  Color _getAltitudeColor(double altitude) {
    if (altitude > 200) return Colors.purple;
    if (altitude > 0) return Colors.blue;
    if (altitude > -50) return Colors.green;
    return Colors.indigo;
  }
}