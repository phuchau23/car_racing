import 'package:flutter/material.dart';

/// Car configuration constants
class CarConfig {
  // Car image paths
  static const List<String> carImagePaths = [
    'assets/images/red_car.png',
    'assets/images/blue_car.png',
    'assets/images/yellow_car.png',
  ];

  // Car colors (fallback)
  static const List<Color> carColors = [Colors.red, Colors.blue, Colors.yellow];

  // Car names
  static const List<String> carNames = ['Xe Đỏ', 'Xe Xanh', 'Xe Vàng'];

  /// Get car image path by index
  static String getCarImagePath(int index) {
    if (index < 0 || index >= carImagePaths.length) {
      return carImagePaths[0]; // fallback
    }
    return carImagePaths[index];
  }

  /// Get car color by index
  static Color getCarColor(int index) {
    if (index < 0 || index >= carColors.length) {
      return carColors[0]; // fallback
    }
    return carColors[index];
  }

  /// Get car name by index
  static String getCarName(int index) {
    if (index < 0 || index >= carNames.length) {
      return carNames[0]; // fallback
    }
    return carNames[index];
  }
}
