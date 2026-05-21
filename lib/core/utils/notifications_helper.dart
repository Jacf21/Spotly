import 'package:supabase_flutter/supabase_flutter.dart';

/// 🔔 Contar notificaciones NO leídas
Future<int> getNotificationCount(String userId) async {

  final response = await Supabase.instance.client
      .from('notificaciones')
      .select('id_notificacion')
      .eq('id_usuario_destino', userId)
      .eq('leido', false);

  return response.length;
}

/// 👁 Marcar TODAS como leídas
Future<void> markNotificationsAsSeen(String userId) async {

  await Supabase.instance.client
      .from('notificaciones')
      .update({'leido': true})
      .eq('id_usuario_destino', userId)
      .eq('leido', false);
}

/// ✅ Marcar UNA notificación como leída
Future<void> markNotificationRead(int notificationId) async {

  await Supabase.instance.client
      .from('notificaciones')
      .update({'leido': true})
      .eq('id_notificacion', notificationId);
}

/// ✅ Saber si una notificación está leída
Future<bool> isNotificationRead(int notificationId) async {

  final response = await Supabase.instance.client
      .from('notificaciones')
      .select('leido')
      .eq('id_notificacion', notificationId)
      .single();

  return response['leido'] ?? false;
}