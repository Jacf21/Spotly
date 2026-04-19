import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/context/auth_context.dart';
import '../../../../core/utils/theme_utils.dart';
import '../../../../core/themes/spotly_colors.dart';
import '../../../../core/themes/spotly_config.dart';

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
    final userId =
        Supabase.instance.client.auth.currentUser?.id ??
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

    final userId =
        Supabase.instance.client.auth.currentUser?.id ??
            '00000000-0000-0000-0000-000000000000';

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

  //context mode dark and login
  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);
    final isGuest = !context.watch<AuthProvider>().isLoggedIn;

    return AnimatedContainer(
      duration: SpotlyConfig.animShort,
      color: SpotlyColors.bg(dark),

      child: feed.isEmpty
          ? _buildEmptyState(dark)
          : _buildFeedList(dark, isGuest),
    );
  }

  Widget _buildEmptyState(bool dark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.image,
            size: 64,
            color: dark ? Colors.white38 : Colors.black38,
          ),
          const SizedBox(height: 16),
          Text(
            "No hay publicaciones aún 📭",
            style: TextStyle(
              color: dark ? Colors.white70 : Colors.black54,
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

        final item = feed[index];
        return _buildFeedItem(item, dark, isGuest);
      },
    );
  }

  Widget _buildFeedItem(
      FeedItemModel item, bool dark, bool isGuest) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 👤 USER
        ListTile(
          leading: CircleAvatar(
            backgroundColor:
                dark ? Colors.white24 : Colors.grey.shade200,
            child: const Icon(LucideIcons.user),
          ),
          title: Text(
            item.usuario,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: dark ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Text(
            item.lugar,
            style: TextStyle(
              color: dark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),

        /// 🖼️ MEDIA
        Image.network(
          item.mediaUrl,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 300,
            color: dark ? Colors.white12 : Colors.black12,
            child: Icon(
              LucideIcons.imageOff,
              color: dark ? Colors.white54 : Colors.black54,
            ),
          ),
        ),

        /// ❤️ ACCIONES
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              _icon(LucideIcons.heart, dark, isGuest),
              _icon(LucideIcons.messageCircle, dark, isGuest),
              _icon(LucideIcons.send, dark, isGuest),
              const Spacer(),
              _icon(LucideIcons.bookmark, dark, isGuest),
            ],
          ),
        ),

        /// 📝 TEXTO
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "${item.usuario} ${item.descripcion ?? ''}",
            style: TextStyle(
              color: dark ? Colors.white : Colors.black,
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _icon(IconData icon, bool dark, bool isGuest) {
    return IconButton(
      onPressed: () {
        if (isGuest) {
          // 🔒 Invitado → login
          Navigator.of(context).pushNamed('/login');
          return;
        }
      },
      icon: Icon(
        icon,
        color: dark ? Colors.white70 : Colors.black54,
      ),
    );
  }
}