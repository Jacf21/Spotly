import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/context/auth_context.dart';
import '../../../../core/utils/theme_utils.dart';
import '../../../../core/themes/spotly_colors.dart';
import '../../../../core/themes/spotly_config.dart';

import '../../../posts/data/models/feed_item_model.dart';
import '../../../posts/data/repositories/feed_repository.dart';
import '../../../posts/data/datasources/feed_remote_datasource.dart';
import '../../../posts/data/datasources/post_interaction_remote_datasource.dart';
import '../../../posts/data/repositories/post_interaction_repository.dart';
import '../../../comments/presentation/pages/comments_page.dart';

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
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = Supabase.instance.client.auth.currentUser?.id;
    loadFeed();

    // ← escucha cambios de sesión
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;

      final newUserId = data.session?.user.id;

      // Si cambió el usuario (login con otra cuenta o logout+login)
      if (newUserId != _currentUserId) {
        _currentUserId = newUserId;
        _resetAndReload();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        loadMore();
      }
    });
  }

  void _resetAndReload() {
    setState(() {
      feed = [];
      hasMore = true;
      isLoading = false;
    });
    loadFeed();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _share(FeedItemModel item) {
    Share.share("Mira esta publicación en Spotly 📍\n${item.mediaUrl}");
  }

  Future<void> _handleLike(FeedItemModel item) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      context.push('/login');
      return;
    }

    final wasLiked = item.isLiked;

    setState(() {
      item.isLiked = !wasLiked;
      item.likesCount += wasLiked ? -1 : 1;
    });

    try {
      final repo = PostInteractionRepository(
        PostInteractionRemoteDatasource(Supabase.instance.client),
      );
      await repo.toggleLike(
        post: item,
        userId: user.id,
        wasLiked: wasLiked,
      );
    } catch (e) {
      setState(() {
        item.isLiked = wasLiked;
        item.likesCount += wasLiked ? 1 : -1;
      });
    }
  }

  Future<void> _handleSave(FeedItemModel item) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      context.push('/login');
      return;
    }

    final wasSaved = item.isSaved;

    setState(() {
      item.isSaved = !wasSaved;
    });

    try {
      final repo = PostInteractionRepository(
        PostInteractionRemoteDatasource(Supabase.instance.client),
      );
      await repo.toggleSave(
        post: item,
        userId: user.id,
        wasSaved: wasSaved, // ← estado correcto
      );
    } catch (e) {
      setState(() {
        item.isSaved = wasSaved;
      });
    }
  }

  Future<void> loadFeed() async {
    final userId = Supabase.instance.client.auth.currentUser?.id ??
        '00000000-0000-0000-0000-000000000000';

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

    final userId = Supabase.instance.client.auth.currentUser?.id ??
        '00000000-0000-0000-0000-000000000000';

    final repo = FeedRepository(
      FeedRemoteDatasource(Supabase.instance.client),
    );

    final newData = await repo.getFeed(
      userId: userId,
      lat: -16.5,
      lng: -68.15,
      lastCreatedAt: feed.last.createdAt.toIso8601String(),
    );

    setState(() {
      if (newData.isEmpty) {
        hasMore = false;
      } else {
        feed.addAll(newData);
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);
    final isGuest = !context.watch<AuthProvider>().isLoggedIn;

    return AnimatedContainer(
      duration: SpotlyConfig.animShort,
      color: SpotlyColors.bg(dark),
      child: feed.isEmpty ? _buildEmptyState(dark) : _buildFeedList(dark, isGuest),
    );
  }

  Widget _buildEmptyState(bool dark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.image, size: 64,
              color: dark ? Colors.white38 : Colors.black38),
          const SizedBox(height: 16),
          Text("No hay publicaciones aún 📭",
              style: TextStyle(
                  color: dark ? Colors.white70 : Colors.black54,
                  fontSize: 16)),
          const SizedBox(height: 8),
          TextButton(onPressed: loadFeed, child: const Text("Reintentar")),
        ],
      ),
    );
  }

  Widget _buildFeedList(bool dark, bool isGuest) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: feed.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == feed.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildFeedItem(feed[index], dark, isGuest);
      },
    );
  }

  Widget _buildFeedItem(FeedItemModel item, bool dark, bool isGuest) {
    final textColor = dark ? Colors.white : Colors.black;
    final subColor = dark ? Colors.white70 : Colors.black54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header: avatar + usuario + lugar ──────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: dark ? Colors.white24 : Colors.grey.shade200,
                backgroundImage: item.avatar.isNotEmpty
                    ? NetworkImage(item.avatar)
                    : null,
                child: item.avatar.isEmpty
                    ? Icon(LucideIcons.user, color: subColor, size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                item.usuario,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // ── Descripción (justo debajo de la imagen) ───────────────────
        if (item.descripcion != null && item.descripcion!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: textColor, fontSize: 14),
                children: [
                  TextSpan(text: item.descripcion),
                ],
              ),
            ),
          ),

        // ── Imagen ────────────────────────────────────────────────────
        Image.network(
          item.mediaUrl,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 300,
            color: dark ? Colors.white12 : Colors.black12,
            child: Icon(LucideIcons.imageOff, color: subColor),
          ),
        ),

        // ── Acciones con contadores inline ────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              // Like
              _iconWithCount(
                icon: LucideIcons.heart,
                dark: dark,
                isGuest: isGuest,
                isActive: item.isLiked,
                activeColor: Colors.red,
                count: item.likesCount,
                onTap: () => _handleLike(item),
              ),

              // Comentarios
              _iconWithCount(
                icon: LucideIcons.messageCircle,
                dark: dark,
                isGuest: isGuest,
                count: item.comentarioCount,
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => CommentsPage(postId: item.id),
                ),
              ),

              // Compartir (sin contador)
              IconButton(
                onPressed: () => _share(item),
                icon: Icon(LucideIcons.send,
                    color: dark ? Colors.white70 : Colors.black54),
              ),

              const Spacer(),

              // Guardar (sin contador)
              IconButton(
                onPressed: () {
                  if (isGuest) {
                    context.push('/login');
                    return;
                  }
                  _handleSave(item);
                },
                icon: Icon(
                  LucideIcons.bookmark,
                  color: item.isSaved
                      ? Colors.amber
                      : (dark ? Colors.white70 : Colors.black54),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Icono con contador a su derecha
  Widget _iconWithCount({
    required IconData icon,
    required bool dark,
    required bool isGuest,
    required VoidCallback onTap,
    bool isActive = false,
    Color activeColor = Colors.red,
    int count = 0,
  }) {
    final color = isActive ? activeColor : (dark ? Colors.white70 : Colors.black54);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap, // ← directo, sin check de isGuest aquí
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}