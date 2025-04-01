import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:canvas_app/providers/color_provider.dart';
import 'package:canvas_app/providers/pen_stroke_provider.dart';
import 'package:canvas_app/drawing_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ColorProvider()),
        ChangeNotifierProvider(create: (_) => PenStrokeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canvas App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DrawringView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
