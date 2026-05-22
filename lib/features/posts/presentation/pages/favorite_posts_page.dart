import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/themes/spotly_colors.dart';
import '../../../../core/utils/theme_utils.dart';

import '../../../../core/widgets/feed/spotly_feed_item.dart';
import '../../../../core/widgets/feed/spotly_image_viewer.dart';

import '../../data/models/feed_item_model.dart';

import '../../data/datasources/favorite_post_remote_datasource.dart';
import '../../data/repositories/favorite_post_repository.dart';

class FavoritePostsPage extends StatefulWidget {
  const FavoritePostsPage({super.key});

  @override
  State<FavoritePostsPage> createState() =>
      _FavoritePostsPageState();
}

class _FavoritePostsPageState
    extends State<FavoritePostsPage> {

  late final FavoritePostRepository _repo;

  bool isLoading = true;

  bool _gridView = true;

  List<FeedItemModel> posts = [];

  @override
  void initState() {
    super.initState();

    _repo = FavoritePostRepository(
      FavoritePostRemoteDatasource(
        Supabase.instance.client,
      ),
    );

    _loadFavorites();
  }

  Future<void> _loadFavorites() async {

    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {

      final data =
          await _repo.getFavorites(user.id);

      if (mounted) {
        setState(() {
          posts = data;
          isLoading = false;
        });
      }

      debugPrint(
        "POSTS FAVORITOS CARGADOS: ${data.length}",
      );

    } catch (e) {

      debugPrint(
        "ERROR FAVORITOS POSTS: $e",
      );

      if (mounted) {
        setState(() {
          isLoading = false;
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
          'Publicaciones guardadas',
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

        actions: [

          IconButton(
            onPressed: () {

              setState(() {
                _gridView = !_gridView;
              });

            },

            icon: Icon(
              _gridView
                  ? LucideIcons.list
                  : LucideIcons.layoutGrid,
              color: SpotlyColors.text(dark),
            ),
          ),
        ],
      ),

      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: SpotlyColors.accent(dark),
              ),
            )
          : posts.isEmpty
              ? _buildEmpty(dark)
              : _gridView
                  ? _buildGrid(dark)
                  : _buildFeed(dark),
    );
  }

  Widget _buildEmpty(bool dark) {

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              LucideIcons.bookmark,
              size: 75,
              color: SpotlyColors.subText(dark),
            ),

            const SizedBox(height: 20),

            Text(
              "Aún no tienes publicaciones guardadas",

              textAlign: TextAlign.center,

              style: TextStyle(
                color: SpotlyColors.text(dark),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Guarda publicaciones increíbles para verlas después 🔖",

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

      itemCount: posts.length,

      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(

        crossAxisCount: 2,

        crossAxisSpacing: 14,
        mainAxisSpacing: 14,

        childAspectRatio: 0.76,
      ),

      itemBuilder: (_, index) {

        final post = posts[index];

        return GestureDetector(

          onTap: () {

            SpotlyImageViewer.show(

              context,

              initialIndex: index,

              items: posts.map((p) {

                return SpotlyImageItem(
                  imageUrl: p.mediaUrl,
                  descripcion: p.descripcion,
                  usuario: p.usuario,
                );

              }).toList(),
            );
          },

          child: Hero(

            tag: 'favorite_post_${post.id}',

            child: ClipRRect(

              borderRadius:
                  BorderRadius.circular(22),

              child: Stack(

                fit: StackFit.expand,

                children: [

                  Image.network(

                    post.mediaUrl,

                    fit: BoxFit.cover,

                    errorBuilder:
                        (_, __, ___) => Container(

                      color:
                          SpotlyColors.card(dark),

                      child: Icon(
                        LucideIcons.imageOff,
                        color:
                            SpotlyColors.subText(dark),
                      ),
                    ),
                  ),

                  Container(

                    decoration: BoxDecoration(

                      gradient: LinearGradient(

                        begin:
                            Alignment.bottomCenter,

                        end: Alignment.center,

                        colors: [
                          Colors.black
                              .withOpacity(0.82),

                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  Positioned(

                    top: 12,
                    right: 12,

                    child: Container(

                      padding:
                          const EdgeInsets.all(9),

                      decoration: BoxDecoration(

                        color: Colors.black
                            .withOpacity(0.35),

                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        LucideIcons.bookmark,
                        color: Colors.amber,
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

                        Text(

                          post.usuario,

                          maxLines: 1,

                          overflow:
                              TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 5),

                        if (post.descripcion != null &&
                            post.descripcion!.isNotEmpty)

                          Text(

                            post.descripcion!,

                            maxLines: 2,

                            overflow:
                                TextOverflow.ellipsis,

                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
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

  Widget _buildFeed(bool dark) {

    return ListView.builder(

      physics:
          const BouncingScrollPhysics(),

      itemCount: posts.length,

      itemBuilder: (_, index) {

        return SpotlyFeedItem(

          item: posts[index],

          dark: dark,

          showLugarButton: true,
        );
      },
    );
  }
}