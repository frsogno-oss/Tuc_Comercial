// main.dart

import 'package:flutter/material.dart';
import 'screens/main_navigator.dart';
import 'theme.dart'; // <-- 1. IMPORTAMOS NUESTRO ARCHIVO DE TEMA

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuc Comercial',
      // --- 2. APLICAMOS EL NUEVO TEMA ---
      // Todo el diseño (colores, fuentes, estilos de barras y tarjetas)
      // ahora será controlado por la función buildAppTheme().
      theme: buildAppTheme(),
      // ------------------------------------
      home: const MainNavigator(),
      debugShowCheckedModeBanner: false,
    );
  }
}

