import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/themes/spotly_colors.dart';
import '../../../../core/themes/spotly_config.dart';
import '../../../../core/widgets/layout/spotly_topbar.dart';
import '../../../../core/widgets/layout/spotly_nav_item.dart';
import '../../../../core/widgets/layout/spotly_add_button.dart';
import '../../../posts/data/models/feed_item_model.dart';
import '../../../posts/data/repositories/feed_repository.dart';
import '../../../posts/data/datasources/feed_remote_datasource.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final ScrollController _scrollController = ScrollController();

  bool isLoading = false;
  bool hasMore = true;
  List<FeedItemModel> feed = [];

  @override
  void initState() {
    super.initState();
    loadFeed();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        loadMore();
      }
    });
  }

  Future<void> loadFeed() async {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '00000000-0000-0000-0000-000000000000';

    final repo = FeedRepository(
      FeedRemoteDatasource(Supabase.instance.client),
    );

    final data = await repo.getFeed(
      userId: userId,
      lat: -16.5,
      lng: -68.15,
    );

    setState(() => feed = data);
  }

  Future<void> loadMore() async {
    if (isLoading || !hasMore || feed.isEmpty) return;

    isLoading = true;

    final userId = Supabase.instance.client.auth.currentUser?.id ?? '00000000-0000-0000-0000-000000000000';
    final lastItem = feed.last;

    final repo = FeedRepository(
      FeedRemoteDatasource(Supabase.instance.client),
    );

    final newData = await repo.getFeed(
      userId: userId,
      lat: -16.5,
      lng: -68.15,
      lastCreatedAt: lastItem.createdAt.toIso8601String(),
    );

    if (newData.isEmpty) {
      hasMore = false;
    } else {
      feed.addAll(newData);
    }

    isLoading = false;
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: SpotlyConfig.animShort,
      color: SpotlyColors.bg(isDarkMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            SpotlyTopBar(
              dark: isDarkMode,
              isAdmin: false,
              onTheme: () {
                // TODO: Implementar cambio de tema cuando esté disponible
                // Por ahora solo mostramos un mensaje
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cambio de tema no implementado')),
                );
              },
              onSearch: () {
                // TODO: Implementar búsqueda
              },
            ),
            Expanded(
              child: feed.isEmpty
                  ? _buildEmptyState(isDarkMode)
                  : _buildFeedList(location, isDarkMode),
            ),
            _buildBottomNav(context, location, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.image,
            size: 64,
            color: isDarkMode ? Colors.white38 : Colors.black38,
          ),
          const SizedBox(height: 16),
          Text(
            "No hay publicaciones aún 📭",
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: loadFeed,
            child: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedList(String location, bool isDarkMode) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: feed.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == feed.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final item = feed[index];
        return _buildFeedItem(item, isDarkMode);
      },
    );
  }

  Widget _buildFeedItem(FeedItemModel item, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 👤 USER INFO
        ListTile(
          leading: CircleAvatar(
            backgroundColor: isDarkMode ? Colors.white24 : Colors.grey.shade200,
            child: const Icon(LucideIcons.user),
          ),
          title: Text(
            item.usuario,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(
                LucideIcons.mapPin,
                size: 14,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(width: 4),
              Text(
                item.lugar,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
          trailing: Icon(
            LucideIcons.moreVertical,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),

        // 🖼️ MEDIA
        // 🖼️ MEDIA
        if (item.tipo == 'video')
          Container(
            height: 250,
            color: isDarkMode ? Colors.white12 : Colors.black12,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.video,
                    size: 48,
                    color: isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "VIDEO",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Image.network(
            item.mediaUrl,
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            headers: const {'Access-Control-Allow-Origin': '*'},
            errorBuilder: (context, error, stackTrace) {
              print('❌ Error imagen: $error');
              print('🔗 URL: ${item.mediaUrl}');
              return Container(
                height: 300,
                color: isDarkMode ? Colors.white12 : Colors.black12,
                child: Center(
                  child: Icon(
                    LucideIcons.imageOff,
                    color: isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                ),
              );
            },
          ),
          
        // ❤️ ACTIONS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Icon(
                LucideIcons.heart,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(width: 12),
              Icon(
                LucideIcons.messageCircle,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(width: 12),
              Icon(
                LucideIcons.send,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              const Spacer(),
              Icon(
                LucideIcons.bookmark,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ],
          ),
        ),

        // 📝 DESCRIPCIÓN
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              children: [
                TextSpan(
                  text: "${item.usuario} ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: item.descripcion ?? ''),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context, String location, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: SpotlyColors.nav(isDarkMode),
        border: Border(
          top: BorderSide(
            color: isDarkMode
                ? Colors.white10
                : Colors.black.withOpacity(0.05),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SpotlyNavItem(
              icon: LucideIcons.home,
              label: 'Inicio',
              active: _isActive(location, '/feed') || _isActive(location, '/user'),
              dark: isDarkMode,
              onTap: () {
                context.go('/feed');
              },
            ),

            SpotlyNavItem(
              icon: LucideIcons.map,
              label: 'Mapa',
              active: _isActive(location, '/map'),
              dark: isDarkMode,
              onTap: () {
                context.go('/map');
              },
            ),

            SpotlyAddButton(
              dark: isDarkMode,
              onTap: () {
                // TODO: Implementar creación de publicación
              },
            ),

            SpotlyNavItem(
              icon: LucideIcons.bell,
              label: 'Alertas',
              active: _isActive(location, '/alerts'),
              dark: isDarkMode,
              onTap: () {
                context.go('/alerts');
              },
            ),

            SpotlyNavItem(
              icon: LucideIcons.user,
              label: 'Perfil',
              active: _isActive(location, '/profile'),
              dark: isDarkMode,
              onTap: () {
                context.go('/profile');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 Detecta tab activo según la ruta
  bool _isActive(String location, String route) {
    return location.startsWith(route);
  }
}