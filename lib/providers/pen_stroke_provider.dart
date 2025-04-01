import 'package:canvas_app/models/pen_stroke_model.dart';
import 'package:flutter/material.dart';

class PenStrokeProvider extends ChangeNotifier {
  List<PenStroke> _points = [];
  List<List<PenStroke>> _strokePoints = []; // List of stroke groups
  bool _isNewStroke = true; // Track when a new stroke should begin

  List<PenStroke> get points => _points;
  List<List<PenStroke>> get strokePoints => _strokePoints;

  void addStroke(PenStroke stroke) {
    _points.add(stroke);

    // Handle separate strokes
    if (_isNewStroke) {
      _strokePoints.add([stroke]); // Start a new stroke
      _isNewStroke = false;
    } else {
      // Add to the current stroke
      _strokePoints.last.add(stroke);
    }

    notifyListeners();
  }

  // Call this when the user lifts their finger
  void endStroke() {
    _isNewStroke = true;
    notifyListeners();
  }

  void clearStrokes() {
    _points.clear();
    _strokePoints.clear();
    _isNewStroke = true;
    notifyListeners();
  }

  bool undoLastStroke() {
    if (_strokePoints.isNotEmpty) {
      // Remove the last stroke group
      List<PenStroke> lastStroke = _strokePoints.removeLast();

      // Remove all points of the last stroke from the points list
      for (var point in lastStroke) {
        _points.remove(point);
      }

      notifyListeners();
      return true;
    }
    return false;
  }
}
