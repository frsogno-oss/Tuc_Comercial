import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ciudad.dart';
import '../models/comercio.dart';
import '../models/rubro.dart';
import '../models/sub_rubro.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'offers_screen.dart';
import 'publish_screen.dart';
import 'contact_screen.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();

  List<Ciudad> _ciudades = [];
  Ciudad? _ciudadSeleccionada;
  Map<String, dynamic>? _datosDeCiudad;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final ciudadesData = await _apiService.getCiudades();
      if (ciudadesData.isEmpty) {
        throw Exception("No se encontraron ciudades.");
      }
      _ciudades = ciudadesData;

      final prefs = await SharedPreferences.getInstance();
      final idCiudadGuardada = prefs.getInt('ultima_ciudad_id');

      _ciudadSeleccionada = _ciudades.firstWhere(
            (c) => c.id == idCiudadGuardada,
        orElse: () => _ciudades.first,
      );

      await _cargarDatosDeCiudad(_ciudadSeleccionada!);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error al conectar: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cargarDatosDeCiudad(Ciudad ciudad) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _ciudadSeleccionada = ciudad;
    });
    try {
      _datosDeCiudad = await _apiService.getDatosCompletos(ciudad.id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('ultima_ciudad_id', ciudad.id);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error al cargar datos: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        // Los estilos (colores, etc.) ahora vienen del theme.dart
        // Solo definimos los íconos aquí.
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // Icono relleno cuando está activo
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer_outlined),
            activeIcon: Icon(Icons.local_offer),
            label: 'Ofertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_business_outlined),
            activeIcon: Icon(Icons.add_business),
            label: 'Publicar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_phone_outlined),
            activeIcon: Icon(Icons.contact_phone),
            label: 'Contacto',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _cargarDatosIniciales, child: const Text('Reintentar')),
          ]),
        ),
      );
    }
    if (_datosDeCiudad != null && _ciudadSeleccionada != null) {
      final List<Widget> screens = [
        HomeScreen(
          ciudades: _ciudades,
          ciudadActual: _ciudadSeleccionada!,
          onCiudadCambiada: _cargarDatosDeCiudad,
          rubros: _datosDeCiudad!['rubros'] as List<Rubro>,
          subRubros: _datosDeCiudad!['subRubros'] as List<SubRubro>,
          comercios: _datosDeCiudad!['comercios'] as List<Comercio>,
        ),
        OffersScreen(
          comerciosEnOferta: (_datosDeCiudad!['comercios'] as List<Comercio>).where((c) => c.tieneOferta).toList(),
        ),
        PublishScreen(
          rubros: _datosDeCiudad!['rubros'] as List<Rubro>,
          subRubros: _datosDeCiudad!['subRubros'] as List<SubRubro>,
          ciudadActual: _ciudadSeleccionada!,
          ciudades: _ciudades,
        ),
        const ContactScreen(),
      ];
      return IndexedStack(index: _selectedIndex, children: screens);
    }
    // --- CORRECCIÓN APLICADA AQUÍ ---
    // Este es el return que faltaba.
    return const Center(child: Text('Error inesperado. Intenta reiniciar la app.'));
  }
}

