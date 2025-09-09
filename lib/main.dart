// main.dart

import 'package:flutter/material.dart';
import 'screens/main_navigator.dart';
// import 'screens/mapa_comercios.dart'; // No necesitas esta importación si no la usas en main.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuc Comercial',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      // Vuelve a la pantalla de inicio original
      home: const MainNavigator(),
      debugShowCheckedModeBanner: false,
    );
  }
}