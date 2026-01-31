import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/bet_state.dart';
import '../engine/game_engine.dart';
import '../utils/game_constants.dart';
import '../utils/orientation_helper.dart';
import 'new_result_screen.dart';

class NewRaceScreen extends StatefulWidget {
  final BetState betState;

  const NewRaceScreen({super.key, required this.betState});

  @override
  State<NewRaceScreen> createState() => _NewRaceScreenState();
}

class _NewRaceScreenState extends State<NewRaceScreen> {
  late GameEngine _engine;
  Timer? _gameLoop;
  bool _isRacing = false;
  final List<Color> _carColors = [Colors.red, Colors.blue, Colors.green];
  final List<String> _carNames = ['Car 1', 'Car 2', 'Car 3'];

  @override
  void initState() {
    super.initState();
    OrientationHelper.setLandscape();
    _engine = GameEngine();
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    OrientationHelper.setAll();
    super.dispose();
  }

  void _startRace() {
    if (_isRacing) return;

    setState(() {
      _isRacing = true;
    });

    // Game loop at 60fps
    _gameLoop = Timer.periodic(
      const Duration(milliseconds: 16), // ~60fps
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        _engine.update(16 / 1000.0); // deltaTime in seconds

        setState(() {});

        // Check if race finished
        if (_engine.state.isFinished) {
          timer.cancel();
          _onRaceFinished();
        }
      },
    );
  }

  void _onRaceFinished() {
    final winner = _engine.state.winner;
    if (winner == null) return;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NewResultScreen(
            betState: widget.betState,
            winner: winner,
            engine: _engine,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = _engine.state;
    final rankings = _engine.getRankings();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade200, Colors.green.shade100],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isRacing ? 'Đang đua...' : 'Sẵn sàng',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    if (!_isRacing)
                      ElevatedButton(
                        onPressed: _startRace,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('BẮT ĐẦU'),
                      ),
                  ],
                ),
              ),

              // Race track
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final trackHeight = constraints.maxHeight;
                    final trackWidth = constraints.maxWidth;
                    // Calculate lane positions based on actual track height
                    final laneSpacing = trackHeight / 3;
                    final laneYPositions = List.generate(3, (index) {
                      return (index + 0.5) * laneSpacing;
                    });

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Stack(
                        children: [
                          // Track background
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.grey.shade400,
                                    Colors.grey.shade600,
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.grey.shade800,
                                  width: 4,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: CustomPaint(
                                painter: RoadLinesPainter(
                                  laneY1: laneYPositions[0],
                                  laneY2: laneYPositions[1],
                                  trackWidth: trackWidth,
                                ),
                              ),
                            ),
                          ),

                          // Start line
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 6,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                border: Border.symmetric(
                                  vertical: BorderSide(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Finish line
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 6,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                border: Border.symmetric(
                                  vertical: BorderSide(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Cars
                          ...List.generate(3, (index) {
                            final progress = _engine.getProgress(index);
                            final availableWidth =
                                trackWidth - 40; // Account for margins
                            final carX = (availableWidth * progress).clamp(
                              0.0,
                              availableWidth - GameConstants.carWidth,
                            );
                            // Use calculated lane Y position
                            final carY =
                                laneYPositions[index] -
                                GameConstants.carHeight / 2;

                            return Positioned(
                              left: carX,
                              top: carY,
                              child: Icon(
                                Icons.directions_car,
                                color: _carColors[index],
                                size: 50,
                              ),
                            );
                          }),

                          // Progress bars on the side
                          Positioned(
                            right: 8,
                            top:
                                laneYPositions[0] - GameConstants.carHeight / 2,
                            child: Column(
                              children: List.generate(3, (index) {
                                final progress = _engine.getProgress(index);
                                return Container(
                                  margin: EdgeInsets.only(
                                    bottom: index < 2
                                        ? laneSpacing - GameConstants.carHeight
                                        : 0,
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
                                      height:
                                          GameConstants.carHeight * progress,
                                      decoration: BoxDecoration(
                                        color: _carColors[index],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Info panel
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white.withOpacity(0.9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(3, (index) {
                    return Column(
                      children: [
                        Text(
                          _carNames[index],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _carColors[index],
                          ),
                        ),
                        Text(
                          '${rankings[index]}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${state.speeds[index].toStringAsFixed(0)} px/s',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Road lines painter
class RoadLinesPainter extends CustomPainter {
  final double laneY1;
  final double laneY2;
  final double trackWidth;

  RoadLinesPainter({
    required this.laneY1,
    required this.laneY2,
    required this.trackWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow.shade700
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Dashed lines
    const dashLength = 30.0;
    const dashSpace = 20.0;
    double currentX = 20;

    while (currentX < trackWidth - 20) {
      canvas.drawLine(
        Offset(currentX, laneY1),
        Offset(currentX + dashLength, laneY1),
        paint,
      );
      canvas.drawLine(
        Offset(currentX, laneY2),
        Offset(currentX + dashLength, laneY2),
        paint,
      );
      currentX += dashLength + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
