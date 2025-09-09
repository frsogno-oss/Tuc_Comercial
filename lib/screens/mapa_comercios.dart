import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Agregamos 'const' y 'key' al constructor
class MapaComerciosPage extends StatefulWidget {
  const MapaComerciosPage({super.key, required LatLng initialPosition, required int idSubRubro});

  @override
  _MapaComerciosPageState createState() => _MapaComerciosPageState();
}

// Clase de estado para MapaComerciosPage
class _MapaComerciosPageState extends State<MapaComerciosPage> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  LatLng? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // Obtiene la ubicación actual del usuario
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
      });
      return Future.error('Los servicios de ubicación están deshabilitados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
        });
        return Future.error('Los permisos de ubicación fueron denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
      });
      return Future.error(
          'Los permisos de ubicación fueron denegados permanentemente.');
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });

    _fetchNearbyBusinesses(position.latitude, position.longitude);
  }

  // Llama a tu script PHP
  Future<void> _fetchNearbyBusinesses(double lat, double lon) async {
    // Reemplaza 'http' por 'https' si tu servidor usa SSL.
    // También, asegúrate de que la IP y el puerto sean correctos.
    final uri = Uri.parse(
        'https://tuccomercial.uno/buscar_cercanos.php?latitud=$lat&longitud=$lon');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          List<dynamic> comercios = jsonResponse['comercios'] as List<dynamic>;
          _markers.clear();
          for (var comercio in comercios) {
            _markers.add(
              Marker(
                markerId: MarkerId(comercio['id'].toString()),
                position: LatLng(
                  double.parse(comercio['latitud']),
                  double.parse(comercio['longitud']),
                ),
                infoWindow: InfoWindow(
                  title: comercio['nombre'],
                  snippet: comercio['descripcion'],
                ),
              ),
            );
          }
          setState(() {});
        } else {
          // Muestra el mensaje de error del servidor
          print('Error del servidor: ${jsonResponse['message']}');
        }
      } else {
        // Maneja el error de la petición HTTP (ej. 404, 500)
        print('Error de petición HTTP: ${response.statusCode}');
      }
    } catch (e) {
      // Maneja errores de red o de parseo
      print('Error en la llamada a la API: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comercios Cercanos'),
      ),
      body: _isLoading || _currentPosition == null // <-- ¡Condición corregida!
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _currentPosition!,
          zoom: 14.0,
        ),
        markers: _markers,
      ),
    );
  }
}