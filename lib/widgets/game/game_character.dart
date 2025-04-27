// lib/widgets/game/game_character.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GameCharacter extends StatelessWidget {
  final double altitude;
  final CharacterType type;
  final bool isRescued;
  
  const GameCharacter({
    Key? key,
    required this.altitude,
    required this.type,
    this.isRescued = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isRescued ? 0.0 : 1.0,
      duration: Duration(milliseconds: 500),
child: Stack(
        alignment: Alignment.center,
        children: [
          // Círculo de destaque para hacer más visible al personaje
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getHighlightColor().withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),Container(
        width: 70,
        height: 70,
        child: _getCharacterImage(),
      ),
      Positioned(
            bottom: -0.8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getHighlightColor(),
                  width: 1.5,
                ),
              ),
              child: Text(
                '${altitude.toInt()} m',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
       ),
    );
  }

  Widget _getCharacterImage() {
    switch (type) {
      case CharacterType.helicopter:
        return Lottie.asset('assets/animations/helicopter.json');
      case CharacterType.swimmer:
        return Lottie.asset('assets/animations/swimmer.json');
      case CharacterType.diver:
        return Lottie.asset('assets/animations/diver.json');
      case CharacterType.fish:
        return Lottie.asset('assets/animations/fish.json');
    }
  }
Color _getHighlightColor() {
    switch (type) {
      case CharacterType.helicopter:
        return Colors.red;
      case CharacterType.swimmer:
        return Colors.orange;
      case CharacterType.diver:
        return Colors.teal;
      case CharacterType.fish:
        return Colors.purpleAccent;
    }
  }
}

enum CharacterType {
  helicopter,  // En el aire
  swimmer,     // En la superficie
  diver,       // Bajo el agua
  fish,        // Muy profundo
}