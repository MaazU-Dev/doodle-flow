import 'package:flutter/widgets.dart';

class PenStroke {
  Color color;
  double brushWidth;
  Offset offset;
  StrokeCap strokeCap;

  PenStroke({
    required this.color,
    required this.brushWidth,
    required this.offset,
    required this.strokeCap,
  });
}
