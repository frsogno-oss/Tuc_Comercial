import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// --- 🎯 INICIO DE LA CORRECCIÓN ---
// Fíjate cómo ahora guardamos las variables que recibe el widget

class MapaComerciosPage extends StatefulWidget {
  // 1. Declaramos las variables finales que el widget guardará
  final LatLng initialPosition;
  final int idSubRubro;

  // 2. El constructor usa "this." para guardar los valores
  const MapaComerciosPage({
    super.key,
    required this.initialPosition,
    required this.idSubRubro,
  });

  @override
  _MapaComerciosPageState createState() => _MapaComerciosPageState();
}
// --- FIN DE LA CORRECCIÓN ---

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

    // Llamamos a la función para buscar comercios
    _fetchNearbyBusinesses(position.latitude, position.longitude);
  }

  // Llama a tu script PHP
  Future<void> _fetchNearbyBusinesses(double lat, double lon) async {
    // Esta línea ahora funciona porque 'widget.idSubRubro' existe
    final uri = Uri.parse(
        'https://tuccomercial.uno/buscar_cercanos.php?latitud=$lat&longitud=$lon&id_sub_rubro=${widget.idSubRubro}');

    // Imprime la URL para verificarla en la consola de depuración
    print('Llamando a la URL: $uri');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          // Esta línea ya estaba correcta, accede a 'comercios'
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
          setState(() {}); // Actualiza el mapa con los marcadores
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
      body: _isLoading || _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          // Usamos la posición del widget como inicial si el GPS falla,
          // o la del GPS si funciona.
          target: _currentPosition ?? widget.initialPosition,
          zoom: 14.0,
        ),
        markers: _markers,
        myLocationEnabled: true, // Opcional: muestra el punto azul del usuario
        myLocationButtonEnabled: true, // Opcional: botón para centrar en el usuario
      ),
    );
  }
}