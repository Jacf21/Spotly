import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';

import '../../../../core/themes/spotly_colors.dart';
import '../../../../core/utils/theme_utils.dart';
import '../../../../core/utils/notifications_helper.dart';

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

  await markNotificationsAsSeen(user.id);

  if (mounted) {
    setState(() {});
  }
}

  Future<void> load() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final myId = user.id;

    final posts = await Supabase.instance.client
        .from('publicaciones')
        .select('id_publicacion, titulo')
        .eq('id_usuario', myId);

    if (posts.isEmpty) {
      setState(() {
        loading = false;
      });
      return;
    }

    final ids = posts.map((e) => e['id_publicacion']).toList();

    final titles = {
      for (var p in posts) p['id_publicacion']: p['titulo']
    };

    final likes = await Supabase.instance.client
        .from('likes')
        .select()
        .inFilter('id_publicacion', ids);

    final comments = await Supabase.instance.client
        .from('comentarios')
        .select()
        .inFilter('id_publicacion', ids)
        .neq('id_usuario', myId);

    List data = [];

    Map<dynamic, List<dynamic>> groupedLikes = {};

for (final like in likes) {
  final postId = like['id_publicacion'];

  groupedLikes.putIfAbsent(postId, () => []);
  groupedLikes[postId]!.add(like);
}

for (final entry in groupedLikes.entries) {
  final postId = entry.key;
  final group = entry.value;

  List<String> nombres = [];

  for (final like in group) {
    final perfil = await Supabase.instance.client
        .from('perfiles')
        .select('nombres')
        .eq('id_usuario', like['id_usuario'])
        .single();

    nombres.add(perfil['nombres']);
  }

  final firstName = nombres.first;
  final others = nombres.length - 1;

  String text;

  if (others <= 0) {
    text = "$firstName indicó que le gusta tu publicación ❤️";
  } else {
    text =
        "$firstName y $others personas más indicaron que les gusta tu publicación ❤️";
  }

  data.add({
  "text": text,
  "post": titles[postId] ?? '',
  "date": group.last["created_at"],
  "readKey": "like_$postId",
  "postId": postId,
  "type": "like",
});
}

    for (final c in comments) {
      final actorId = c['id_usuario'];

      final perfil = await Supabase.instance.client
          .from('perfiles')
          .select('nombres, apellidos')
          .eq('id_usuario', actorId)
          .single();

      final nombre = '${perfil['nombres']} ${perfil['apellidos']}';

        data.add({
         "text": "$nombre comentó: ${c['texto_comentario']}",
         "post": titles[c['id_publicacion']] ?? '',
         "date": c["created_at"],
         "readKey": "comment_${c['id_comentario']}",
         "postId": c["id_publicacion"],
         "commentId": c["id_comentario"],
         "type": "comment",
         });
    }

    data.sort((a, b) => b["date"].compareTo(a["date"]));

    setState(() {
      notifications = data;
      loading = false;
    });
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

  return FutureBuilder<bool>(
    future: isNotificationRead(n["readKey"]),
    builder: (context, snapshot) {
      final isRead = snapshot.data ?? false;

      return GestureDetector(
        onTap: () async {
          await markNotificationRead(n["readKey"]);

          if (mounted) {
            setState(() {});
          }

          final postId = n["postId"];
          context.push('/post-detail/$postId');
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isRead
                ? (dark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03))
                : SpotlyColors.accent(dark).withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark ? Colors.white10 : Colors.black12,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n["text"],
                      style: TextStyle(
                        color: SpotlyColors.text(dark),
                        fontWeight: isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "En: ${n["post"]}",
                      style: TextStyle(
                        color: SpotlyColors.subText(dark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeago.format(
                        DateTime.parse(n["date"]).toLocal(),
                        locale: 'es',
                      ),
                      style: TextStyle(
                        color: SpotlyColors.subText(dark),
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
  );
},
                ),
    );
  }
}