import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:spotly/features/auth/data/models/location_model.dart';

class LocationHelper {
  static Future<LocationModel?> getCurrentLocationName() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      //¿Está el GPS encendido en el celular?
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('El GPS está apagado. Por favor, actívalo.');
      }

      //Verificar permisos
      permission = await Geolocator.checkPermission();
      
      // Si el permiso fue denegado antes, lo pedimos de nuevo
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission(); //ESTA LÍNEA ABRE LA VENTANA
        if (permission == LocationPermission.denied) {
          return Future.error('Permiso de ubicación denegado.');
        }
      }

      // Si el usuario bloqueó el permiso permanentemente
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Los permisos están bloqueados permanentemente en ajustes.');
      }

      //Si todo está OK, obtenemos la posición
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      // 4. Geocoding (Convertir a nombres de Bolivia)
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
      print("Error en LocationHelper: $e");
    }
    return null;
  }
}