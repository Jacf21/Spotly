import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart';
import 'package:spotly/core/themes/spotly_colors.dart'; 
import 'package:spotly/core/utils/locationHelper.dart';
import 'package:spotly/core/utils/theme_utils.dart'; 

// Este es solo para la sección de ubicación en la pantalla de publicación
class PostLocationSelector extends StatefulWidget {
  final Function(LatLng coords, String deptoName, String city)? onLocationChanged;

  const PostLocationSelector({
    super.key, 
    this.onLocationChanged,
  });

  @override
  State<PostLocationSelector> createState() => _PostLocationSelectorState();
}

class _PostLocationSelectorState extends State<PostLocationSelector> {
  final MapController _mapController = MapController();
  String _city = "";
  String _depto = "";
  LatLng _currentLatLng = const LatLng(-16.4897, -68.1193); // La Paz por defecto
  String _locationTitle = "San Antonio, La Paz";
  String _locationSubtitle = "Bolivia";
  bool _isSearching = false;

  Future<void> _determinePosition() async {
    if (!mounted) return;
    setState(() => _isSearching = true);

    try {
      final locationInfo = await LocationHelper.getCurrentLocationName();

      if (locationInfo != null && mounted) {
        final newLatLng = LatLng(locationInfo.latitude, locationInfo.longitude);
        setState(() {
          _currentLatLng = newLatLng;
          _city = locationInfo.city;
          _depto = locationInfo.department;
          _locationTitle = "$_city, $_depto";
          _locationSubtitle = locationInfo.country;
        });

        if (widget.onLocationChanged != null) {
          widget.onLocationChanged!(
            _currentLatLng, 
            _depto,
            _city,
          );
        }

        // Breve delay para asegurar que el MapController reconozca el nuevo estado
        Future.delayed(const Duration(milliseconds: 150), () {
          _mapController.move(newLatLng, 15.0);
        });
      }
    } catch (e) {
      // AQUÍ capturamos el Future.error del Helper y lo mostramos al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("📍 $e"),
            backgroundColor: Colors.orange[800],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _onMapMoved(LatLng newCoords) {
     if (widget.onLocationChanged != null) {
        widget.onLocationChanged!(newCoords, _depto, _city);
     }
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "UBICACIÓN EN BOLIVIA",
              style: TextStyle(
                fontSize: 12, 
                color: dark ? Colors.white70 : Colors.black87, 
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
                  style: TextStyle(color: SpotlyColors.accent(dark))),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLatLng,
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.spotly.app',
                  tileBuilder: dark ? (context, tileWidget, tile) {
                    return ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        -0.9,  0,  0, 0, 255,
                         0, -0.9,  0, 0, 255,
                         0,  0, -0.9, 0, 255,
                         0,  0,  0, 1, 0,
                      ]),
                      child: tileWidget,
                    );
                  } : null,
                ),
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

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: dark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: dark ? Colors.white10 : Colors.grey[200]!),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: SpotlyColors.accent(dark),
                radius: 18,
                child: Icon(Icons.map_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_locationTitle, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 14,
                        color: dark ? Colors.white : Colors.black87
                      )),
                    Text(_locationSubtitle, 
                      style: TextStyle(
                        color: dark ? Colors.white38 : Colors.grey, 
                        fontSize: 12
                      )),
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
