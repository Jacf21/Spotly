import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/features/posts/data/datasources/feed_remote_datasource.dart';
import 'package:spotly/features/posts/data/models/feed_item_model.dart';
import 'package:spotly/features/posts/data/repositories/feed_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Esta clase es la que se muestra en la pestaña de "Publicaciones" dentro del buscador
class SearchPostsTab extends StatelessWidget {
  final String query;
  final bool dark;

  const SearchPostsTab({
    super.key, 
    required this.query, 
    required this.dark
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = SpotlyColors.bg(dark);
    final subTextColor = SpotlyColors.subText(dark);

    return Container(
      color: backgroundColor,
      child: _buildBody(subTextColor),
    );
  }

  Widget _buildBody(Color subTextColor) {
    if (query.isEmpty) {
      return Center(
        child: Text(
          "Busca publicaciones increíbles",
          style: TextStyle(color: subTextColor),
        ),
      );
    }

    return FutureBuilder<List<FeedItemModel>>(
      future: _fetchSearchPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: SpotlyColors.accent(dark)),
          );
        }

        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return _buildInfoState("No hay publicaciones para \"$query\"", subTextColor);
        }

        return GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final item = posts[index];
            return GestureDetector(
              onTap: () {
                final String id = item.id.toString();
                // Cerramos el buscador
                Navigator.pop(context);
                // Navegamos al feed con el parámetro exacto
                context.go('/feed?postId=$id');
              },
              child: Hero(
                tag: 'post_${item.id}',
                child: Image.network(
                  item.mediaUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: dark ? Colors.white12 : Colors.black12,
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    color: dark ? Colors.white12 : Colors.black12,
                    child: Icon(
                      LucideIcons.imageOff, 
                      size: 20, 
                      color: subTextColor
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Método de búsqueda (usando lógica de repositorio)
  Future<List<FeedItemModel>> _fetchSearchPosts() async {
    final repo = FeedRepository(
      FeedRemoteDatasource(Supabase.instance.client),
    );
    
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 
                   '00000000-0000-0000-0000-000000000000';
    
    return await repo.getFeed(
      userId: userId,
      lat: -16.5,
      lng: -68.15,
    ).then((list) => list.where((element) => 
      element.descripcion?.toLowerCase().contains(query.toLowerCase()) ?? false
    ).toList());
  }

  Widget _buildInfoState(String text, Color textColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          text, 
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}