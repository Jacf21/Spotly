import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Esta clase es la que se muestra en la pestaña de "Lugares" dentro del buscador
class SearchPlacesTab extends StatelessWidget {
  final String query;
  final bool dark;

  const SearchPlacesTab({
    super.key, // Añadido super.key
    required this.query,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos los colores del tema actual
    final backgroundColor = SpotlyColors.bg(dark);
    final textColor = SpotlyColors.text(dark);
    final subTextColor = SpotlyColors.subText(dark);
    return Container(
      color: backgroundColor,
      child: _buildContent(backgroundColor, textColor, subTextColor, context),
    );
  }

  Widget _buildContent(Color bg, Color txt, Color subTxt, BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text(
          "Busca destinos increíbles",
          style: TextStyle(color: subTxt),
        ),
      );
    }

    return FutureBuilder(
      future: Supabase.instance.client
          .from('lugares')
          .select()
          .ilike('nombre_lugar', '%$query%')
          .limit(15),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: SpotlyColors.accent(dark)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error al buscar lugares",
              style: TextStyle(color: txt),
            ),
          );
        }

        final places = snapshot.data as List? ?? [];

        if (places.isEmpty) {
          return Center(
            child: Text(
              "No encontramos ese lugar",
              style: TextStyle(color: subTxt),
            ),
          );
        }

        return ListView.builder(
          itemCount: places.length,
          itemBuilder: (context, index) {
            final place = places[index];
            return ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: dark ? Colors.white10 : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  LucideIcons.mapPin,
                  color: dark ? Colors.white70 : Colors.black54,
                  size: 20,
                ),
              ),
              title: Text(
                place['nombre_lugar'] ?? 'Lugar sin nombre',
                style: TextStyle(
                  color: txt,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                place['ciudad'] ?? 'Explorar lugar',
                style: TextStyle(color: subTxt, fontSize: 13),
              ),
              onTap: () {
                final String id = place['id_lugar'].toString();
                Navigator.pop(context);
                context.push('/lugar/$id');
              },
            );
          },
        );
      },
    );
  }
}