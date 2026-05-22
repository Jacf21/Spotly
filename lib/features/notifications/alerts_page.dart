import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';

import '../../../../core/themes/spotly_colors.dart';
import '../../../../core/utils/theme_utils.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  List notifications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();

    timeago.setLocaleMessages('es', timeago.EsMessages());

    load();
    clearBadge();
  }

  Future<void> clearBadge() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    await Supabase.instance.client
        .from('notificaciones')
        .update({'leido': true})
        .eq('id_usuario_destino', user.id)
        .eq('leido', false);

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> load() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final data = await Supabase.instance.client
        .from('notificaciones')
        .select('''
          *,
          actor:perfiles!notificaciones_id_usuario_actor_fkey(
            nombres,
            apellidos,
            foto_perfil_url
          ),
          publicaciones (
            titulo
          ),
          lugares (
            nombre_lugar
          )
        ''')
        .eq('id_usuario_destino', user.id)
        .order('created_at', ascending: false);

    setState(() {
      notifications = data;
      loading = false;
    });
  }

  String buildNotificationText(Map n) {
  final actor = n['actor'];

  final nombre =
      '${actor?['nombres'] ?? ''} ${actor?['apellidos'] ?? ''}'.trim();

  switch (n['tipo']) {
    case 'like':
      return '$nombre indicó que le gusta tu publicación ❤️';

    case 'comentario':
      return '$nombre comentó tu publicación 💬';

    case 'follow':
      return '$nombre comenzó a seguirte 👤';

    case 'sugerencia_lugar':
      final lugar =
          n['lugares']?['nombre_lugar'] ?? 'un lugar';

      return '$nombre te sugirió visitar $lugar 📍';
    case 'advertencia_publicacion':
      return n['contenido'];

    case 'compartir':
      return '$nombre compartio tu publicación';

    default:
      return 'Nueva notificación';
  }
}

  String buildSubtitle(Map n) {
  if (n['tipo'] == 'sugerencia_lugar') {
    return n['lugares']?['nombre_lugar'] ?? '';
  }

  return n['publicaciones']?['titulo'] ?? '';
}

  Future<void> markAsRead(int id) async {
    await Supabase.instance.client
        .from('notificaciones')
        .update({'leido': true})
        .eq('id_notificacion', id);
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);

    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Notificaciones",
          style: TextStyle(
            color: SpotlyColors.text(dark),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: SpotlyColors.text(dark),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(
                  child: Text(
                    "No tienes notificaciones",
                    style: TextStyle(
                      color: SpotlyColors.subText(dark),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: notifications.length,
                  itemBuilder: (context, i) {
                    final n = notifications[i];

                    final isRead = n['leido'] ?? false;

                    return GestureDetector(
                      onTap: () async {
                        await markAsRead(n['id_notificacion']);

                        if (mounted) {
                          setState(() {
                            n['leido'] = true;
                          });
                        }

                        final tipo = n['tipo'];

                        if (tipo == 'sugerencia_lugar') {
                          final lugarId = n['id_lugar'];

                          if (lugarId != null) {
                            context.push('/lugar/$lugarId');
                          }

                          return;
                        }
                        if (tipo == 'follow') {

                        final actorId = n['id_usuario_actor'];

                        if (actorId != null) {
                        context.push('/user/$actorId');
                            }

                          return;
                            }

                        if (tipo == 'advertencia_publicacion') {
                          return;
                        }

                        if (tipo == 'compartir') {
                          final originalPostId = n['id_publicacion'];
                          final actorId = n['id_usuario_actor'];

                          if (originalPostId == null) return;

                          // Buscar la publicación compartida por ese actor
                          final result = await Supabase.instance.client
                              .from('publicaciones')
                              .select('id_publicacion')
                              .eq('es_compartido', true)
                              .eq('id_publicacion_original', originalPostId)
                              .eq('id_usuario_que_comparte', actorId)
                              .order('created_at', ascending: false)
                              .limit(1)
                              .maybeSingle();

                          final sharedPostId = result?['id_publicacion'] ?? originalPostId;

                          if (mounted) {
                            context.push('/feed?postId=$sharedPostId');
                          }
                          return;
                        }

                        final postId = n['id_publicacion'];
                        final commentId = n['id_comentario'];

                        if (postId == null) return;

                        if (tipo == 'comentario' &&
                            commentId != null) {
                          context.push(
                            '/feed?postId=$postId&commentId=$commentId',
                          );
                        } else {
                          context.push('/feed?postId=$postId');
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isRead
                              ? (dark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.03))
                              : SpotlyColors.accent(dark)
                                  .withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                dark ? Colors.white10 : Colors.black12,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications,
                              color: SpotlyColors.accent(dark),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    buildNotificationText(n),
                                    style: TextStyle(
                                      color:
                                          SpotlyColors.text(dark),
                                      fontWeight: isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  if (buildSubtitle(n).isNotEmpty)
                                    Text(
                                      "En: ${buildSubtitle(n)}",
                                      style: TextStyle(
                                        color: SpotlyColors.subText(dark),
                                      ),
                                    ),

                                  const SizedBox(height: 4),

                                  Text(
                                    timeago.format(
                                      DateTime.parse(
                                        n["created_at"],
                                      ).toLocal(),
                                      locale: 'es',
                                    ),
                                    style: TextStyle(
                                      color:
                                          SpotlyColors.subText(dark),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.15);
                  },
                ),
    );
  }
}