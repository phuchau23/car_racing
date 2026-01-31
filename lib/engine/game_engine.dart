import 'dart:math';
import '../models/game_state.dart';
import '../utils/game_constants.dart';

/// Game engine that handles game loop and physics
class GameEngine {
  GameState _state;

  GameEngine({GameState? initialState, int? seed})
      : _state = initialState ?? GameState.initial(seed: seed);

  GameState get state => _state;

  /// Update game state by deltaTime (in seconds)
  void update(double deltaTime) {
    if (_state.isFinished) return;

    final newPositions = List<double>.from(_state.positions);
    final newSpeeds = List<double>.from(_state.speeds);
    final newElapsedTime = _state.elapsedTime + deltaTime;
    final newLeadHistory = List<int>.from(_state.leadHistory);
    int newCurrentLeader = _state.currentLeader;

    // Calculate speeds for each car
    for (int i = 0; i < 3; i++) {
      // 1. Base speed
      double speed = _state.baseSpeeds[i];

      // 2. Noise speed (smooth variation using sine wave)
      final noiseValue = sin(
        newElapsedTime * GameConstants.noiseFrequency * 2 * pi +
            _state.noisePhases[i],
      );
      speed += GameConstants.noiseAmplitude * noiseValue;

      // 3. Rubber banding
      final leader = _state.getLeader();
      if (leader == i) {
        // Leader: slow down slightly
        final distanceAhead = _state.positions[i] -
            _state.positions[(i + 1) % 3]
                .clamp(0, _state.positions[i]);
        final distanceAhead2 = _state.positions[i] -
            _state.positions[(i + 2) % 3]
                .clamp(0, _state.positions[i]);
        final maxDistance = max(distanceAhead, distanceAhead2);
        if (maxDistance > 0) {
          final rubberFactor = (maxDistance / GameConstants.maxDistanceForRubberBand)
              .clamp(0.0, 1.0);
          speed -= GameConstants.rubberBandStrength * rubberFactor;
        }
      } else {
        // Behind: speed up slightly
        final distanceBehind = _state.positions[leader] - _state.positions[i];
        if (distanceBehind > 0 && distanceBehind < GameConstants.maxDistanceForRubberBand) {
          final rubberFactor =
              (1.0 - distanceBehind / GameConstants.maxDistanceForRubberBand);
          speed += GameConstants.rubberBandStrength * rubberFactor;
        }
      }

      // Clamp speed to reasonable values
      speed = speed.clamp(30.0, 200.0);
      newSpeeds[i] = speed;

      // Update position
      newPositions[i] += speed * deltaTime;
      newPositions[i] = newPositions[i].clamp(0.0, _state.finishDistance);
    }

    // Track lead changes
    final newLeader = _getLeader(newPositions);
    if (newLeader != newCurrentLeader) {
      newLeadHistory.add(newLeader);
      newCurrentLeader = newLeader;
    }

    // Check finish
    bool isFinished = false;
    int? winner;
    for (int i = 0; i < newPositions.length; i++) {
      if (newPositions[i] >= _state.finishDistance) {
        isFinished = true;
        if (winner == null || newPositions[i] > newPositions[winner]) {
          winner = i;
        }
      }
    }

    _state = _state.copyWith(
      positions: newPositions,
      speeds: newSpeeds,
      elapsedTime: newElapsedTime,
      isFinished: isFinished,
      winner: winner,
      leadHistory: newLeadHistory,
      currentLeader: newCurrentLeader,
    );
  }

  /// Get current leader index
  int _getLeader(List<double> positions) {
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

  /// Reset game state
  void reset({int? seed}) {
    _state = GameState.initial(seed: seed);
  }

  /// Get progress percentage (0.0 to 1.0) for a car
  double getProgress(int carIndex) {
    return (_state.positions[carIndex] / _state.finishDistance).clamp(0.0, 1.0);
  }

  /// Get current ranking (1st, 2nd, 3rd) for each car
  List<int> getRankings() {
    final positions = List<double>.from(_state.positions);
    final sorted = List<int>.generate(3, (i) => i);
    sorted.sort((a, b) => positions[b].compareTo(positions[a]));
    final rankings = List<int>.filled(3, 0);
    for (int i = 0; i < sorted.length; i++) {
      rankings[sorted[i]] = i + 1;
    }
    return rankings;
  }
}
