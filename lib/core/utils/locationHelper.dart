import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:spotly/features/posts/data/models/location_model.dart';

// Este Helper se encarga de obtener la ubicación actual del usuario, manejar los permisos y convertir las coordenadas en nombres geográficos legibles. También incluye una función para mapear el nombre del departamento a su ID correspondiente en la base de datos.
class LocationHelper {
  // Obtiene la ubicación y los nombres geográficos
  static Future<LocationModel?> getCurrentLocationName() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      //Verificación del hardware GPS
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!kIsWeb) {
          await Geolocator.openLocationSettings();
        }
        return Future.error('El GPS está apagado. Por favor, actívalo.');
      }

      //Manejo de Permisos
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Permiso de ubicación denegado.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error('Los permisos están bloqueados en los ajustes del sistema.');
      }

      //Obtener coordenadas actuales
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), 
      );

      //Manejo Web vs Móvil para obtener nombres
      if (kIsWeb) {
        return LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
          city: "Ubicación detectada",
          department: "Navegador Web",
          country: "Bolivia",
        );
      } else {
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, 
            position.longitude
          );

          if (placemarks.isNotEmpty) {
            Placemark place = placemarks[0];
            return LocationModel(
              latitude: position.latitude,
              longitude: position.longitude,
              city: place.locality ?? 'Sin ciudad',
              department: place.administrativeArea ?? 'Sin departamento',
              country: place.country ?? 'Bolivia',
            );
          }
        } catch (e) {
          return LocationModel(
            latitude: position.latitude,
            longitude: position.longitude,
            city: "Coordenadas obtenidas",
            department: "Sin datos de nombre",
            country: "Bolivia",
          );
        }
      }
    } catch (e) {
      print("Error detallado en LocationHelper: $e");
      return Future.error(e.toString());
    }
    return null;
  }

  // Basado en la estructura estándar de 9 departamentos de Bolivia
  static int getDeptoIdByName(String? deptoName) {
    if (deptoName == null || deptoName.isEmpty) return 3; // Cochabamba por defecto
    
    final name = deptoName.toLowerCase();

    if (name.contains('chuquisaca')) return 1;
    if (name.contains('paz')) return 2; // La Paz
    if (name.contains('cocha')) return 3; // Cochabamba
    if (name.contains('oruro')) return 4;
    if (name.contains('potos')) return 5; // Potosí / Potosi
    if (name.contains('tarija')) return 6;
    if (name.contains('santa')) return 7; // Santa Cruz
    if (name.contains('beni')) return 8;
    if (name.contains('pando')) return 9;

    return 3; // Valor por defecto si no hay coincidencia clara
  }
}