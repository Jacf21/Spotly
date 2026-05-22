import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'suggestion_card.dart';

class HorizontalSuggestions extends StatefulWidget {
  final List<Map<String, dynamic>> suggestedUsers;
  final bool dark;

  const HorizontalSuggestions({super.key, required this.suggestedUsers, required this.dark});

  @override
  State<HorizontalSuggestions> createState() => _HorizontalSuggestionsState();
}

class _HorizontalSuggestionsState extends State<HorizontalSuggestions> {
  late List<Map<String, dynamic>> _list;

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.suggestedUsers);
  }

  @override
  void didUpdateWidget(covariant HorizontalSuggestions oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si la referencia de la lista cambió o su tamaño es diferente, actualizamos
    if (oldWidget.suggestedUsers != widget.suggestedUsers) {
      setState(() {
        _list = List.from(widget.suggestedUsers);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_list.isEmpty) return const SizedBox.shrink(); 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título + Ver Todo
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sugerencias para ti",
                style: TextStyle(
                  color: SpotlyColors.text(widget.dark),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.push('/discover-people'); 
                },
                child: Text(
                  "Ver todo",
                  style: TextStyle(color: SpotlyColors.accent(widget.dark), fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 210, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: _list.length,
            itemBuilder: (context, index) {
              final user = _list[index];
              return SuggestionCard(
                key: ValueKey(user['id_usuario'] ?? index.toString()), 
                user: user,
                dark: widget.dark,
                onRemove: () {
                  setState(() {
                    _list.removeAt(index); 
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Divider(color: SpotlyColors.subText(widget.dark), thickness: 0.5),
      ],
    );
  }
}