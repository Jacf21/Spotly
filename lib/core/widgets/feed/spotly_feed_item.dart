import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../context/auth_context.dart';
import '../../../../features/posts/data/models/feed_item_model.dart';
import '../../../../features/posts/data/repositories/feed_repository.dart';
import '../../../../features/posts/data/datasources/feed_remote_datasource.dart';
import '../../../../features/posts/data/datasources/post_interaction_remote_datasource.dart';
import '../../../../features/posts/data/repositories/post_interaction_repository.dart';
import '../../../../features/comments/presentation/pages/comments_page.dart';

class SpotlyFeedItem extends StatefulWidget {
  final FeedItemModel item;
  final bool dark;
  final bool showLugarButton;

  const SpotlyFeedItem({
    super.key,
    required this.item,
    required this.dark,
    this.showLugarButton = true,
  });

  @override
  State<SpotlyFeedItem> createState() => _SpotlyFeedItemState();
}

class _SpotlyFeedItemState extends State<SpotlyFeedItem> {
  late FeedItemModel item;

  @override
  void initState() {
    super.initState();
    item = widget.item;
  }

  bool get dark => widget.dark;

  Future<void> _handleLike() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) { context.push('/login'); return; }

    final wasLiked = item.isLiked;
    setState(() {
      item.isLiked = !wasLiked;
      item.likesCount += wasLiked ? -1 : 1;
    });

    try {
      await PostInteractionRepository(
        PostInteractionRemoteDatasource(Supabase.instance.client),
      ).toggleLike(post: item, userId: user.id, wasLiked: wasLiked);
    } catch (_) {
      setState(() {
        item.isLiked = wasLiked;
        item.likesCount += wasLiked ? 1 : -1;
      });
    }
  }

  Future<void> _handleSave(bool isGuest) async {
    if (isGuest) { context.push('/login'); return; }
    final user = Supabase.instance.client.auth.currentUser!;
    final wasSaved = item.isSaved;
    setState(() => item.isSaved = !wasSaved);

    try {
      await PostInteractionRepository(
        PostInteractionRemoteDatasource(Supabase.instance.client),
      ).toggleSave(post: item, userId: user.id, wasSaved: wasSaved);
    } catch (_) {
      setState(() => item.isSaved = wasSaved);
    }
  }

  Future<void> _handleComment() async {
    if (!item.comentarioActivado) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("El autor desactivó los comentarios"),
        backgroundColor: dark ? Colors.white24 : Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsPage(postId: item.id),
    );

    if (!mounted) return;
    final count = await FeedRepository(
      FeedRemoteDatasource(Supabase.instance.client),
    ).getCommentCount(item.id);
    if (!mounted) return;
    setState(() => item.comentarioCount = count);
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = !context.watch<AuthProvider>().isLoggedIn;
    final textColor = dark ? Colors.white : Colors.black;
    final subColor = dark ? Colors.white70 : Colors.black54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: dark ? Colors.white24 : Colors.grey.shade200,
              backgroundImage: item.avatar.isNotEmpty
                  ? NetworkImage(item.avatar) : null,
              child: item.avatar.isEmpty
                  ? Icon(LucideIcons.user, color: subColor, size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(item.usuario,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 14)),
          ]),
        ),

        if (item.descripcion != null && item.descripcion!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Text(item.descripcion!,
                style: TextStyle(color: textColor, fontSize: 14)),
          ),

        // Imagen
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

        // Acciones
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(children: [
            _iconWithCount(
              icon: LucideIcons.heart,
              isActive: item.isLiked,
              activeColor: Colors.red,
              count: item.likesCount,
              onTap: _handleLike,
            ),
            _iconWithCount(
              icon: LucideIcons.messageCircle,
              count: item.comentarioCount,
              onTap: _handleComment,
            ),
            IconButton(
              onPressed: () => Share.share(
                  "Mira esta publicación en Spotly 📍\n${item.mediaUrl}"),
              icon: Icon(LucideIcons.send, color: subColor),
            ),
            if (widget.showLugarButton && item.lugar.isNotEmpty)
              IconButton(
                onPressed: () => context.push('/lugar/${item.lugarId}'),
                icon: Icon(LucideIcons.mapPin, color: subColor),
                tooltip: item.lugar,
              ),
            const Spacer(),
            IconButton(
              onPressed: () => _handleSave(isGuest),
              icon: Icon(
                LucideIcons.bookmark,
                color: item.isSaved ? Colors.amber : subColor,
              ),
            ),
          ]),
        ),

        const Divider(height: 1),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _iconWithCount({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
    Color activeColor = Colors.red,
    int count = 0,
  }) {
    final color = isActive
        ? activeColor
        : (dark ? Colors.white70 : Colors.black54);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 22),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Text(count.toString(),
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ]),
      ),
    );
  }
}