import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🔑 clave por usuario
String _notifKey(String userId) => 'last_seen_notifications_$userId';

Future<int> getNotificationCount(String userId) async {
  final prefs = await SharedPreferences.getInstance();

  final saved = prefs.getString(_notifKey(userId));

  final lastSeen =
      saved != null ? DateTime.parse(saved) : DateTime(2000);

  final posts = await Supabase.instance.client
      .from('publicaciones')
      .select('id_publicacion')
      .eq('id_usuario', userId);

  if (posts.isEmpty) return 0;

  final ids = posts.map((e) => e['id_publicacion']).toList();

  final likes = await Supabase.instance.client
      .from('likes')
      .select()
      .inFilter('id_publicacion', ids)
      .neq('id_usuario', userId)
      .gt('created_at', lastSeen.toIso8601String());

  final comments = await Supabase.instance.client
      .from('comentarios')
      .select()
      .inFilter('id_publicacion', ids)
      .neq('id_usuario', userId)
      .gt('created_at', lastSeen.toIso8601String());

  return likes.length + comments.length;
}

/// 👁 marcar todas como vistas
Future<void> markNotificationsAsSeen(String userId) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString(
    _notifKey(userId),
    DateTime.now().toUtc().toIso8601String(),
  );
}

/// ✅ saber si UNA notificación fue leída
Future<bool> isNotificationRead(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key) ?? false;
}

/// ✅ marcar UNA notificación como leída
Future<void> markNotificationRead(String key) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, true);
}