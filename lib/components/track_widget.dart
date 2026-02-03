import 'package:flutter/material.dart';

/// Widget to display the race track with road lines
class TrackWidget extends StatelessWidget {
  final double trackWidth;
  final double trackHeight;
  final List<double> laneYPositions;

  const TrackWidget({
    super.key,
    required this.trackWidth,
    required this.trackHeight,
    required this.laneYPositions,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
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
      ],
    );
  }
}

/// Custom painter for road lines
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
  bool shouldRepaint(covariant RoadLinesPainter oldDelegate) =>
      oldDelegate.laneY1 != laneY1 ||
      oldDelegate.laneY2 != laneY2 ||
      oldDelegate.trackWidth != trackWidth;
}
