import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:spotly/features/posts/presentation/widgets/horizontal_suggestions.dart';
import 'package:spotly/features/search/data/repositories/search_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
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
import 'package:spotly/features/stories/models/story_model.dart';
import 'package:spotly/features/stories/widgets/stories_bar.dart';
import 'package:spotly/features/stories/services/story_service.dart';


class FeedPage extends StatefulWidget {
  final String? targetPostId;
  final String? targetCommentId;

  const FeedPage({
    super.key,
    this.targetPostId,
    this.targetCommentId,
  });

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final ScrollController _scrollController = ScrollController();

  bool isLoading = false;
  bool hasMore = true;
  List<FeedItemModel> feed = [];
  String? _currentUserId;
  String? highlightedPostId;
  final storyService = StoryService();
List<StoryModel> stories = [];
bool loadingStories = true;

  @override
  void initState() {
    super.initState();

     loadStories();
    _currentUserId = Supabase.instance.client.auth.currentUser?.id;
    loadFeed();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;

      final newUserId = data.session?.user.id;

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

  void _navigateToUserProfile(String userId) {
    if (userId.isEmpty) return;
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == userId) {
      context.push('/profile');
    } else {
      context.push('/user/$userId');
    }
  }

  void _scrollToTargetPost() {
    if (widget.targetPostId == null || feed.isEmpty) return;

    final index = feed.indexWhere(
      (item) => item.id.toString() == widget.targetPostId,
    );

    if (index == -1) return;

    final targetPost = feed[index];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        final screenHeight = MediaQuery.of(context).size.height;

        const double altoHeader = 60.0;   
        const double altoImagen = 300.0;   
        const double altoAcciones = 60.0;  
        const double paddingExtra = 20.0;  
        
        const double itemHeight = altoHeader + altoImagen + altoAcciones + paddingExtra; 
        final double position = (index * itemHeight) + altoHeader + (altoImagen / 2) - (screenHeight / 2);

        _scrollController.animateTo(
          position < 0 ? 0 : position,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.fastOutSlowIn,
        );

        setState(() {
          highlightedPostId = widget.targetPostId;
        });

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => highlightedPostId = null);
        });

        if (widget.targetCommentId != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _openComments(targetPost);
          });
        }
      });
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
  void didUpdateWidget(covariant FeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targetPostId != oldWidget.targetPostId && widget.targetPostId != null) {
      _scrollToTargetPost();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // FUNCIÓN COMPARTIR CORREGIDA - Usa publicaciones y multimedia
  Future<void> _share(FeedItemModel item) async {
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user == null) {
      context.push('/login');
      return;
    }
    
    // No se puede compartir tu propia publicación
    if (user.id == item.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes compartir tu propia publicación')),
      );
      return;
    }
    
    try {
      // Verificar si ya compartiste esta publicación
      final existingShare = await Supabase.instance.client
          .from('publicaciones')
          .select('id_publicacion')
          .eq('id_publicacion_original', item.id)
          .eq('id_usuario_que_comparte', user.id)
          .eq('es_compartido', true)
          .maybeSingle();
      
      if (existingShare != null) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Ya compartiste esta publicación'),
            content: const Text('¿Quieres dejar de compartirla?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        
        if (confirm == true) {
          final sharedPostId = existingShare['id_publicacion'];
          
          // Eliminar la multimedia primero
          await Supabase.instance.client
              .from('multimedia')
              .delete()
              .eq('id_publicacion', sharedPostId);
          
          // Eliminar la publicación compartida
          await Supabase.instance.client
              .from('publicaciones')
              .delete()
              .eq('id_publicacion', sharedPostId);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Has dejado de compartir esta publicación')),
            );
          }
        }
        return;
      }
      
      // Obtener la URL de la imagen del post original desde multimedia
      final multimediaData = await Supabase.instance.client
          .from('multimedia')
          .select('url_recurso, tipo_recurso')
          .eq('id_publicacion', item.id)
          .maybeSingle();
      
      final imageUrl = multimediaData?['url_recurso'] ?? '';
      final tipoRecurso = multimediaData?['tipo_recurso'] ?? 'foto';
      
      // 1. Insertar en publicaciones
