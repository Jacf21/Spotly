import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/core/utils/location_permission.dart';
import 'package:spotly/features/search/data/repositories/search_repository.dart';

// Este widget es el que muestra la grilla de lugares filtrados por distancia o departamento
class PlacesGrid extends StatelessWidget {
  final String type;
  final dynamic value; 
  final bool dark;

  const PlacesGrid({
    super.key,
    required this.type,
    required this.value,
    required this.dark,
  });

  Future<List<Map<String, dynamic>>> _fetchData(BuildContext context) async {
    final repo = SearchRepository();

    if (type == 'distancia') {
      // pedimos permiso para activar gps y permiso para la app
      Position? position = await LocationUtil.determinePosition(context);
      
      // Si la posición es nula (permiso denegado), detenemos la búsqueda
      if (position == null) return [];
      return await repo.getNearbyPlaces(
        position.latitude, 
        position.longitude, 
        value as double,
      );
    } else {
      // Búsqueda por Departamento
      if (value == null) return [];
      return await repo.getPlacesByDept(value as int);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchData(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error al cargar destinos", style: TextStyle(color: SpotlyColors.subText(dark))));
        }

        final places = snapshot.data ?? [];

        if (places.isEmpty) {
          return Center(
            child: Text(
              type == 'distancia' 
                ? "No hay lugares en este radio" 
                : "Selecciona un departamento",
              style: TextStyle(color: SpotlyColors.subText(dark)),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 1,
          ),
          itemCount: places.length,
          itemBuilder: (context, index) {
            final place = places[index];
            return GestureDetector(
              onTap: () {
                final String id = place['id_lugar'].toString();
                Navigator.pop(context);
                context.push('/lugar/$id');
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // La Imagen del lugar
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(place['foto_portada_url'] ?? 'https://via.placeholder.com/300'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  
                  // El Nombre del lugar
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                    child: Text(
                      place['nombre_lugar'] ?? 'Sin nombre',
                      style: TextStyle(
                        color: SpotlyColors.text(dark),
                        fontSize: 11, 
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}