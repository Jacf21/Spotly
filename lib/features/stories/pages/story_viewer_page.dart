import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/story_model.dart';
import '../services/story_service.dart';

class StoryViewerPage extends StatefulWidget {
  final List<StoryModel> stories;

  const StoryViewerPage({
    super.key,
    required this.stories,
  });

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage> {
  final controller = StoryController();

  @override
  void initState() {
    super.initState();

    // Marcar vistas SOLO UNA VEZ
    for (final story in widget.stories) {
      StoryService().markAsViewed(story.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        Supabase.instance.client.auth.currentUser?.id;

    final isMine = widget.stories.first.userId == currentUserId;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// =========================
          /// STORIES
          /// =========================
          StoryView(
            storyItems: widget.stories.map((story) {
              return StoryItem.pageImage(
                url: story.imageUrl,
                controller: controller,
                shown: false,
                duration: const Duration(seconds: 15),
                
              );
            }).toList(),
            controller: controller,
            repeat: false,
            onComplete: () => Navigator.pop(context),
          ),

          /// =========================
          /// DELETE STORY (SOLO MÍO)
          /// =========================
          if (isMine)
            Positioned(
              top: 50,
              right: 20,
              child: PopupMenuButton(
                color: Colors.black,
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Eliminar historia',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'delete') {
                    await StoryService()
                        .deleteStory(widget.stories.first.id);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            ),

          /// =========================
          /// VIEWERS (👁️)
          /// =========================
          if (isMine)
            Positioned(
  bottom: 40,
  left: 20,
  child: IgnorePointer(
    ignoring: false,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          
          debugPrint("👁️ OJO PRESIONADO");

          controller.pause();

          final story = widget.stories.first;
         
          final viewers =
              await StoryService().getStoryViews(story.id);

          debugPrint("👁️ VIEWERS: $viewers");

          if (!context.mounted) return;

          await showModalBottomSheet(
            context: context,
            backgroundColor: Colors.black,
            builder: (_) {
              if (viewers.isEmpty) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      "Nadie ha visto esta historia",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: viewers.length,
                itemBuilder: (context, index) {
                  final v = viewers[index];
                  final perfil = v['perfiles'];

                  final name =
                      perfil?['nombre_usuario'] ?? 'Usuario';

                  final photo =
                      perfil?['foto_perfil_url'] ?? '';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: photo.isNotEmpty
                          ? NetworkImage(photo)
                          : null,
                      child: photo.isEmpty
                          ? const Icon(Icons.person,
                              color: Colors.white)
                          : null,
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              );
            },
          );

          controller.play();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(Icons.remove_red_eye, color: Colors.white),
    const SizedBox(width: 6),

    Text(
      '${widget.stories.first.viewedBy.length}',
      style: const TextStyle(color: Colors.white),
    ),

    const SizedBox(width: 6),

    const Text(
      'Vistas',
      style: TextStyle(color: Colors.white),
    ),
  ],
),
        ),
      ),
    ),
  ),
)
        ],
      ),
    );
  }
}