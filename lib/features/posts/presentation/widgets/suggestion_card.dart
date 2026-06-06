import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotly/core/themes/spotly_colors.dart';

// Tarjeta individual para cada sugerencia de usuario
class SuggestionCard extends StatefulWidget {
  final Map<String, dynamic> user;
  final bool dark;
  final VoidCallback onRemove;

  const SuggestionCard({
    super.key,
    required this.user,
    required this.dark,
    required this.onRemove,
  });

  @override
  State<SuggestionCard> createState() => _SuggestionCardState();
}

// Esta clase maneja el estado de cada tarjeta de sugerencia, incluyendo si el usuario
// ya es seguido o no, y maneja las acciones de seguir/dejar de seguir con sus respectivas notificaciones.
class _SuggestionCardState extends State<SuggestionCard> {
  late bool _isFollowing;
  bool _isLoadingFollow = false;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.user['ya_lo_sigo'] ?? false;
  }

  @override
  void didUpdateWidget(covariant SuggestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user['ya_lo_sigo'] != widget.user['ya_lo_sigo']) {
      _isFollowing = widget.user['ya_lo_sigo'] ?? false;
    }
  }

  // Acción de Seguir + Notificación
  @override
  Widget build(BuildContext context) {
    final txtColor = SpotlyColors.text(widget.dark);
    final cardBg = widget.dark ? const Color(0xFF1E293B).withOpacity(0.7) : const Color.fromARGB(255, 213, 212, 212);

    final String firstName = widget.user['nombres'] ?? '';
    final String lastName = widget.user['apellidos'] ?? '';
    String displayName = '$firstName $lastName'.trim();
    
    if (displayName.isEmpty) {
      displayName = widget.user['nombre_usuario'] ?? 'Usuario';
    }

    final String userId = widget.user['id_usuario'] ?? '';

    return Container(
      width: 155,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBg),
      ),
      child: GestureDetector(
        onTap: () {
          if (userId.isEmpty) return;
          context.push('/user/$userId');
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned(
              top: 8, right: 8,
              child: GestureDetector(
                onTap: widget.onRemove,
                child: Icon(Icons.close, size: 16, color: SpotlyColors.subText(widget.dark)),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: SpotlyColors.accent(widget.dark).withOpacity(0.2),
                    backgroundImage: widget.user['foto_perfil_url'] != null && widget.user['foto_perfil_url'].toString().isNotEmpty
                        ? NetworkImage(widget.user['foto_perfil_url'])
                        : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    displayName,
                    style: TextStyle(color: txtColor, fontSize: 13, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  
                  Text(
                    "Sugerencia para ti",
                    style: TextStyle(color: SpotlyColors.subText(widget.dark), fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const Spacer(),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: _isFollowing 
                      ? _buildFollowingButton(userId)
                      : _buildFollowButton(userId),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton(String userIdToFollow) {
    return ElevatedButton(
      onPressed: _isLoadingFollow ? null : () async {
        if (!mounted) return;

        setState(() {
          _isFollowing = true; 
          _isLoadingFollow = true;
        });

        final success = await _performFollowAction(userIdToFollow);

        if (!mounted) return;

        setState(() {
          _isLoadingFollow = false;
          if (!success) {
            _isFollowing = false; 
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: SpotlyColors.accent(widget.dark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        padding: EdgeInsets.zero,
      ),
      child: _isLoadingFollow 
        ? SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: SpotlyColors.bg(widget.dark)))
        : Text(
            "Seguir",
            style: TextStyle(color: SpotlyColors.text(widget.dark), fontSize: 12, fontWeight: FontWeight.bold),
          ),
    );
  }

  Widget _buildFollowingButton(String userIdToUnfollow) {
    return OutlinedButton(
      onPressed: _isLoadingFollow ? null : () async {
        if (!mounted) return;

        setState(() {
          _isFollowing = false;
          _isLoadingFollow = true;
        });

        final success = await _performUnfollowAction(userIdToUnfollow);

        if (!mounted) return;

        setState(() {
          _isLoadingFollow = false;
          if (!success) {
            _isFollowing = true;
          }
        });
      }, 
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: SpotlyColors.subText(widget.dark)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.zero,
      ),
      child: _isLoadingFollow
        ? SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: SpotlyColors.subText(widget.dark)))
        : Text(
            "Siguiendo",
            style: TextStyle(
              color: SpotlyColors.subText(widget.dark),
              fontSize: 12, 
              fontWeight: FontWeight.w600,
            ),
          ),
    );
  }

  //Acción de Seguir + Registro en la tabla maestra de notificaciones
  Future<bool> _performFollowAction(String targetUserId) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) return false;

      // Crear la relación en la tabla de seguidores
      await supabase.from('seguidores').insert({
        'id_usuario_seguidor': currentUserId,
        'id_usuario_seguido': targetUserId,
      });

      // Insertar la alerta en la tabla maestra unificada
      await supabase.from('notificaciones').insert({
        'id_usuario_destino': targetUserId,   // Quién recibe el follow
        'id_usuario_actor': currentUserId,    // Quién presiona el botón "Seguir"
        'tipo': 'follow',                      // El tipo que lee tu switch/case
        'leido': false,
      });
      
      return true;
    } catch (e) {
      print('Error en Supabase al seguir / notificar: $e');
      return false;
    }
  }

  // Acción de Dejar de Seguir + Limpieza automática de la notificación
  Future<bool> _performUnfollowAction(String targetUserId) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      if (currentUserId == null) return false;

      // Eliminar el registro de seguimiento
      await supabase
          .from('seguidores')
          .delete()
          .eq('id_usuario_seguidor', currentUserId)
          .eq('id_usuario_seguido', targetUserId);

      // Eliminar la notificación de follow para no dejar datos huérfanos
      await supabase
          .from('notificaciones')
          .delete()
          .eq('id_usuario_destino', targetUserId)
          .eq('id_usuario_actor', currentUserId)
          .eq('tipo', 'follow');

      return true;
    } catch (e) {
      print('Error en Supabase al dejar de seguir / remover notificación: $e');
      return false;
    }
  }
}