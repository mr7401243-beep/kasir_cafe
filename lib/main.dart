import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const FeyCoffeeApp());
}

class FeyCoffeeApp extends StatelessWidget {
  const FeyCoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FEY COFFEE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFFF5EFE6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4E342E),
          foregroundColor: Colors.white,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}