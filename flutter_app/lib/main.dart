import 'package:flutter/material.dart';
import './splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Yield Prediction',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green[500]!,
          primary: Colors.green[500],
          secondary: Colors.amber[600],
          surface: Colors.brown[50],
          background: Colors.brown[25],
        ),
        scaffoldBackgroundColor: Colors.brown[25],
        appBarTheme: const AppBarTheme(
          elevation: 2,
          backgroundColor: Color(0xFF81C784),
          foregroundColor: Colors.brown,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.brown,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          color: Colors.brown[50],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[500],
            foregroundColor: Colors.brown[900],
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.green[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.green[500]!,
              width: 2,
            ),
          ),
          labelStyle: TextStyle(
            color: Colors.green[700],
            fontSize: 16,
          ),
          iconColor: Colors.green[600],
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: Colors.green[800],
            height: 1.3,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.brown[800],
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: Colors.brown[800],
            height: 1.4,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Colors.brown[700],
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.green[600],
          size: 28,
        ),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: SplashToHome(), // Removed const if constructor isn't const
    );
  }
}
