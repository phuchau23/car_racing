import 'dart:math';
import '../utils/game_constants.dart';

/// Game state for racing game
class GameState {
  // Positions and speeds
  final List<double> positions; // X positions (0 to finishDistance)
  final List<double> speeds; // Current speeds in pixels/second
  final List<double> baseSpeeds; // Base speeds for each car
  final List<double> noisePhases; // Phases for noise calculation
  
  // Lane positions (fixed)
  final List<double> laneY;
  
  // Race state
  final double finishDistance;
  final double elapsedTime;
  final bool isFinished;
  final int? winner;
  final int seed;
  
  // Lead tracking
  final List<int> leadHistory; // Track lead changes
  final int currentLeader;

  GameState({
    required this.positions,
    required this.speeds,
    required this.baseSpeeds,
    required this.noisePhases,
    required this.laneY,
    required this.finishDistance,
    this.elapsedTime = 0.0,
    this.isFinished = false,
    this.winner,
    this.seed = 0,
    List<int>? leadHistory,
    this.currentLeader = 0,
  }) : leadHistory = leadHistory ?? [];

  /// Create initial game state
  factory GameState.initial({int? seed}) {
    final random = Random(seed ?? DateTime.now().millisecondsSinceEpoch);
    final gameSeed = seed ?? random.nextInt(1000000);
    final rng = Random(gameSeed);

    // Initialize 3 cars
    final baseSpeeds = List.generate(3, (i) {
      return GameConstants.baseSpeedMin +
          rng.nextDouble() * (GameConstants.baseSpeedMax - GameConstants.baseSpeedMin);
    });

    final noisePhases = List.generate(3, (i) => rng.nextDouble() * 2 * pi);

    // Lane Y positions (top, middle, bottom)
    final laneY = List.generate(3, (i) {
      return GameConstants.topLaneY + (i * GameConstants.laneSpacing);
    });

    return GameState(
      positions: [0.0, 0.0, 0.0],
      speeds: List.from(baseSpeeds),
      baseSpeeds: baseSpeeds,
      noisePhases: noisePhases,
      laneY: laneY,
      finishDistance: GameConstants.finishDistance,
      seed: gameSeed,
      currentLeader: 0,
    );
  }

  /// Copy with updated values
  GameState copyWith({
    List<double>? positions,
    List<double>? speeds,
    double? elapsedTime,
    bool? isFinished,
    int? winner,
    List<int>? leadHistory,
    int? currentLeader,
  }) {
    return GameState(
      positions: positions ?? List.from(this.positions),
      speeds: speeds ?? List.from(this.speeds),
      baseSpeeds: baseSpeeds,
      noisePhases: noisePhases,
      laneY: laneY,
      finishDistance: finishDistance,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isFinished: isFinished ?? this.isFinished,
      winner: winner ?? this.winner,
      seed: seed,
      leadHistory: leadHistory ?? List.from(this.leadHistory),
      currentLeader: currentLeader ?? this.currentLeader,
    );
  }

  /// Get current leader index
  int getLeader() {
    int leader = 0;
    double maxPos = positions[0];
    for (int i = 1; i < positions.length; i++) {
      if (positions[i] > maxPos) {
        maxPos = positions[i];
        leader = i;
      }
    }
    return leader;
  }

  /// Check if any car finished
  bool checkFinish() {
    for (int i = 0; i < positions.length; i++) {
      if (positions[i] >= finishDistance) {
        return true;
      }
    }
    return false;
  }

  /// Get winner index
  int? getWinner() {
    if (!isFinished) return null;
    int winner = 0;
    double maxPos = positions[0];
    for (int i = 1; i < positions.length; i++) {
      if (positions[i] > maxPos) {
        maxPos = positions[i];
        winner = i;
      }
    }
    return winner;
  }
}
