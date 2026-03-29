import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart'; 
import 'package:spotly/core/utils/location_helper.dart'; 
import 'package:spotly/features/auth/data/models/location_model.dart';

class PostLocationSelector extends StatefulWidget {
  const PostLocationSelector({super.key});

  @override
  State<PostLocationSelector> createState() => _PostLocationSelectorState();
}

class _PostLocationSelectorState extends State<PostLocationSelector> {
  //Variables de estado declaradas
  final MapController _mapController = MapController();
  LatLng _currentLatLng = const LatLng(-16.4897, -68.1193); // La Paz por defecto
  String _locationTitle = "Salar de Uyuni, Potosí";
  String _locationSubtitle = "Bolivia";
  bool _isSearching = false;

  Future<void> _determinePosition() async {
    if (!mounted) return;
    setState(() => _isSearching = true);

    final locationInfo = await LocationHelper.getCurrentLocationName();

    if (locationInfo != null && mounted) {
      setState(() {
        _currentLatLng = LatLng(locationInfo.latitude, locationInfo.longitude);
        _locationTitle = "${locationInfo.city}, ${locationInfo.department}";
        _locationSubtitle = locationInfo.country;
        _isSearching = false;
      });
      _mapController.move(_currentLatLng, 15.0);
    } else {
      setState(() => _isSearching = false);
    }
  }

  
@override
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      //CABECERA CON BOTÓN
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "UBICACIÓN EN BOLIVIA",
            style: TextStyle(
              fontSize: 12, 
              color: Color.fromARGB(255, 2, 2, 2), 
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1
            ),
          ),
          TextButton.icon(
            onPressed: _isSearching ? null : _determinePosition,
            icon: _isSearching 
                ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location, size: 16),
            label: Text(_isSearching ? "Buscando..." : "Cambiar", 
                style: const TextStyle(color: Colors.cyan)),
          ),
        ],
      ),

      const SizedBox(height: 8),

      //EL MAPA (Contenedor con altura fija)
      ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          height: 180, // VITAL: Sin esto el mapa no se ve
          width: double.infinity,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLatLng,
              initialZoom: 13.0,
            ),
            children: [
              // Capa de imágenes del mapa (OpenStreetMap)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.spotly.app',
              ),
              // El PIN rojo en el centro
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLatLng,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 12),

      //INFORMACIÓN DETALLADA (Ciudad y Departamento)
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.cyan,
              radius: 18,
              child: Icon(Icons.map_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_locationTitle, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(_locationSubtitle, 
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
}
