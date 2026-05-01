import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class PostLocationSelector extends StatefulWidget {
  final void Function(LatLng coords, String deptoName, String city) onLocationChanged;

  const PostLocationSelector({super.key, required this.onLocationChanged});

  @override
  State<PostLocationSelector> createState() => _PostLocationSelectorState();
}

enum _LocationMode { gps, map, search }

class _PostLocationSelectorState extends State<PostLocationSelector> {
  _LocationMode _mode = _LocationMode.gps;
  LatLng _pinLocation = const LatLng(-17.3935, -66.1570);
  String _displayName = "Cochabamba, Bolivia";
  bool _isGeocoding = false;
  bool _mapExpanded = false;

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Geocodificación inversa: coords → nombre legible (Nominatim OSM, gratis)
  Future<void> _reverseGeocode(LatLng coords) async {
    setState(() => _isGeocoding = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${coords.latitude}&lon=${coords.longitude}'
        '&format=json&accept-language=es',
      );
      final res = await http.get(uri, headers: {'User-Agent': 'SpotlyApp/1.0'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final addr = data['address'] as Map<String, dynamic>;

        final city = addr['city'] ?? addr['town'] ?? addr['village'] ?? addr['county'] ?? '';
        final state = addr['state'] ?? '';
        setState(() => _displayName = '$city, $state');

        // Llamamos al callback del padre con los datos reales
        widget.onLocationChanged(coords, state, city);
      }
    } catch (_) {
      setState(() => _displayName = "${coords.latitude.toStringAsFixed(4)}, ${coords.longitude.toStringAsFixed(4)}");
    } finally {
      setState(() => _isGeocoding = false);
    }
  }

  // Búsqueda directa: texto → lista de lugares (Nominatim)
  Future<void> _searchPlaces(String query) async {
    if (query.length < 3) {
      setState(() => _searchResults = []);
      return;
    }
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=$query&format=json&limit=5&countrycodes=bo&accept-language=es',
      );
      final res = await http.get(uri, headers: {'User-Agent': 'SpotlyApp/1.0'});
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        setState(() {
          _searchResults = list.map((e) => {
            'name': e['display_name'],
            'lat': double.parse(e['lat']),
            'lon': double.parse(e['lon']),
          }).toList();
        });
      }
    } catch (_) {}
  }

  void _selectSearchResult(Map<String, dynamic> result) {
    final coords = LatLng(result['lat'], result['lon']);
    setState(() {
      _pinLocation = coords;
      _searchResults = [];
      _searchController.text = result['name'].toString().split(',').first;
      _mapExpanded = true;
    });
    _mapController.move(coords, 15.0);
    _reverseGeocode(coords);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "UBICACIÓN DEL LUGAR",
          style: TextStyle(
            fontSize: 12,
            color: dark ? Colors.white70 : Colors.black87,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),

        // Selector de modo (3 chips)
        Row(
          children: _LocationMode.values.map((mode) {
            final labels = {
              _LocationMode.gps: ("GPS", Icons.my_location),
              _LocationMode.map: ("Mapa", Icons.map_outlined),
              _LocationMode.search: ("Buscar", Icons.search),
            };
            final selected = _mode == mode;
            return Expanded(
              child: GestureDetector(
                onTap: () async {
                  setState(() { _mode = mode; _mapExpanded = mode == _LocationMode.map; });
                  if (mode == _LocationMode.gps) {
                    await _reverseGeocode(_pinLocation); // aquí integras tu LocationHelper real
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? (dark ? Colors.white12 : Colors.black87)
                        : (dark ? Colors.white10 : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? Colors.transparent : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(labels[mode]!.$2,
                          size: 18, color: selected ? (dark ? Colors.white : Colors.white) : Colors.grey),
                      const SizedBox(height: 4),
                      Text(labels[mode]!.$1,
                          style: TextStyle(
                              fontSize: 11,
                              color: selected ? (dark ? Colors.white : Colors.white) : Colors.grey)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // Modo BUSCAR: campo de texto con resultados
        if (_mode == _LocationMode.search) ...[
          TextField(
            controller: _searchController,
            onChanged: (v) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () => _searchPlaces(v));
            },
            decoration: InputDecoration(
              hintText: "Ej: Parque Nacional Tunari",
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchResults = []);
                      })
                  : null,
              filled: true,
              fillColor: dark ? Colors.white10 : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          // Lista de resultados
          if (_searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final r = _searchResults[i];
                  return ListTile(
                    leading: const Icon(Icons.place_outlined, size: 18),
                    title: Text(r['name'].toString().split(',').first,
                        style: const TextStyle(fontSize: 14)),
                    subtitle: Text(
                      r['name'].toString().split(',').skip(1).take(2).join(','),
                      style: const TextStyle(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _selectSearchResult(r),
                  );
                },
              ),
            ),
          const SizedBox(height: 12),
        ],

        // MAPA interactivo (visible en modo "map" o cuando se seleccionó un resultado de búsqueda)
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: (_mode == _LocationMode.map || (_mode == _LocationMode.search && _mapExpanded))
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: _buildMap(dark),
          secondChild: const SizedBox.shrink(),
        ),

        // Chip con la ubicación seleccionada
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: dark ? Colors.white10 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.place, size: 16, color: Colors.redAccent),
              const SizedBox(width: 8),
              Expanded(
                child: _isGeocoding
                    ? const LinearProgressIndicator()
                    : Text(_displayName,
                        style: TextStyle(fontSize: 13, color: dark ? Colors.white70 : Colors.black87)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMap(bool dark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 260,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _pinLocation,
                initialZoom: 13.0,
                // Al tocar el mapa se mueve el pin
                onTap: (tapPos, latlng) {
                  setState(() => _pinLocation = latlng);
                  _reverseGeocode(latlng);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.spotly.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pinLocation,
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          // Arrastre del pin — convertir offset a LatLng requiere el mapController
                          // Esto es ilustrativo; el tap en onTap del mapa ya cubre el caso
                        },
                        child: const Icon(Icons.location_pin, color: Colors.redAccent, size: 40),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Hint de instrucción
            Positioned(
              bottom: 10, left: 10, right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Toca el mapa para mover el pin",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}