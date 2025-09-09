// lib/screens/mapa_selector.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Importamos Fluttertoast

class MapaSelectorPage extends StatefulWidget {
  const MapaSelectorPage({super.key});

  @override
  _MapaSelectorPageState createState() => _MapaSelectorPageState();
}

class _MapaSelectorPageState extends State<MapaSelectorPage> {
  LatLng _selectedPosition = const LatLng(-26.8329, -65.2045);
  final Set<Marker> _markers = {};
  bool _canUseCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _checkLocationServiceStatus();
    _addMarker(_selectedPosition);
  }

  void _checkLocationServiceStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (serviceEnabled && permission != LocationPermission.denied) {
      setState(() {
        _canUseCurrentLocation = true;
      });
    }
  }

  void _useCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      Navigator.pop(context, currentLocation);
      Fluttertoast.showToast(msg: 'Ubicación actual guardada.');
    } catch (e) {
      print("Error al obtener la ubicación actual: $e");
      Fluttertoast.showToast(msg: 'Error al obtener la ubicación.');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    // Ya tenemos un marcador inicial
  }

  void _onTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _addMarker(position);
    });
  }

  void _addMarker(LatLng position) {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('selected_location'),
        position: position,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona la ubicación del comercio'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _selectedPosition,
          zoom: 14,
        ),
        markers: _markers,
        onTap: _onTap,
        onMapCreated: _onMapCreated,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_canUseCurrentLocation)
            FloatingActionButton.extended(
              onPressed: _useCurrentLocation,
              label: const Text('Usar mi ubicación actual'),
              icon: const Icon(Icons.my_location),
            ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.pop(context, _selectedPosition);
              Fluttertoast.showToast(msg: 'Ubicación guardada con éxito.');
            },
            label: const Text('Confirmar ubicación'),
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}