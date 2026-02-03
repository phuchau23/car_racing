import 'package:flutter/material.dart';
import '../constants/game_constants.dart';
import '../constants/car_config.dart';

/// Widget to display progress bar for a car
class ProgressBarWidget extends StatelessWidget {
  final int carIndex;
  final double progress;
  final double laneSpacing;
  final bool isLast;

  const ProgressBarWidget({
    super.key,
    required this.carIndex,
    required this.progress,
    required this.laneSpacing,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : laneSpacing - GameConstants.carHeight,
      ),
      width: 8,
      height: GameConstants.carHeight,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 8,
          height: GameConstants.carHeight * progress,
          decoration: BoxDecoration(
            color: CarConfig.getCarColor(carIndex),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
