import 'dart:math';
import 'package:flutter/material.dart';

class CircularAudioVisualizer extends StatelessWidget {
  final double size;
  final List<double> waveformData;
  final Color startColor;
  final Color endColor;

  const CircularAudioVisualizer({
    super.key,
    required this.size,
    required this.waveformData,
    required this.startColor,
    required this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: CircularWaveformPainter(
        waveformData: waveformData,
        startColor: startColor,
        endColor: endColor,
      ),
    );
  }
}

class CircularWaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color startColor;
  final Color endColor;

  CircularWaveformPainter({
    required this.waveformData,
    required this.startColor,
    required this.endColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < waveformData.length; i++) {
      final angle = 2 * pi * i / waveformData.length;
      final amplitude = waveformData[i] * radius / 2;

      final innerPoint = Offset(
        center.dx + (radius - amplitude) * cos(angle),
        center.dy + (radius - amplitude) * sin(angle),
      );
      final outerPoint = Offset(
        center.dx + (radius + amplitude) * cos(angle),
        center.dy + (radius + amplitude) * sin(angle),
      );

      final progress = i / waveformData.length;
      final color = Color.lerp(startColor, endColor, progress)!;
      paint.color = color;

      canvas.drawLine(innerPoint, outerPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
