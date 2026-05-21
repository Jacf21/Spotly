import 'package:flutter/material.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/features/posts/presentation/pages/user_profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Esta clase es la que se muestra en la pestaña de "Cuentas" dentro del buscador
class SearchAccountsTab extends StatelessWidget {
  final String query;
  final bool dark;
  final Function(dynamic) onSelect;

  const SearchAccountsTab({
    super.key,
    required this.query,
    required this.dark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos el color de fondo según el tema
    final backgroundColor = SpotlyColors.bg(dark);
    final textColor = SpotlyColors.text(dark);
    final subTextColor = SpotlyColors.subText(dark);

    if (query.isEmpty) {
      return Container(
        color: backgroundColor,
        child: Center(
          child: Text(
            "Busca amigos exploradores",
            style: TextStyle(color: subTextColor),
          ),
        ),
      );
    }

    return Container(
      color: backgroundColor,
      child: FutureBuilder(
        future: Supabase.instance.client
            .from('perfiles')
            .select()
            .ilike('nombre_usuario', '%$query%')
            .limit(15),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: SpotlyColors.accent(dark)));
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return _buildEmptyState("Error al buscar exploradores", backgroundColor, subTextColor);
          }

          final users = snapshot.data as List;
          if (users.isEmpty) {
            return _buildEmptyState("No se encontraron exploradores", backgroundColor, subTextColor);
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: dark ? Colors.white10 : Colors.grey.shade200,
                  child: Icon(Icons.person, color: subTextColor),
                ),
                title: Text(
                  user['nombre_usuario'],
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  "Explorador de Spotly",
                  style: TextStyle(color: subTextColor, fontSize: 12),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfilePage(userId: user['id_usuario']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String text, Color bg, Color textCol) => Container(
        color: bg,
        child: Center(
          child: Text(text, style: TextStyle(color: textCol)),
        ),
      );
}
