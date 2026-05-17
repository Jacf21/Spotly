import 'package:flutter/material.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/features/search/widgets/search_account.dart';
import 'package:spotly/features/search/widgets/search_places.dart';
import 'package:spotly/features/search/widgets/search_publication.dart';
// Esta clase es la que se encarga de manejar la lógica del buscador y mostrar las pestañas correspondientes
class SpotlySearchDelegate extends SearchDelegate {
  final bool dark;
  SpotlySearchDelegate({required this.dark});

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: SpotlyColors.bg(dark),
        elevation: 0,
        iconTheme: IconThemeData(color: SpotlyColors.text(dark)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: SpotlyColors.subText(dark)),
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: TextStyle(color: SpotlyColors.text(dark)), 
      ),
      scaffoldBackgroundColor: SpotlyColors.bg(dark),
    );
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      color: SpotlyColors.text(dark),
      onPressed: () => close(context, null),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          color: SpotlyColors.text(dark),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  PreferredSizeWidget? buildBottom(BuildContext context) => null;

  @override
  Widget buildResults(BuildContext context) => _SearchBody(query: query, dark: dark);

  @override
  Widget buildSuggestions(BuildContext context) => _SearchBody(query: query, dark: dark);
}

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
    return Container(
      color: SpotlyColors.bg(widget.dark),
      child: Column(
        children: [
          Container(
            color: SpotlyColors.bg(widget.dark),
            child: TabBar(
              controller: _tabController,
              indicatorColor: SpotlyColors.accent(widget.dark),
              labelColor: SpotlyColors.accent(widget.dark),
              unselectedLabelColor: SpotlyColors.subText(widget.dark),
              dividerColor: Colors.transparent, 
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
                SearchPostsTab(query: widget.query, dark: widget.dark),
                SearchAccountsTab(
                  query: widget.query, 
                  dark: widget.dark, 
                  onSelect: (user) => Navigator.of(context).pop(),
                ),
                SearchPlacesTab(query: widget.query, dark: widget.dark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}