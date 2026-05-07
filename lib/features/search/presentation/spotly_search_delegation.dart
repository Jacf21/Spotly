import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/features/posts/data/datasources/feed_remote_datasource.dart';
import 'package:spotly/features/posts/data/models/feed_item_model.dart';
import 'package:spotly/features/posts/data/repositories/feed_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SpotlySearchDelegate extends SearchDelegate {
  final bool dark;
  SpotlySearchDelegate({required this.dark});

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  // IMPORTANTE: Dejamos buildBottom vacío para evitar el conflicto del controlador arriba
  @override
  PreferredSizeWidget? buildBottom(BuildContext context) => null;

  @override
  Widget buildResults(BuildContext context) => _SearchBody(query: query, dark: dark);

  @override
  Widget buildSuggestions(BuildContext context) => _SearchBody(query: query, dark: dark);
}

// Creamos un widget aparte para manejar las pestañas correctamente
class _SearchBody extends StatefulWidget {
  final String query;
  final bool dark;
  const _SearchBody({required this.query, required this.dark});

  @override
  State<_SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<_SearchBody> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Aquí dibujamos el TabBar manualmente para que tenga acceso al _tabController
        Container(
          color: widget.dark ? const Color(0xFF0F1117) : Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: SpotlyColors.accent(widget.dark),
            labelColor: SpotlyColors.accent(widget.dark),
            unselectedLabelColor: SpotlyColors.subText(widget.dark),
            tabs: const [
              Tab(text: "Publicación"),
              Tab(text: "Cuentas"),
              Tab(text: "Lugares"),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _SearchPostsTab(query: widget.query, dark: widget.dark),   // Pestaña de Publicaciones
              _SearchAccountsTab(query: widget.query, dark: widget.dark, onSelect: (user) {Navigator.of(context).pop();},), // Pestaña de Cuentas
              _SearchPlacesTab(query: widget.query, dark: widget.dark),   // Pestaña de Lugares
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchAccountsTab extends StatelessWidget {
  final String query;
  final bool dark;
  final Function(dynamic) onSelect;
  const _SearchAccountsTab({required this.query, required this.dark, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return _buildEmptyState("Busca amigos por su nombre");
    return FutureBuilder(
        // Consulta a la tabla de perfiles
        future: Supabase.instance.client
      .from('perfiles')
      .select()
      .ilike('nombre_usuario', '%$query%')
      .limit(15),
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final users = snapshot.data as List;
        if (users.isEmpty) return _buildEmptyState("No se encontraron exploradores");

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user['nombre_usuario'], style: TextStyle(color: SpotlyColors.text(dark))),
              onTap: () {
                Navigator.of(context).pop(); 
                // 2. Navegamos a la pantalla de perfil del usuario seleccionado
                /*Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(userId: user['id']), // Usa el ID de Supabase
                  ),
                );*/
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String text) => Center(child: Text(text));
}

class _SearchPlacesTab extends StatelessWidget {
  final String query;
  final bool dark;

  const _SearchPlacesTab({
    required this.query,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text(
          "Busca destinos increíbles",
          style: TextStyle(color: SpotlyColors.subText(dark)),
        ),
      );
    }

    return FutureBuilder(
      // 1. Cambiamos a la tabla de lugares (ajusta el nombre si es 'locations' o 'spots')
      future: Supabase.instance.client
          .from('lugares') 
          .select()
          .ilike('nombre_lugar', '%$query%') // Ajusta 'place_name' al nombre de tu columna
          .limit(15),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error al buscar lugares"));
        }

        final places = snapshot.data as List? ?? [];

        if (places.isEmpty) {
          return Center(
            child: Text(
              "No encontramos ese lugar",
              style: TextStyle(color: SpotlyColors.subText(dark)),
            ),
          );
        }

        return ListView.builder(
          itemCount: places.length,
          itemBuilder: (context, index) {
            final place = places[index];
            return ListTile(
              leading: Icon(
                LucideIcons.mapPin, // Usamos Lucide para que coincida con tu Feed
                color: dark ? Colors.white70 : Colors.black54,
              ),
              title: Text(
                place['nombre_lugar'] ?? 'Lugar sin nombre', // Ajusta al nombre de tu columna
                style: TextStyle(color: SpotlyColors.text(dark)),
              ),
              subtitle: Text(
                place['ciudad'] ?? 'Explorar lugar',
                style: TextStyle(color: SpotlyColors.subText(dark)),
              ),
              onTap: () {
                final String id = place['id_lugar'].toString();
                
                // Cerramos el buscador antes de navegar
                Navigator.pop(context);
                
                // Navegación idéntica a feed_page.dart
                context.push('/lugar/$id');
              },
            );
          },
        );
      },
    );
  }
}

class _SearchPostsTab extends StatelessWidget {
  final String query;
  final bool dark;

  const _SearchPostsTab({required this.query, required this.dark});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return _buildInfoState("Explora nuevas aventuras");

    return FutureBuilder<List<FeedItemModel>>(
      // REUTILIZAMOS tu repositorio para mantener la lógica de negocio
      future: _fetchSearchPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data ?? [];
        if (posts.isEmpty) return _buildInfoState("No hay publicaciones para \"$query\"");

        return GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final item = posts[index];
            return GestureDetector(
              onTap: () {
                Navigator.pop(context); // Cierras el buscador
                
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true, // Para que pueda ocupar más espacio
                  builder: (context) => FractionallySizedBox(
                    heightFactor: 0.9, // Ocupa el 90% de la pantalla
                    //child: PostDetailWidget(item: item), // Un widget que solo muestra ese post
                  ),
                );
              },
              child: Image.network(
                item.mediaUrl, // Usamos la propiedad que ya definiste en tu modelo
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: dark ? Colors.white12 : Colors.black12,
                  child: const Icon(LucideIcons.imageOff, size: 20),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Método para conectar con tu lógica de Supabase
  Future<List<FeedItemModel>> _fetchSearchPosts() async {
    final repo = FeedRepository(
      FeedRemoteDatasource(Supabase.instance.client),
    );
    
    // Aquí usamos una búsqueda por descripción basada en tu repositorio
    // Si tu repo no tiene un método de búsqueda, puedes filtrar el feed
    // o usar una consulta directa que devuelva el modelo.
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '00000000-0000-0000-0000-000000000000';
    
    // Nota: Si quieres búsqueda exacta en DB, podrías añadir un método 'searchPosts' a tu Repo
    return await repo.getFeed(
      userId: userId,
      lat: -16.5, // Coordenadas por defecto de tu FeedPage
      lng: -68.15,
      // Aquí idealmente pasarías el query al repo
    ).then((list) => list.where((element) => 
      element.descripcion?.toLowerCase().contains(query.toLowerCase()) ?? false
    ).toList());
  }

  Widget _buildInfoState(String text) {
    return Center(
      child: Text(text, style: TextStyle(color: dark ? Colors.white38 : Colors.black38)),
    );
  }
}