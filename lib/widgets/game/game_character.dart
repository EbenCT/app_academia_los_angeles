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
      child: Container(
        width: 50,
        height: 50,
        child: _getCharacterImage(),
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
}

enum CharacterType {
  helicopter,  // En el aire
  swimmer,     // En la superficie
  diver,       // Bajo el agua
  fish,        // Muy profundo
}