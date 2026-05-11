import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/themes/spotly_colors.dart';
import '../../../../core/utils/theme_utils.dart';

import '../../data/datasources/lugar_remote_datasource.dart';
import 'package:spotly/features/destinations/data/models/favorite_place_model.dart';
import '../../data/repositories/lugar_repository.dart';

class FavoritesPlacesPage extends StatefulWidget {
  const FavoritesPlacesPage({super.key});

  @override
  State<FavoritesPlacesPage> createState() =>
      _FavoritesPlacesPageState();
}

class _FavoritesPlacesPageState
    extends State<FavoritesPlacesPage> {
  late final LugarRepository _repo;

  bool _loading = true;

  List<FavoritePlaceModel> _favorites = [];

  @override
  void initState() {
    super.initState();

    _repo = LugarRepository(
      LugarRemoteDatasource(
        Supabase.instance.client,
      ),
    );

    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    try {
      final data =
          await _repo.getFavoritePlaces(user.id);

      if (mounted) {
        setState(() {
          _favorites = data;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("ERROR FAVORITES: $e");

      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);

    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),

      appBar: AppBar(
        title: Text(
          'Favoritos',
          style: TextStyle(
            color: SpotlyColors.text(dark),
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: SpotlyColors.bg(dark),

        elevation: 0,

        iconTheme: IconThemeData(
          color: SpotlyColors.text(dark),
        ),
      ),

      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: SpotlyColors.accent(dark),
              ),
            )
          : _favorites.isEmpty
              ? _buildEmpty(dark)
              : _buildGrid(dark),
    );
  }

  Widget _buildEmpty(bool dark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.heart,
              size: 75,
              color: SpotlyColors.subText(dark),
            ),

            const SizedBox(height: 20),

            Text(
              "Aún no tienes favoritos",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SpotlyColors.text(dark),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Explora lugares increíbles y guárdalos para verlos después 💜",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SpotlyColors.subText(dark),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(bool dark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),

      itemCount: _favorites.length,

      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,

        crossAxisSpacing: 14,
        mainAxisSpacing: 14,

        childAspectRatio: 0.76,
      ),

      itemBuilder: (_, index) {
        final place = _favorites[index];

        return GestureDetector(
          onTap: () {
            context.push('/lugar/${place.id}');
          },

          child: Hero(
            tag: 'favorite_${place.id}',

            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),

              child: Stack(
                fit: StackFit.expand,

                children: [
                  Image.network(
                    place.fotoPortadaUrl ?? '',
                    fit: BoxFit.cover,

                    errorBuilder: (_, __, ___) => Container(
                      color: SpotlyColors.card(dark),

                      child: Icon(
                        LucideIcons.imageOff,
                        color: SpotlyColors.subText(dark),
                      ),
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,

                        colors: [
                          Colors.black.withOpacity(0.82),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: 12,
                    right: 12,

                    child: Container(
                      padding: const EdgeInsets.all(9),

                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        LucideIcons.heart,
                        color: Colors.pinkAccent,
                        size: 18,
                      ),
                    ),
                  ),

                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                place.nombre,

                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            if (place.esVerificado)
                              const Padding(
                                padding:
                                    EdgeInsets.only(left: 5),

                                child: Icon(
                                  Icons.verified,
                                  color: Colors.cyanAccent,
                                  size: 17,
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Icon(
                              LucideIcons.mapPin,
                              size: 13,
                              color: Colors.white70,
                            ),

                            const SizedBox(width: 4),

                            Expanded(
                              child: Text(
                                place.departamento,

                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,

                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (place.categoria.isNotEmpty) ...[
                          const SizedBox(height: 4),

                          Text(
                            place.categoria,

                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}