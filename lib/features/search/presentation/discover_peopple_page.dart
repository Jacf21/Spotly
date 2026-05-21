import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotly/core/utils/theme_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/features/search/data/repositories/search_repository.dart';
// Página de Descubrir Personas, que muestra sugerencias de usuarios para seguir
class DiscoverPeoplePage extends StatefulWidget {
  const DiscoverPeoplePage({super.key});

  @override
  State<DiscoverPeoplePage> createState() => _DiscoverPeoplePageState();
}

class _DiscoverPeoplePageState extends State<DiscoverPeoplePage> {
  final _repository = SearchRepository();
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    setState(() => _isLoading = true);
    final data = await _repository.getAllPeopleDiscover();
    if (mounted) {
      setState(() {
        _users = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);

    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),
      appBar: AppBar(
        backgroundColor: SpotlyColors.nav(dark),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: SpotlyColors.text(dark)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Descubrir personas",
          style: TextStyle(color: SpotlyColors.text(dark), fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              "Sugerencias para ti",
              style: TextStyle(color: SpotlyColors.text(dark), fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          
          // Contenido principal de la lista
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? Center(
                        child: Text(
                          "No hay sugerencias disponibles",
                          style: TextStyle(color: SpotlyColors.subText(dark), fontSize: 14),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadSuggestions,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return _buildUserRow(user, dark);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // CONSTRUCCIÓN DE CADA FILA DE USUARIO
  Widget _buildUserRow(Map<String, dynamic> user, bool dark) {
    final String firstName = user['nombres'] ?? '';
    final String lastName = user['apellidos'] ?? '';
    String displayName = '$firstName $lastName'.trim();
    if (displayName.isEmpty) {
      displayName = user['nombre_usuario'] ?? 'Usuario';
    }

    final String userId = user['id_usuario'] ?? '';
    bool isFollowing = user['ya_lo_sigo'] ?? false;

    return StatefulBuilder(
      builder: (context, setRowState) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              // Avatar con redirección al perfil
              GestureDetector(
                onTap: () => userId.isNotEmpty ? context.push('/user/$userId') : null,
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: SpotlyColors.accent(dark).withOpacity(0.2),
                  backgroundImage: user['foto_perfil_url'] != null && user['foto_perfil_url'].toString().isNotEmpty
                      ? NetworkImage(user['foto_perfil_url'])
                      : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                ),
              ),
              const SizedBox(width: 14),
              
              // Textos informativos (Nombre + Sugerencia)
              Expanded(
                child: GestureDetector(
                  onTap: () => userId.isNotEmpty ? context.push('/user/$userId') : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(color: SpotlyColors.text(dark), fontSize: 14, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Sugerencia para ti",
                        style: TextStyle(color: SpotlyColors.subText(dark), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Botón de acción Dinámico (Seguir / Siguiendo)
              SizedBox(
                height: 32,
                width: 90,
                child: isFollowing
                    ? OutlinedButton(
                        onPressed: () async {
                          // Permitir dejar de seguir al presionar el botón gris
                          setRowState(() => isFollowing = false);
                          final success = await _performUnfollow(userId);
                          if (!mounted) return;
                          if (!success) {
                            setRowState(() => isFollowing = true); // Revierte si falla la red
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: SpotlyColors.subText(dark)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          "Siguiendo",
                          style: TextStyle(color: SpotlyColors.subText(dark), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          setRowState(() => isFollowing = true);
                          final success = await _performFollow(userId);
                          if (!mounted) return;
                          if (!success) {
                            setRowState(() => isFollowing = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SpotlyColors.accent(dark),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          "Seguir",
                          style: TextStyle(color: SpotlyColors.text(dark), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
              
              // Icono de tres puntos sin ninguna función por ahora, pero que puede servir para opciones adicionales en el futuro
              IconButton(
                icon: Icon(Icons.more_vert, color: SpotlyColors.text(dark), size: 20),
                onPressed: () {
                  // Menú de opciones extra si lo requieres más adelante
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _performFollow(String targetUserId) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) return false;

      await supabase.from('seguidores').insert({
        'id_usuario_seguidor': currentUserId,
        'id_usuario_seguido': targetUserId,
      });
      return true;
    } catch (e) {
      print('Error al seguir en pantalla de descubrimiento: $e');
      return false;
    }
  }

  /// Remueve la relación de seguimiento en Supabase
  Future<bool> _performUnfollow(String targetUserId) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) return false;

      // Eliminamos la fila correspondiente en tu tabla de relaciones
      await supabase
          .from('seguidores')
          .delete()
          .eq('id_usuario_seguidor', currentUserId)
          .eq('id_usuario_seguido', targetUserId);
          
      print('Se dejó de seguir exitosamente a: $targetUserId');
      return true;
    } catch (e) {
      print('Error en Supabase al dejar de seguir: $e');
      return false;
    }
  }
}