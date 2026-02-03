import 'package:flutter/material.dart';
import '../constants/game_constants.dart';
import '../constants/car_config.dart';

/// Widget to display a car with its image
class CarWidget extends StatelessWidget {
  final int carIndex;
  final double progress;
  final double x;
  final double y;

  const CarWidget({
    super.key,
    required this.carIndex,
    required this.progress,
    required this.x,
    required this.y,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: Image.asset(
        CarConfig.getCarImagePath(carIndex),
        width: GameConstants.carWidth,
        height: GameConstants.carHeight,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to colored container with icon if image fails to load
          return Container(
            width: GameConstants.carWidth,
            height: GameConstants.carHeight,
            decoration: BoxDecoration(
              color: CarConfig.getCarColor(carIndex),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.directions_car, color: Colors.white, size: 40),
          );
        },
      ),
    );
  }
}
