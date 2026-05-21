import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/themes/spotly_colors.dart';
import '../../../../core/utils/theme_utils.dart';

class FollowersPage extends StatefulWidget {
  final String userId;
  final bool showFollowers;

  const FollowersPage({
    super.key,
    required this.userId,
    required this.showFollowers,
  });

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  List users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final client = Supabase.instance.client;

      final response = await client
          .from('seguidores')
          .select('''
            *,
            seguidor:perfiles!seguidores_id_usuario_seguidor_fkey(
              id_usuario,
              nombre_usuario,
              foto_perfil_url
            ),
            seguido:perfiles!seguidores_id_usuario_seguido_fkey(
              id_usuario,
              nombre_usuario,
              foto_perfil_url
            )
          ''')
          .eq(
            widget.showFollowers
                ? 'id_usuario_seguido'
                : 'id_usuario_seguidor',
            widget.userId,
          );

      setState(() {
        users = response;
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);

    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: SpotlyColors.bg(dark),

        title: Text(
          widget.showFollowers
              ? 'Seguidores'
              : 'Seguidos',
          style: TextStyle(
            color: SpotlyColors.text(dark),
            fontWeight: FontWeight.bold,
          ),
        ),

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: SpotlyColors.text(dark),
          ),
          onPressed: () => context.pop(),
        ),
      ),

      body: loading
          ? Center(
              child: CircularProgressIndicator(
                color: SpotlyColors.accent(dark),
              ),
            )
          : users.isEmpty
              ? Center(
                  child: Text(
                    widget.showFollowers
                        ? 'No tiene seguidores'
                        : 'No sigue a nadie',
                    style: TextStyle(
                      color: SpotlyColors.subText(dark),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {

                    final data = widget.showFollowers
                        ? users[index]['seguidor']
                        : users[index]['seguido'];

                    final userId = data['id_usuario'];

                    return ListTile(

                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),

                      leading: CircleAvatar(
                        radius: 26,
                        backgroundImage:
                            data['foto_perfil_url'] != null &&
                                    data['foto_perfil_url']
                                        .toString()
                                        .isNotEmpty
                                ? NetworkImage(
                                    data['foto_perfil_url'],
                                  )
                                : null,

                        backgroundColor:
                            dark
                                ? Colors.white12
                                : Colors.black12,

                        child:
    data['foto_perfil_url'] == null ||
            data['foto_perfil_url']
                .toString()
                .isEmpty
        ? Icon(
            LucideIcons.user,
            color: SpotlyColors.subText(
              dark,
            ),
          )
        : null,
                      ),

                      title: Text(
                        data['nombre_usuario'] ??
                            'Usuario',
                        style: TextStyle(
                          color:
                              SpotlyColors.text(dark),
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      subtitle: Text(
                        '@${data['nombre_usuario'] ?? ''}',
                        style: TextStyle(
                          color:
                              SpotlyColors.subText(
                            dark,
                          ),
                        ),
                      ),

                      trailing: GestureDetector(
  onTap: () {
  context.go('/user/$userId');
},

  child: Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 8,
    ),

    decoration: BoxDecoration(
      color: SpotlyColors.accent(dark),
      borderRadius: BorderRadius.circular(12),
    ),

    child: const Text(
      'Ver perfil',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  ),
),

                      onTap: () {
  context.go('/user/$userId');
},
                    );
                  },
                ),
    );
  }
}