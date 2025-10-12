import 'package:flutter/material.dart';

// Definimos nuestra paleta de colores para el nuevo diseño.
class AppColors {
  static const Color background = Color(0xFFF0F2F5);
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color textOnPrimary = Colors.black87;
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color shadow = Color(0xFFE2E8F0);
}

// Aquí definimos el tema completo de la aplicación.
ThemeData buildAppTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primaryYellow,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryYellow,
      primary: AppColors.primaryYellow,
      background: AppColors.background,
    ),

    // Estilo para la barra de navegación superior (AppBar)
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryYellow,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 0.5,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textOnPrimary,
      ),
    ),

    // Estilo para el texto en general
    textTheme: const TextTheme(
      headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
    ),

    // --- CORRECCIÓN FINAL ---
    // Estilo para las tarjetas (Cards)
    cardTheme: CardThemeData( // <-- Se quitó el 'const' para evitar conflictos con el IDE
      elevation: 2.0,
      color: AppColors.cardBackground,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: const BorderSide(color: AppColors.shadow, width: 1.5),
      ),
    ),
    // --- FIN DE LA CORRECCIÓN ---

    // Estilo para la barra de navegación inferior
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.primaryYellow,
      selectedItemColor: AppColors.textOnPrimary,
      unselectedItemColor: AppColors.textOnPrimary.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),

    // Estilo para los botones de texto
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryYellow,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}

