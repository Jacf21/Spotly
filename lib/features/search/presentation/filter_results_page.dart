import 'package:flutter/material.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/features/search/data/repositories/search_repository.dart';
import 'package:spotly/features/search/widgets/grid_place_item.dart';

// Esta página muestra los resultados filtrados por distancia o departamento, dependiendo de la pestaña seleccionada
class FilterResultsPage extends StatefulWidget {
  final bool dark;
  const FilterResultsPage({super.key, required this.dark});

  @override
  State<FilterResultsPage> createState() => _FilterResultsPageState();
}

class _FilterResultsPageState extends State<FilterResultsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // VARIABLES DE FILTRO
  double _radius = 10.0;
  int? _selectedDeptId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = SpotlyColors.bg(widget.dark);
    final txtColor = SpotlyColors.text(widget.dark);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: txtColor),
        title: Text("Explorar", style: TextStyle(color: txtColor)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: SpotlyColors.accent(widget.dark),
          labelColor: SpotlyColors.accent(widget.dark),
          unselectedLabelColor: SpotlyColors.subText(widget.dark),
          tabs: const [
            Tab(text: "Cercanos"),
            Tab(text: "Departamentos"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de filtros dinámica
          _buildDynamicFilterBar(txtColor),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // PESTAÑA 1: CERCANOS (GPS)
                PlacesGrid(
                  type: 'distancia', 
                  value: _radius, 
                  dark: widget.dark
                ),

                // PESTAÑA 2: DEPARTAMENTOS
                PlacesGrid(
                  type: 'depto', 
                  value: _selectedDeptId, 
                  dark: widget.dark
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicFilterBar(Color txtColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: widget.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _tabController.index == 0 
          ? _buildDistanceSlider(txtColor) 
          : _buildDeptSelector(txtColor),
      ),
    );
  }

  Widget _buildDistanceSlider(Color txtColor) {
    return Row(
      key: const ValueKey(0),
      children: [
        Text("${_radius.round()} km", style: TextStyle(color: txtColor, fontWeight: FontWeight.bold)),
        Expanded(
          child: Slider(
            value: _radius,
            min: 1, max: 100,
            activeColor: SpotlyColors.accent(widget.dark),
            onChanged: (v) => setState(() => _radius = v),
          ),
        ),
        Icon(Icons.location_on, color: SpotlyColors.accent(widget.dark), size: 18),
      ],
    );
  }

  Widget _buildDeptSelector(Color txtColor) {
    return Row(
      key: const ValueKey(1),
      children: [
        Icon(Icons.map, color: SpotlyColors.accent(widget.dark), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: SearchRepository().getDepartamentos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LinearProgressIndicator();
              }
              
              if (snapshot.hasError) return const Text("Error al cargar");

              final depts = snapshot.data ?? [];
              
              return DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedDeptId, 
                  hint: Text("Elegir departamento", 
                      style: TextStyle(color: SpotlyColors.subText(widget.dark))),
                  dropdownColor: SpotlyColors.bg(widget.dark),
                  isExpanded: true,
                  items: depts.map((d) => DropdownMenuItem<int>(
                    value: d['id_departamento'] as int, 
                    child: Text(d['nombre_departamento'], style: TextStyle(color: txtColor))
                  )).toList(),
                  onChanged: (id) {
                    setState(() => _selectedDeptId = id);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}