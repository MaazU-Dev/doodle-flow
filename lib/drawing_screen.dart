import 'dart:typed_data';

import 'package:canvas_app/components/draw_painter.dart';
import 'package:canvas_app/models/pen_stroke_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:canvas_app/providers/color_provider.dart';
import 'package:canvas_app/providers/pen_stroke_provider.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:canvas_app/utils/functions.dart';

class DrawringView extends StatefulWidget {
  const DrawringView({super.key});

  @override
  State<DrawringView> createState() => _DrawringViewState();
}

class _DrawringViewState extends State<DrawringView> {
  double brushWidth = 5.0;
  double eraserWidth = 20.0;
  bool isErasing = false;
  StrokeCap strokeCap = StrokeCap.round;
  bool _showGestureInfo = true; // Control visibility of gesture info bar

  // Add a GlobalKey for the RepaintBoundary
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final colorProvider = Provider.of<ColorProvider>(context);
    final penStrokeProvider = Provider.of<PenStrokeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DoodleFlow',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          _getInfo(),
        ],
        backgroundColor: const Color.fromARGB(255, 234, 117, 117),
      ),
      body: Column(
        children: [
          if (_showGestureInfo) _buildGestureInfoBar(),
          Expanded(
            child: Container(
              color: Colors.white,
              child: RepaintBoundary(
                key: _repaintBoundaryKey,
                child: GestureDetector(
                  onPanStart: (details) {
                    RenderBox renderBox =
                        context.findRenderObject() as RenderBox;
                    Offset localPosition =
                        renderBox.globalToLocal(details.globalPosition);
                    penStrokeProvider.addStroke(PenStroke(
                      color: isErasing
                          ? Colors.white
                          : colorProvider.selectedColor,
                      offset: localPosition,
                      brushWidth: isErasing ? eraserWidth : brushWidth,
                      strokeCap: strokeCap,
                    ));
                  },
                  onPanEnd: (details) {
                    // End the current stroke when the user lifts their finger
                    penStrokeProvider.endStroke();
                  },
                  onHorizontalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dx < -300) {
                      bool undoSuccessful = penStrokeProvider.undoLastStroke();
                      showCustomSnackBar(
                        context,
                        undoSuccessful
                            ? 'Last stroke undone'
                            : 'Nothing to undo',
                        isSuccess: undoSuccessful,
                      );
                    }
                    // Ensure we end the stroke here too
                    penStrokeProvider.endStroke();
                  },
                  onTap: () {
                    colorProvider.updateRandomColor();
                  },
                  onDoubleTap: () {
                    penStrokeProvider.clearStrokes();
                  },
                  onLongPress: () async {
                    await _captureAndShowDrawing(context);
                  },
                  onPanUpdate: (details) {
                    RenderBox renderBox =
                        context.findRenderObject() as RenderBox;
                    Offset localPosition =
                        renderBox.globalToLocal(details.globalPosition);
                    print(localPosition);
                    penStrokeProvider.addStroke(PenStroke(
                      color: isErasing
                          ? Colors.white
                          : colorProvider.selectedColor,
                      offset: localPosition,
                      brushWidth: isErasing ? eraserWidth : brushWidth,
                      strokeCap: strokeCap,
                    ));
                  },
                  child: CustomPaint(
                    painter: DrawingPainter(
                      points: penStrokeProvider.points,
                      strokePoints: penStrokeProvider.strokePoints,
                    ),
                    size: Size.infinite,
                    child: Container(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _getBottomNavBar(colorProvider, penStrokeProvider),
    );
  }

  Widget _getInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo/logo-new.png',
              height: 30,
              width: 30,
            ),
            const SizedBox(width: 8),
            const Text(
              'By Maaz Umar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGestureInfoBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(109, 223, 218, 218),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildGestureItem(Icons.touch_app, "Tap", "Change color"),
                  _buildGestureItem(Icons.swipe_left, "Swipe left", "Undo"),
                  _buildGestureItem(
                      Icons.touch_app_outlined, "Double tap", "Clear all"),
                  _buildGestureItem(
                      Icons.touch_app_rounded, "Long press", "Preview"),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              setState(() {
                _showGestureInfo = false;
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 16,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildGestureItem(IconData icon, String gesture, String action) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color.fromARGB(255, 234, 117, 117)),
          const SizedBox(width: 4),
          Text(
            "$gesture: ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey[800],
            ),
          ),
          Text(
            action,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndShowDrawing(BuildContext context) async {
    try {
      // Capture the RepaintBoundary as an image
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();

        await _showImagePreviewDialog(context, pngBytes);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate image preview: $e')),
      );
    }
  }

  Future<void> _showImagePreviewDialog(
      BuildContext context, Uint8List imageBytes) async {
    return await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your Masterpiece',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 234, 117, 117),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 30),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getBottomNavBar(
      ColorProvider colorProvider, PenStrokeProvider penStrokeProvider) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomAppBar(
          color: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: Icons.color_lens,
                label: 'Color',
                isSelected: !isErasing,
                color: colorProvider.selectedColor,
                onPressed: () {
                  setState(() {
                    isErasing = false;
                  });
                },
              ),
              _buildNavItem(
                icon: Icons.brush,
                label: 'Brush',
                isSelected: !isErasing,
                color: Colors.black87,
                onPressed: () {
                  setState(() {
                    isErasing = false;
                  });
                },
              ),
              _buildNavItem(
                icon: Icons.cleaning_services,
                label: 'Eraser',
                isSelected: isErasing,
                color: Colors.blue,
                onPressed: () {
                  setState(() {
                    isErasing = true;
                  });
                },
              ),
              _buildNavItem(
                icon: Icons.delete_outline_rounded,
                label: 'Clear',
                isSelected: false,
                color: Colors.redAccent,
                onPressed: () {
                  penStrokeProvider.clearStrokes();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 2,
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              flex: 1,
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
