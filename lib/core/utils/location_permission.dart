import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationUtil {
  // Verifica si el servicio de GPS está activo y si la app tiene permisos.
  static Future<Position?> determinePosition(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si los servicios de ubicación están habilitados.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorSnackBar(context, 'El GPS está desactivado. Por favor, actívalo.');
      return null;
    }

    // Verificar permisos actuales.
    permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      // Solicitar permisos por primera vez.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorSnackBar(context, 'Has rechazado el permiso de ubicación.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // El usuario denegó los permisos permanentemente.
      _showErrorSnackBar(
        context, 
        'Los permisos de ubicación están bloqueados. Actívalos en los ajustes del celular.'
      );
      return null;
    }

    // Si llegamos aquí, tenemos acceso.
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Método privado para mostrar alertas rápidas
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}