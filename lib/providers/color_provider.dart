import 'package:flutter/material.dart';
import 'dart:math';

class ColorProvider with ChangeNotifier {
  Color _selectedColor = Colors.black;

  Color get selectedColor => _selectedColor;

  void updateColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  void updateRandomColor() {
    _selectedColor =
        Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    notifyListeners();
  }
}
