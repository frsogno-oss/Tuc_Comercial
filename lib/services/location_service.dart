// lib/services/location_service.dart

import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Obtiene la posición actual del usuario.
  /// Maneja los permisos y la disponibilidad del servicio.
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Revisa si los servicios de localización están activos.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Los servicios de localización están desactivados.');
    }

    // 2. Revisa los permisos.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Los permisos de localización fueron denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // El usuario denegó los permisos permanentemente.
      return Future.error('Los permisos de localización están permanentemente denegados, no podemos solicitar permisos.');
    }

    // 3. Si todo está bien, obtenemos la posición.
    return await Geolocator.getCurrentPosition();
  }
}