final newPostResponse = await Supabase.instance.client
    .from('publicaciones')
    .insert({
      'id_usuario': user.id,
      'id_usuario_que_comparte': user.id,
      'id_usuario_original': item.userId,   // 👈 AGREGAR ESTA LÍNEA
      'id_publicacion_original': item.id,
      'es_compartido': true,
      'descripcion_experiencia': null,
      'comentario_activado': true,
      'visible_para': 'public',
      'id_lugar': item.lugarId,
      'created_at': DateTime.now().toIso8601String(),
    })
    .select('id_publicacion')
    .single();
      
      final newPostId = newPostResponse['id_publicacion'];
      
      // 2. Insertar en multimedia
      await Supabase.instance.client.from('multimedia').insert({
        'id_publicacion': newPostId,
        'url_recurso': imageUrl,
        'tipo_recurso': tipoRecurso,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // Notificar al autor original
      if (item.userId != user.id) {
        await Supabase.instance.client.from('notificaciones').insert({
          'id_usuario_destino': item.userId,
          'id_usuario_actor': user.id,
          'tipo': 'compartir',
          'id_publicacion': item.id,
          'contenido': 'compartió tu publicación 🔄',
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publicación compartida en tu perfil')),
        );
      }
    } catch (e) {
      debugPrint('Error al compartir: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al compartir publicación')),
        );
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
      if (!wasLiked) {
        await Supabase.instance.client
            .from('notificaciones')
            .insert({
          'id_usuario_destino': item.userId,
          'id_usuario_actor': user.id,
          'tipo': 'like',
          'id_publicacion': item.id,
          'contenido': 'le dio like a tu publicación ❤️',
        });
      }
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
        wasSaved: wasSaved,
      );
    } catch (e) {
      setState(() {
        item.isSaved = wasSaved;
      });
    }
  }

  Future<void> loadStories() async {
  try {
    final response = await storyService.getStories();

    if (!mounted) return;

    setState(() {
      stories = response;
      loadingStories = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      stories = [];
      loadingStories = false;
    });
  }
}

  Future<void> _openComments(FeedItemModel item) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsPage(
        postId: item.id,
        targetCommentId: widget.targetCommentId,
      ),
    );
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
    if (mounted) {
        setState(() => feed = data);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _scrollToTargetPost();
          });
        });
      }
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
  
  Future<void> _reportPost(FeedItemModel item, final dark) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      if (mounted) context.push('/login');
      return;
    }

    // Capturar el context del Scaffold ANTES de cualquier await
    final scaffoldMessenger = ScaffoldMessenger.of(context);  
    final controller = TextEditingController();

    // Usar rootNavigator para evitar conflicto con el context del PopupMenu
    final motivo = await showDialog<String>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: SpotlyColors.bg(dark), // Fondo del diálogo
        title: Text(
          "Reportar publicación",
          style: TextStyle(color: SpotlyColors.text(dark)), // Color del título
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          style: TextStyle(color: SpotlyColors.text(dark)), // Color del texto
          decoration: InputDecoration(
            hintText: "Describe el motivo del reporte (opcional)",
            hintStyle: TextStyle(color: SpotlyColors.subText(dark)), // Color del hint
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: dark ? Colors.white24 : Colors.black26),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: SpotlyColors.accent(dark), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "Cancelar",
              style: TextStyle(color: SpotlyColors.subText(dark)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text(
              "Reportar",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    controller.dispose();

    if (motivo == null) return; // usuario canceló

    try {
      await Supabase.instance.client.from('reportes_publicaciones').insert({
        'id_publicacion': item.id,
        'user_id': user.id,
        'motivo': motivo.isEmpty ? null : motivo,
        'pendiente': true,
      });

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('Publicación reportada. Gracias.'),
          backgroundColor: dark ? Colors.grey[800] : Colors.grey[200],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('Error al enviar el reporte'),
          backgroundColor: dark ? Colors.grey[800] : Colors.grey[200],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  
    @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);
    final isGuest = !context.watch<AuthProvider>().isLoggedIn;

    return AnimatedContainer(
      duration: SpotlyConfig.animShort,
      color: SpotlyColors.bg(dark),
      child:
          feed.isEmpty ? _buildEmptyState(dark) : _buildFeedList(dark, isGuest),
    );
  }

  Widget _buildEmptyState(bool dark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.image,
              size: 64, color: dark ? Colors.white38 : Colors.black38),
          const SizedBox(height: 16),
          Text("No hay publicaciones aún 📭",
              style: TextStyle(
                  color: SpotlyColors.text(dark), fontSize: 16)),
          const SizedBox(height: 8),
          TextButton(onPressed: loadFeed, child: const Text("Reintentar")),
        ],
      ),
    );
  }

  Widget _buildFeedList(bool dark, bool isGuest) {
    final totalItemsWithSuggestions = feed.length + 1;
    final finalCount = totalItemsWithSuggestions + (hasMore ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      itemCount: finalCount + 1,
      itemBuilder: (context, index) {
// =====================================
// STORIES
// =====================================

if (index == 0) {

  if (loadingStories) {

    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
if (index == 0) {
  if (isGuest) {
    return const SizedBox(); // 👈 INVITADO NO VE HISTORIAS
  }

  if (loadingStories) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(child: CircularProgressIndicator()),
    );
  }
  return StoriesBar(
    stories: stories,
    onReload: loadStories,
  );
}
}
index--;
        if (hasMore && index == finalCount - 1) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Insertar carrusel horizontal en la posición (índice) del feed
        if (index == 3) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: SearchRepository().getPeopleSuggestions(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              return HorizontalSuggestions(
                suggestedUsers: snapshot.data!,
                dark: dark,
              );
            },
          );
        }

        int postRealIndex;
        if (index > 3) {
          postRealIndex = index - 1;
        } else {
          postRealIndex = index; 
        }

        if (postRealIndex < 0 || postRealIndex >= feed.length) {
          return const SizedBox.shrink();
        }

        // Si pasó las validaciones, dibujamos el post real
        return _buildFeedItem(feed[postRealIndex], dark, isGuest);
      },
      
    );
  }

  Widget _buildFeedItem(FeedItemModel item, bool dark, bool isGuest) {
  final textColor = dark ? Colors.white : Colors.black;
  final subColor = dark ? Colors.white70 : Colors.black54;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Header: avatar + usuario
      GestureDetector(
        onTap: () => _navigateToUserProfile(
          item.isShared ? (item.originalUserId ?? item.userId) : item.userId
        ),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              if (item.isShared)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compartido por ${item.usuario}',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(LucideIcons.repeat, size: 12, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          'Publicación original de @${item.originalUserName ?? "usuario"}',
                          style: TextStyle(
                            color: subColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Text(
                  item.usuario,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: Icon(LucideIcons.moreVertical, color: subColor),
                color: SpotlyColors.card(dark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (value) {
                  if (value == 'report') {
                    Future.delayed(Duration.zero, () {
                      _reportPost(item, dark);
                    });
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        const Icon(LucideIcons.flag, color: Colors.redAccent, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          'Reportar publicación',
                          style: TextStyle(color: SpotlyColors.text(dark)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      
      // Descripción
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
        child: Row(
          children: [
            _iconWithCount(
              icon: LucideIcons.heart,
              dark: dark,
              isGuest: isGuest,
              isActive: item.isLiked,
              activeColor: Colors.red,
              count: item.likesCount,
              onTap: () => _handleLike(item),
            ),
            _iconWithCount(
              icon: LucideIcons.messageCircle,
              dark: dark,
              isGuest: isGuest,
              count: item.comentarioCount,
              isActive: false,
              activeColor: Colors.grey,
              onTap: () async {
                if (!item.comentarioActivado) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("No puedes comentar esta publicación"),
                      backgroundColor: dark ? Colors.white24 : Colors.black87,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                await showModalBottomSheet<int>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => CommentsPage(postId: item.id),
                );
                if (!mounted) return;
                final repo = FeedRepository(
                  FeedRemoteDatasource(Supabase.instance.client),
                );
                final updatedCount = await repo.getCommentCount(item.id);
                if (!mounted) return;
                setState(() => item.comentarioCount = updatedCount);
              },
            ),
            IconButton(
              onPressed: () => _share(item),
              icon: Icon(
                LucideIcons.send,
                color: dark ? Colors.white70 : Colors.black54,
              ),
            ),
            if (item.lugar.isNotEmpty)
              IconButton(
                onPressed: () => context.push('/lugar/${item.lugarId}'),
                icon: Icon(LucideIcons.mapPin,
                    color: dark ? Colors.white70 : Colors.black54),
                tooltip: item.lugar,
              ),
            const Spacer(),
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

  Widget _iconWithCount({
    required IconData icon,
    required bool dark,
    required bool isGuest,
    required VoidCallback onTap,
    bool isActive = false,
    Color activeColor = Colors.red,
    int count = 0,
  }) {
    final color =
        isActive ? activeColor : (dark ? Colors.white70 : Colors.black54);

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