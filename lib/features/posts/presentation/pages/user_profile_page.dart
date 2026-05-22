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
import 'package:spotly/features/profile/data/datasources/followers_remote_datasource.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final bool showBackButton;

  const UserProfilePage({
    super.key,
    required this.userId,
    this.showBackButton = true,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  List<FeedItemModel> _posts = [];
  bool _loading = true;
  String _userName = '';
  String _userAvatar = '';
  String _errorMessage = '';
  bool _isFollowing = false;

  int _followersCount = 0;
  int _followingCount = 0;

  // Motivos de reporte
  static const List<String> _motivosReporte = [
    'Spam',
    'Contenido inapropiado',
    'Cuenta falsa',
    'Otro motivo',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadUserPosts();
    _loadFollowData();
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

  Future<void> _loadFollowData() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    final repo = FollowersRemoteDatasource(Supabase.instance.client);
    final following = await repo.isFollowing(
      seguidorId: currentUser.id,
      seguidoId: widget.userId,
    );
    final followers = await repo.getFollowersCount(widget.userId);
    final followingCount = await repo.getFollowingCount(widget.userId);

    if (mounted) {
      setState(() {
        _isFollowing = following;
        _followersCount = followers;
        _followingCount = followingCount;
      });
    }
  }

  Future<void> _toggleFollow() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) { context.push('/login'); return; }

    final repo = FollowersRemoteDatasource(Supabase.instance.client);
    try {
      if (_isFollowing) {
        await repo.unfollowUser(
          seguidorId: currentUser.id,
          seguidoId: widget.userId,
        );
        setState(() { _isFollowing = false; _followersCount--; });
      } else {
        await repo.followUser(
          seguidorId: currentUser.id,
          seguidoId: widget.userId,
        );
        await Supabase.instance.client
            .from('notificaciones_follow')
            .insert({
              'id_usuario': widget.userId,
              'id_usuario_actor': currentUser.id,
            });
        setState(() { _isFollowing = true; _followersCount++; });
      }
    } catch (e) {
      debugPrint('Error follow: $e');
    }
  }

  Future<void> _loadUserPosts() async {
    setState(() => _loading = true);
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id ??
          '00000000-0000-0000-0000-000000000000';
      final repo = FeedRepository(FeedRemoteDatasource(Supabase.instance.client));
      final posts = await repo.getPostsByUser(widget.userId, currentUserId);
      if (mounted) setState(() { _posts = posts; _loading = false; });
    } catch (e) {
      debugPrint('Error cargando posts: $e');
      if (mounted) setState(() { _errorMessage = 'No se pudieron cargar las publicaciones'; _loading = false; });
    }
  }

  Future<void> _handleLike(FeedItemModel item) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) { if (mounted) context.push('/login'); return; }
    final wasLiked = item.isLiked;
    final index = _posts.indexWhere((p) => p.id == item.id);
    if (index == -1) return;
    setState(() { _posts[index].isLiked = !wasLiked; _posts[index].likesCount += wasLiked ? -1 : 1; });
    try {
      final repo = PostInteractionRepository(PostInteractionRemoteDatasource(Supabase.instance.client));
      await repo.toggleLike(post: item, userId: user.id, wasLiked: wasLiked);
    } catch (e) {
      if (mounted) setState(() { _posts[index].isLiked = wasLiked; _posts[index].likesCount += wasLiked ? 1 : -1; });
    }
  }

  Future<void> _handleSave(FeedItemModel item) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) { if (mounted) context.push('/login'); return; }
    final wasSaved = item.isSaved;
    final index = _posts.indexWhere((p) => p.id == item.id);
    if (index == -1) return;
    setState(() => _posts[index].isSaved = !wasSaved);
    try {
      final repo = PostInteractionRepository(PostInteractionRemoteDatasource(Supabase.instance.client));
      await repo.toggleSave(post: item, userId: user.id, wasSaved: wasSaved);
    } catch (e) {
      if (mounted) setState(() => _posts[index].isSaved = wasSaved);
    }
  }

  Future<void> _openComments(FeedItemModel item) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsPage(postId: item.id),
    );
    if (!mounted) return;
    final repo = FeedRepository(FeedRemoteDatasource(Supabase.instance.client));
    final updatedCount = await repo.getCommentCount(item.id);
    if (mounted) {
      final index = _posts.indexWhere((p) => p.id == item.id);
      if (index != -1) setState(() => _posts[index].comentarioCount = updatedCount);
    }
  }

  void _navigateToUserProfile(String userId) {
    if (userId == widget.userId) return;
    if (mounted) context.go('/user/$userId');
  }

  // ── Menú hamburguesa ──────────────────────────────────────────────────────

  void _mostrarMenu(bool dark) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isOwnProfile = currentUserId == widget.userId;

    showModalBottomSheet(
      context: context,
      backgroundColor: SpotlyColors.card(dark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: SpotlyColors.subText(dark).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          // Solo muestra "Reportar" si no es el propio perfil
          if (!isOwnProfile) ...[
            ListTile(
              leading: const Icon(LucideIcons.flag,
                  color: Colors.redAccent, size: 20),
              title: const Text('Reportar cuenta',
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _mostrarReporte(dark);
              },
            ),
            Divider(
                color: SpotlyColors.subText(dark).withOpacity(0.15),
                height: 1),
          ],
          ListTile(
            leading: Icon(LucideIcons.x,
                color: SpotlyColors.subText(dark), size: 20),
            title: Text('Cerrar',
                style: TextStyle(color: SpotlyColors.subText(dark))),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Modal de reporte ──────────────────────────────────────────────────────

  void _mostrarReporte(bool dark) {
    String? motivoSeleccionado;
    final otroCtrl = TextEditingController();
    bool enviando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SpotlyColors.bg(dark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 16,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: SpotlyColors.subText(dark).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(children: [
                  const Icon(LucideIcons.flag,
                      color: Colors.redAccent, size: 20),
                  const SizedBox(width: 10),
                  Text('Reportar cuenta',
                      style: TextStyle(
                          color: SpotlyColors.text(dark),
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 6),
                Text(
                  'Selecciona el motivo del reporte. Tu identidad es anónima.',
                  style: TextStyle(
                      color: SpotlyColors.subText(dark), fontSize: 12),
                ),
                const SizedBox(height: 16),

                // Opciones de motivo
                ..._motivosReporte.map((motivo) => GestureDetector(
                      onTap: () =>
                          setModalState(() => motivoSeleccionado = motivo),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: motivoSeleccionado == motivo
                              ? Colors.redAccent.withOpacity(0.1)
                              : SpotlyColors.card(dark),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: motivoSeleccionado == motivo
                                ? Colors.redAccent.withOpacity(0.5)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(children: [
                          Expanded(
                            child: Text(motivo,
                                style: TextStyle(
                                    color: motivoSeleccionado == motivo
                                        ? Colors.redAccent
                                        : SpotlyColors.text(dark),
                                    fontSize: 14,
                                    fontWeight: motivoSeleccionado == motivo
                                        ? FontWeight.w600
                                        : FontWeight.normal)),
                          ),
                          if (motivoSeleccionado == motivo)
                            const Icon(Icons.check_circle,
                                color: Colors.redAccent, size: 18),
                        ]),
                      ),
                    )),

                // Campo de texto si eligió "Otro motivo"
                if (motivoSeleccionado == 'Otro motivo') ...[
                  const SizedBox(height: 4),
                  TextField(
                    controller: otroCtrl,
                    maxLines: 3,
                    style: TextStyle(
                        color: SpotlyColors.text(dark), fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: SpotlyColors.card(dark),
                      hintText: 'Describe el motivo...',
                      hintStyle: TextStyle(
                          color: SpotlyColors.subText(dark)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Botón enviar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: motivoSeleccionado == null || enviando
                        ? null
                        : () async {
                            // Si es "Otro motivo" y el campo está vacío, no envía
                            if (motivoSeleccionado == 'Otro motivo' &&
                                otroCtrl.text.trim().isEmpty) {
                              return;
                            }
                            setModalState(() => enviando = true);
                            await _enviarReporte(
                              motivo: motivoSeleccionado!,
                              descripcion: motivoSeleccionado == 'Otro motivo'
                                  ? otroCtrl.text.trim()
                                  : null,
                            );
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      disabledBackgroundColor:
                          Colors.redAccent.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: enviando
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Enviar reporte',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _enviarReporte({
    required String motivo,
    String? descripcion,
  }) async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    try {
      await Supabase.instance.client.from('reportes_cuenta').insert({
        'id_usuario_reportado': widget.userId,
        'id_usuario_reportador': currentUser.id,
        'motivo': motivo,
        'descripcion': descripcion,
        'pendiente': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte enviado. Gracias por ayudarnos.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo enviar el reporte. Intenta de nuevo.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);

    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),
      appBar: AppBar(
        title: Text(
          _userName,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: SpotlyColors.text(dark)),
        ),
        leading: widget.showBackButton
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: SpotlyColors.text(dark)),
                onPressed: () { if (mounted) context.pop(); },
              )
            : null,
        backgroundColor: SpotlyColors.bg(dark),
        elevation: 0,
        // Menú hamburguesa en la derecha
        actions: [
          IconButton(
            icon: Icon(LucideIcons.moreVertical,
                color: SpotlyColors.text(dark), size: 22),
            onPressed: () => _mostrarMenu(dark),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: SpotlyColors.accent(dark)))
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage,
                    style: TextStyle(color: SpotlyColors.text(dark))))
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildProfileHeader(dark)),
                    if (_posts.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Text('Este usuario aún no ha publicado nada',
                              style: TextStyle(
                                  color: SpotlyColors.subText(dark))),
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
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isOwnProfile = currentUserId == widget.userId;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundImage: _userAvatar.isNotEmpty
                    ? NetworkImage(_userAvatar)
                    : null,
                backgroundColor: dark ? Colors.white12 : Colors.grey.shade200,
                child: _userAvatar.isEmpty
                    ? Icon(LucideIcons.user, size: 40,
                        color: SpotlyColors.subText(dark))
                    : null,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat('${_posts.length}', 'Publicaciones', dark),
                    GestureDetector(
                      onTap: () => context.push(
                          '/followers/${widget.userId}/followers'),
                      child: _buildStat(
                          '$_followersCount', 'Seguidores', dark),
                    ),
                    GestureDetector(
                      onTap: () => context.push(
                          '/followers/${widget.userId}/following'),
                      child: _buildStat(
                          '$_followingCount', 'Seguidos', dark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(_userName,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: SpotlyColors.text(dark))),
          ),
          const SizedBox(height: 16),
          if (!isOwnProfile)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: _isFollowing
                      ? Colors.grey.shade700
                      : SpotlyColors.accent(dark),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _toggleFollow,
                child: Text(
                  _isFollowing ? 'Siguiendo' : 'Seguir',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label, bool dark) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: SpotlyColors.text(dark))),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: SpotlyColors.subText(dark), fontSize: 13)),
      ],
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
            if (item.userId != widget.userId) _navigateToUserProfile(item.userId);
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      dark ? Colors.white24 : Colors.grey.shade200,
                  backgroundImage: item.avatar.isNotEmpty
                      ? NetworkImage(item.avatar)
                      : null,
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
              ],
            ),
          ),
        ),
        if (item.descripcion != null && item.descripcion!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Text(item.descripcion!,
                style: TextStyle(color: textColor, fontSize: 14)),
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
                onPressed: () {},
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
              Text(count.toString(),
                  style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}