import 'package:flutter/material.dart';
import '../constants/car_config.dart';

/// Widget to display car information (name, ranking, speed)
class CarInfoWidget extends StatelessWidget {
  final int carIndex;
  final int ranking;
  final double speed;

  const CarInfoWidget({
    super.key,
    required this.carIndex,
    required this.ranking,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          CarConfig.getCarName(carIndex),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: CarConfig.getCarColor(carIndex),
          ),
        ),
        Text(
          '$ranking',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          '${speed.toStringAsFixed(0)} px/s',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
