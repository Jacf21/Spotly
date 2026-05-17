import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/core/utils/theme_utils.dart';
import 'package:spotly/core/widgets/feed/spotly_feed_item.dart';
import 'package:spotly/core/widgets/feed/spotly_image_viewer.dart';
import '../../data/datasources/lugar_remote_datasource.dart';
import '../../data/repositories/lugar_repository.dart';
import '../../data/models/lugar_detalle_model.dart';
import '../../data/models/lugar_post_model.dart';
import '../../../posts/data/models/feed_item_model.dart';
import 'edit_lugar_page.dart';

class LugarProfilePage extends StatefulWidget {
  final int lugarId;
  const LugarProfilePage({super.key, required this.lugarId});

  @override
  State<LugarProfilePage> createState() => _LugarProfilePageState();
}

class _LugarProfilePageState extends State<LugarProfilePage> {
  LugarDetalleModel? _lugar;
  List<LugarPostModel> _posts = [];
  bool _loadingLugar = true;
  bool _loadingPosts = false;
  bool _hasMore = true;
  bool _gridView = true;
  bool _isFavorite = false;

  late final LugarRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = LugarRepository(LugarRemoteDatasource(Supabase.instance.client));
    _loadDetalle();
    _loadPosts();
    _loadFavoriteState();
  }

  Future<void> _loadDetalle() async {
    final data = await _repo.getDetalle(widget.lugarId);
    if (mounted)
      setState(() {
        _lugar = data;
        _loadingLugar = false;
      });
  }

  Future<void> _loadPosts() async {
    if (_loadingPosts || !_hasMore) return;
    setState(() => _loadingPosts = true);
    final userId = Supabase.instance.client.auth.currentUser?.id ??
        '00000000-0000-0000-0000-000000000000';
    final newPosts = await _repo.getPublicaciones(
      lugarId: widget.lugarId,
      userId: userId,
      lastCreatedAt:
          _posts.isEmpty ? null : _posts.last.createdAt.toIso8601String(),
    );
    setState(() {
      if (newPosts.isEmpty)
        _hasMore = false;
      else
        _posts.addAll(newPosts);
      _loadingPosts = false;
    });
  }

  Future<void> _loadFavoriteState() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('favoritos_lugares')
          .select()
          .eq('user_id', user.id)
          .eq('lugar_id', widget.lugarId);

      if (mounted) {
        setState(() {
          _isFavorite = response.isNotEmpty;
        });
      }
    } catch (e) {
      debugPrint("Error loading favorite state: $e");
      if (mounted) {
        setState(() {
          _isFavorite = false;
        });
      }
    }
  }

  // Convierte LugarPostModel → FeedItemModel para SpotlyFeedItem
  FeedItemModel _toFeedItem(LugarPostModel p) => FeedItemModel(
        id: p.id,
        userId: p.userId,
        descripcion: p.descripcion,
        mediaUrl: p.mediaUrl,
        tipo: 'foto',
        lugar: _lugar?.nombre ?? '',
        usuario: p.usuario,
        avatar: p.avatar,
        createdAt: p.createdAt,
        isLiked: p.isLiked,
        isSaved: false,
        likesCount: p.likesCount,
        comentarioCount: p.comentarioCount,
        comentarioActivado: true,
        visiblePara: 'public',
        lugarId: widget.lugarId,
      );

  void _irAlMapaEnEsteLugar() {
    final coords = _lugar?.coordenadas;
    if (coords == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este lugar no tiene ubicación registrada'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    context.push('/map', extra: coords);
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);
    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),
      body: _loadingLugar
          ? Center(
              child:
                  CircularProgressIndicator(color: SpotlyColors.accent(dark)))
          : _lugar == null
              ? _buildError(dark)
              : _buildContent(dark),
    );
  }

  Widget _buildError(bool dark) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(LucideIcons.mapPin, size: 48, color: SpotlyColors.subText(dark)),
          const SizedBox(height: 12),
          Text("Lugar no encontrado",
              style: TextStyle(color: SpotlyColors.text(dark), fontSize: 16)),
        ]),
      );

  Widget _buildContent(bool dark) {
    final l = _lugar!;
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels > n.metrics.maxScrollExtent - 300) _loadPosts();
        return false;
      },
      child: CustomScrollView(
        slivers: [
          // ── AppBar ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: SpotlyColors.bg(dark),
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: l.fotoPortadaUrl != null
                      ? Colors.white
                      : SpotlyColors.text(dark)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: l.fotoPortadaUrl != null
                      ? Colors.white
                      : SpotlyColors.text(dark),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditLugarPage(lugar: l),
                      fullscreenDialog: true,
                    ),
                  );
                  if (result == true && mounted) {
                    _loadDetalle(); // Recargar datos después de editar
                  }
                },
                tooltip: 'Editar lugar turístico',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: l.fotoPortadaUrl != null
                  ? Stack(fit: StackFit.expand, children: [
                      Image.network(l.fotoPortadaUrl!, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ])
                  : Container(color: SpotlyColors.card(dark)),
            ),
          ),

          // ── Info del lugar ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre + botones (favorito + ver en mapa + sugerir) + badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          l.nombre,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: SpotlyColors.text(dark),
                          ),
                        ),
                      ),

                      Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ── Botón "Ver en mapa" ────────────────────
                              if (l.coordenadas != null)
                                Tooltip(
                                  message: 'Ver en mapa',
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: _irAlMapaEnEsteLugar,
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: SpotlyColors.accent(dark)
                                            .withOpacity(0.12),
                                      ),
                                      child: Icon(
                                        LucideIcons.mapPin,
                                        size: 20,
                                        color: SpotlyColors.accent(dark),
                                      ),
                                    ),
                                  ),
                                ),

                              // ── Botón favorito ─────────────────────────
                              _buildFavoriteButton(dark),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // ── Botón sugerir lugar ────────────────────
                          _buildSuggestButton(dark),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Categoría + Departamento
                  Row(children: [
                    if (l.categoria.isNotEmpty) ...[
                      Icon(LucideIcons.tag,
                          size: 14, color: SpotlyColors.subText(dark)),
                      const SizedBox(width: 4),
                      Text(l.categoria,
                          style: TextStyle(
                              color: SpotlyColors.subText(dark), fontSize: 13)),
                      const SizedBox(width: 12),
                    ],
                    if (l.departamento.isNotEmpty) ...[
                      Icon(LucideIcons.mapPin,
                          size: 14, color: SpotlyColors.subText(dark)),
                      const SizedBox(width: 4),
                      Text(l.departamento,
                          style: TextStyle(
                              color: SpotlyColors.subText(dark), fontSize: 13)),
                    ],
                  ]),

                  const SizedBox(height: 20),

                  // Chips
                  Wrap(spacing: 10, runSpacing: 8, children: [
                    if (l.alturaMsnm != null)
                      _chip("${l.alturaMsnm} msnm", LucideIcons.mountain, dark),
                    if (l.climaRecomendado != null)
                      _chip(l.climaRecomendado!, LucideIcons.cloud, dark),
                    if (l.mejorEpocaVisitar != null)
                      _chip(l.mejorEpocaVisitar!, LucideIcons.calendar, dark),
                  ]),

                  // Descripción
                  if (l.descripcion != null) ...[
                    const SizedBox(height: 20),
                    Text("Sobre este lugar",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: SpotlyColors.text(dark))),
                    const SizedBox(height: 8),
                    Text(l.descripcion!,
                        style: TextStyle(
                            color: SpotlyColors.subText(dark),
                            fontSize: 14,
                            height: 1.6)),
                  ],

                  // Info útil
                  if (l.informacionUtil != null) ...[
                    const SizedBox(height: 20),
                    _infoCard(l.informacionUtil!, dark),
                  ],

                  // Cabecera publicaciones
                  const SizedBox(height: 28),
                  Row(children: [
                    Icon(LucideIcons.image,
                        size: 18, color: SpotlyColors.accent(dark)),
                    const SizedBox(width: 8),
                    Text("Publicaciones",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: SpotlyColors.text(dark))),
                    const Spacer(),
                    _viewToggleBtn(
                      icon: LucideIcons.layoutGrid,
                      active: _gridView,
                      dark: dark,
                      onTap: () => setState(() => _gridView = true),
                    ),
                    const SizedBox(width: 4),
                    _viewToggleBtn(
                      icon: LucideIcons.list,
                      active: !_gridView,
                      dark: dark,
                      onTap: () => setState(() => _gridView = false),
                    ),
                  ]),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Grid ───────────────────────────────────────────────
          if (_gridView)
            _posts.isEmpty && !_loadingPosts
                ? SliverToBoxAdapter(child: _buildNoPosts(dark))
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => GestureDetector(
                          onTap: () => SpotlyImageViewer.show(
                            context,
                            initialIndex: i,
                            items: _posts
                                .map((p) => SpotlyImageItem(
                                      imageUrl: p.mediaUrl,
                                      descripcion: p.descripcion,
                                      usuario: p.usuario,
                                    ))
                                .toList(),
                          ),
                          child: _buildPostTile(_posts[i], dark),
                        ),
                        childCount: _posts.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.85,
                      ),
                    ),
                  ),

          // ── Feed ───────────────────────────────────────────────
          if (!_gridView)
            _posts.isEmpty && !_loadingPosts
                ? SliverToBoxAdapter(child: _buildNoPosts(dark))
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => SpotlyFeedItem(
                        item: _toFeedItem(_posts[i]),
                        dark: dark,
                        showLugarButton: false,
                      ),
                      childCount: _posts.length,
                    ),
                  ),

          if (_loadingPosts)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildPostTile(LugarPostModel post, bool dark) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(fit: StackFit.expand, children: [
          Image.network(post.mediaUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                    color: SpotlyColors.card(dark),
                    child: Icon(LucideIcons.imageOff,
                        color: SpotlyColors.subText(dark)),
                  )),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
              child: Row(children: [
                const Icon(LucideIcons.heart, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(post.likesCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ]),
            ),
          ),
        ]),
      );

  Widget _buildNoPosts(bool dark) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text("Aún no hay publicaciones de este lugar",
              style:
                  TextStyle(color: SpotlyColors.subText(dark), fontSize: 14)),
        ),
      );

  Widget _viewToggleBtn({
    required IconData icon,
    required bool active,
    required bool dark,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: active
                ? SpotlyColors.accent(dark).withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              size: 20,
              color: active
                  ? SpotlyColors.accent(dark)
                  : SpotlyColors.subText(dark)),
        ),
      );

  Widget _chip(String label, IconData icon, bool dark) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: SpotlyColors.card(dark),
          borderRadius: BorderRadius.circular(20),
          boxShadow: SpotlyColors.shadow(dark),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: SpotlyColors.subText(dark)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(color: SpotlyColors.text(dark), fontSize: 12)),
        ]),
      );

  Widget _infoCard(String info, bool dark) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SpotlyColors.accent(dark).withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: SpotlyColors.accent(dark).withOpacity(0.2)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(LucideIcons.info, size: 18, color: SpotlyColors.accent(dark)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(info,
                style: TextStyle(
                    color: SpotlyColors.text(dark), fontSize: 13, height: 1.5)),
          ),
        ]),
      );

  Widget _buildFavoriteButton(bool dark) => Tooltip(
        message: _isFavorite ? "Quitar de favoritos" : "Marcar como favorito",
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () async {
            final user = Supabase.instance.client.auth.currentUser;
            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Debes iniciar sesión")),
              );
              return;
            }
            final previous = _isFavorite;
            setState(() => _isFavorite = !previous);
            try {
              await _repo.toggleFavorite(
                  userId: user.id, lugarId: widget.lugarId);
              await _loadFavoriteState();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isFavorite
                      ? "💜 Lugar agregado a favoritos"
                      : "❌ Lugar eliminado de favoritos"),
                ),
              );
            } catch (e) {
              setState(() => _isFavorite = previous);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _isFavorite
                  ? const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)])
                  : null,
              color: !_isFavorite
                  ? (dark ? Colors.white10 : Colors.grey.shade200)
                  : null,
              boxShadow: _isFavorite
                  ? [
                      BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.6),
                          blurRadius: 12)
                    ]
                  : [],
            ),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: _isFavorite ? 1.2 : 1.0,
              child: Icon(
                LucideIcons.heart,
                color: _isFavorite
                    ? Colors.white
                    : (dark ? Colors.white70 : Colors.black54),
                size: 20,
              ),
            ),
          ),
        ),
      );

  // ── Botón para sugerir lugar ──────────────────────────────────────────────
  Widget _buildSuggestButton(bool dark) {
    return Tooltip(
      message: "Sugerir lugar",
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () async {
          final user = Supabase.instance.client.auth.currentUser;
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Debes iniciar sesión")),
            );
            return;
          }

          try {
            // 🔹 Obtener seguidores
            final seguidores = await Supabase.instance.client
                .from('seguidores')
                .select('id_usuario_seguidor')
                .eq('id_usuario_seguido', user.id);

            if (seguidores.isEmpty) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No tienes seguidores")),
              );
              return;
            }

            // 🔹 Obtener nombre del usuario actor
            final perfil = await Supabase.instance.client
                .from('perfiles')
                .select('nombre_usuario')
                .eq('id_usuario', user.id)
                .single();

            final nombreUsuario = perfil['nombre_usuario'] ?? 'Alguien';

            // 🔹 Crear lista de notificaciones
            final notifications = seguidores.map((seguidor) {
              return {
                'id_usuario_destino': seguidor['id_usuario_seguidor'],
                'id_usuario_actor': user.id,
                'tipo': 'sugerencia_lugar',
                'contenido':
                    '$nombreUsuario te sugirió visitar ${_lugar?.nombre} 📍',
                'id_lugar': widget.lugarId,
              };
            }).toList();

            // 🔹 Insertar todas las notificaciones
            await Supabase.instance.client
                .from('notificaciones')
                .insert(notifications);

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('📍 Lugar sugerido a ${seguidores.length} seguidores'),
              ),
            );
          } catch (e) {
            debugPrint(e.toString());
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error al sugerir lugar')),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: SpotlyColors.accent(dark),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: SpotlyColors.accent(dark).withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.send, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                'Sugerir lugar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
