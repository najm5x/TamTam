import 'package:flutter/material.dart';
import 'package:tamtam/presentation/screens/home_screen.dart';
import 'package:tamtam/presentation/theme/app_theme.dart';

void main() {
  runApp(const TamTamApp());
}

class TamTamApp extends StatelessWidget {
  const TamTamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TamTam',
      theme: AppTheme.theme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
