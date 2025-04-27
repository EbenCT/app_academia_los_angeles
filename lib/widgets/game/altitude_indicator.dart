// lib/widgets/game/altitude_indicator.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AltitudeIndicator extends StatelessWidget {
  final double currentAltitude;
  final double maxAltitude;
  final double minAltitude;
  
  const AltitudeIndicator({
    Key? key,
    required this.currentAltitude,
    required this.maxAltitude,
    required this.minAltitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ALTITUD',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '${currentAltitude.toInt()} m',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _getAltitudeColor(currentAltitude),
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                currentAltitude >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                color: _getAltitudeColor(currentAltitude),
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                currentAltitude >= 0 ? 'Sobre el mar' : 'Bajo el mar',
                style: TextStyle(
                  fontFamily: 'Comic Sans MS',
                  fontSize: 12,
                  color: _getAltitudeColor(currentAltitude),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getAltitudeColor(double altitude) {
    if (altitude > 200) return Colors.purple;
    if (altitude > 0) return Colors.blue;
    if (altitude > -50) return Colors.green;
    return Colors.indigo;
  }
}