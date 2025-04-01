import 'package:flutter/material.dart';
import 'package:canvas_app/models/pen_stroke_model.dart';

class DrawingPainter extends CustomPainter {
  final List<PenStroke> points;
  final List<List<PenStroke>> strokePoints; // Added strokePoints

  DrawingPainter({
    required this.points,
    this.strokePoints = const [], // Default empty if not provided
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Use the strokePoints list to draw separate strokes
    if (strokePoints.isNotEmpty) {
      for (final stroke in strokePoints) {
        // Draw each stroke group separately
        for (int i = 0; i < stroke.length - 1; i++) {
          Paint paint = Paint()
            ..color = stroke[i].color
            ..strokeWidth = stroke[i].brushWidth
            ..strokeCap = stroke[i].strokeCap;

          canvas.drawLine(stroke[i].offset, stroke[i + 1].offset, paint);
        }
      }
    } else {
      // Fallback to original implementation if strokePoints is not provided
      for (int i = 0; i < points.length - 1; i++) {
        Paint paint = Paint()
          ..color = points[i].color
          ..strokeWidth = points[i].brushWidth
          ..strokeCap = points[i].strokeCap;

        canvas.drawLine(points[i].offset, points[i + 1].offset, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
