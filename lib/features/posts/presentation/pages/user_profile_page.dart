import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/utils/theme_utils.dart';
import '../../../../core/themes/spotly_colors.dart';
import '../../data/repositories/feed_repository.dart';
import '../../data/datasources/feed_remote_datasource.dart';
import '../../data/models/feed_item_model.dart';
import '../../data/datasources/post_interaction_remote_datasource.dart';
import '../../data/repositories/post_interaction_repository.dart';
import '../../../comments/presentation/pages/comments_page.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  List<FeedItemModel> _posts = [];
  bool _loading = true;
  String _userName = '';
  String _userAvatar = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadUserPosts();
  }

  Future<void> _loadUserInfo() async {
    try {
      final response = await Supabase.instance.client
          .from('perfiles')
          .select('nombre_usuario, foto_perfil_url')
          .eq('id_usuario', widget.userId)
          .single();

      if (mounted) {
        setState(() {
          _userName = response['nombre_usuario'] ?? 'Usuario';
          _userAvatar = response['foto_perfil_url'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error cargando perfil: $e');
    }
  }

  Future<void> _loadUserPosts() async {
    setState(() => _loading = true);
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id ??
          '00000000-0000-0000-0000-000000000000';
      final repo = FeedRepository(
        FeedRemoteDatasource(Supabase.instance.client),
      );
      final posts = await repo.getPostsByUser(widget.userId, currentUserId);
      if (mounted) {
        setState(() {
          _posts = posts;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error cargando posts: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'No se pudieron cargar las publicaciones';
          _loading = false;
        });
      }
    }
  }

  Future<void> _handleLike(FeedItemModel item) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      context.push('/login');
      return;
    }

    final wasLiked = item.isLiked;
    final index = _posts.indexWhere((p) => p.id == item.id);

    setState(() {
      _posts[index].isLiked = !wasLiked;
      _posts[index].likesCount += wasLiked ? -1 : 1;
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
        _posts[index].isLiked = wasLiked;
        _posts[index].likesCount += wasLiked ? 1 : -1;
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
    final index = _posts.indexWhere((p) => p.id == item.id);

    setState(() {
      _posts[index].isSaved = !wasSaved;
    });

    try {
      final repo = PostInteractionRepository(
        PostInteractionRemoteDatasource(Supabase.instance.client),
      );
      await repo.toggleSave(
        post: item,
        userId: user.id,
        wasSaved: wasSaved,
      );
    } catch (e) {
      setState(() {
        _posts[index].isSaved = wasSaved;
      });
    }
  }

  Future<void> _openComments(FeedItemModel item) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsPage(postId: item.id),
    );
    final repo = FeedRepository(
      FeedRemoteDatasource(Supabase.instance.client),
    );
    final updatedCount = await repo.getCommentCount(item.id);
    if (mounted) {
      final index = _posts.indexWhere((p) => p.id == item.id);
      if (index != -1) {
        setState(() {
          _posts[index].comentarioCount = updatedCount;
        });
      }
    }
  }

  void _share(FeedItemModel item) {}

  void _navigateToUserProfile(String userId) {
    if (userId == widget.userId) return;
    context.push('/user/$userId');
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);

    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),
      appBar: AppBar(
        title: Text(
          _userName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: SpotlyColors.text(dark),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: SpotlyColors.text(dark)),
          onPressed: () => context.pop(),
        ),
        backgroundColor: SpotlyColors.bg(dark),
        elevation: 0,
      ),
      body: _loading
          ? Center(
              child:
                  CircularProgressIndicator(color: SpotlyColors.accent(dark)),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: SpotlyColors.text(dark)),
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildProfileHeader(dark),
                    ),
                    if (_posts.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Text(
                            "Este usuario aún no ha publicado nada",
                            style: TextStyle(color: SpotlyColors.subText(dark)),
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _buildPostItem(_posts[index], dark),
                          childCount: _posts.length,
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildProfileHeader(bool dark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage:
                _userAvatar.isNotEmpty ? NetworkImage(_userAvatar) : null,
            child: _userAvatar.isEmpty
                ? Icon(Icons.person,
                    size: 40, color: SpotlyColors.subText(dark))
                : null,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: SpotlyColors.text(dark),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_posts.length} publicaciones',
                style: TextStyle(color: SpotlyColors.subText(dark)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(FeedItemModel item, bool dark) {
    final textColor = SpotlyColors.text(dark);
    final subColor = SpotlyColors.subText(dark);
    final cardColor = SpotlyColors.card(dark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (item.userId != widget.userId) {
              _navigateToUserProfile(item.userId);
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: dark ? Colors.white24 : Colors.grey.shade200,
                  backgroundImage:
                      item.avatar.isNotEmpty ? NetworkImage(item.avatar) : null,
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
        ),
        if (item.descripcion != null && item.descripcion!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Text(
              item.descripcion!,
              style: TextStyle(color: textColor, fontSize: 14),
            ),
          ),
        Image.network(
          item.mediaUrl,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 300,
            color: cardColor,
            child: Icon(LucideIcons.imageOff, color: subColor),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              _iconWithCount(
                icon: LucideIcons.heart,
                dark: dark,
                isActive: item.isLiked,
                activeColor: Colors.red,
                count: item.likesCount,
                onTap: () => _handleLike(item),
              ),
              _iconWithCount(
                icon: LucideIcons.messageCircle,
                dark: dark,
                count: item.comentarioCount,
                isActive: false,
                onTap: () => _openComments(item),
              ),
              IconButton(
                onPressed: () => _share(item),
                icon: Icon(LucideIcons.send, color: subColor),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _handleSave(item),
                icon: Icon(
                  item.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: item.isSaved ? Colors.amber : subColor,
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

  Widget _iconWithCount({
    required IconData icon,
    required bool dark,
    required VoidCallback onTap,
    bool isActive = false,
    Color activeColor = Colors.red,
    int count = 0,
  }) {
    final color = isActive ? activeColor : SpotlyColors.subText(dark);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
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
