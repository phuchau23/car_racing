/// Game constants for racing gameplay
class GameConstants {
  // Race settings
  static const double finishDistance = 2000.0; // pixels
  static const double raceTimeMin = 25.0; // seconds
  static const double raceTimeMax = 40.0; // seconds

  // Speed settings
  static const double baseSpeedMin = 80.0; // pixels/second
  static const double baseSpeedMax = 120.0; // pixels/second
  static const double noiseAmplitude = 20.0; // pixels/second
  static const double noiseFrequency = 0.2; // Hz (changes every ~5 seconds)

  // Rubber banding
  static const double rubberBandStrength = 15.0; // pixels/second
  static const double maxDistanceForRubberBand = 250.0; // pixels

  // Lane settings
  static const double laneSpacing = 100.0; // pixels between lanes
  static const double topLaneY = 150.0; // Y position of top lane
  static const double carWidth = 80.0;
  static const double carHeight = 60.0;

  // Betting
  static const double betOdds = 2.0; // 2x multiplier if win
  static const double initialCoins = 100.0;

  // Lead change tracking
  static const int targetLeadChanges = 8; // Target 6-12 lead changes per race
}
