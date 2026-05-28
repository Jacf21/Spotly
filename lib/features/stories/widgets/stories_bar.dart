import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/story_model.dart';
import '../../../../core/utils/theme_utils.dart';
import '../services/story_service.dart';
import '../pages/story_viewer_page.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:image_picker/image_picker.dart';

class StoriesBar extends StatelessWidget {
  final List<StoryModel> stories;
  final VoidCallback onReload;

  const StoriesBar({
    super.key,
    required this.stories,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);

    final grouped = <String, List<StoryModel>>{};

    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser?.id;
    final user = supabase.auth.currentUser;

    for (final s in stories) {
  if (s.userId != currentUser) {
    grouped.putIfAbsent(s.userId, () => []).add(s);
  }
}

    final users = grouped.entries.toList();

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: users.length + 1,
        itemBuilder: (context, index) {

          // =====================================
          // TU HISTORIA (ADD STORY)
          // =====================================
          // =====================================
// TU HISTORIA (ADD STORY)
// =====================================
if (index == 0) {
  final myStories = stories
      .where((s) => s.userId == user!.id)
      .toList();

  final hasStories = myStories.isNotEmpty;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [

            // 🔵 AVATAR (SOLO VISUAL + CLICK DEPENDIENDO DE ESTADO)
            GestureDetector(
              onTap: () async {
                if (!hasStories) {
                  // ❌ NO TIENE STORIES → abre selector
                  final service = StoryService();

                  final XFile? file =
                      await showModalBottomSheet<XFile>(
                    context: context,
                    builder: (_) {
                      return SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text("Cámara"),
                              onTap: () async {
                                final img = await service.takePhoto();
                                if (context.mounted) {
                                  Navigator.pop(context, img);
                                }
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo),
                              title: const Text("Galería"),
                              onTap: () async {
                                final img = await service.pickGallery();
                                if (context.mounted) {
                                  Navigator.pop(context, img);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );

                  if (file != null) {
                    await service.uploadStory(file);
                    onReload();
                  }
                } else {
                  // ✔ YA TIENE STORIES → ABRE VIEWER
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          StoryViewerPage(stories: myStories),
                    ),
                  ).then((_) => onReload());
                }
              },

              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF2DD4BF),
                    width: 2,
                  ),
                  color: dark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                ),
                child: FutureBuilder(
                  future: supabase
                      .from('perfiles')
                      .select('foto_perfil_url')
                      .eq('id_usuario', user!.id)
                      .single(),
                  builder: (context, snapshot) {
                    final url = snapshot.data?['foto_perfil_url'];

                    return ClipOval(
                      child: (url != null && url != '')
                          ? Image.network(
                              url,
                              fit: BoxFit.cover,
                              width: 68,
                              height: 68,
                            )
                          : const Center(child: Icon(Icons.person)),
                    );
                  },
                ),
              ),
            ),

            // ➕ SOLO BOTÓN REAL DE SUBIR STORY
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () async {
                  final service = StoryService();

                  final XFile? file =
                      await showModalBottomSheet<XFile>(
                    context: context,
                    builder: (_) {
                      return SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text("Cámara"),
                              onTap: () async {
                                final img = await service.takePhoto();
                                if (context.mounted) {
                                  Navigator.pop(context, img);
                                }
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo),
                              title: const Text("Galería"),
                              onTap: () async {
                                final img = await service.pickGallery();
                                if (context.mounted) {
                                  Navigator.pop(context, img);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );

                  if (file != null) {
  await service.uploadStory(file);
  onReload();

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("📸 Historia subida correctamente"),
      duration: Duration(seconds: 2),
      backgroundColor: Colors.black87,
    ),
  );
}
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
  "Tu historia",
  style: TextStyle(
    fontSize: 12,
    color: SpotlyColors.text(dark),
  ),
),
      ],
    ),
  );
}

          // =====================================
          // STORIES USUARIOS
          // =====================================
          final userEntry = users[index - 1];
final userStories = userEntry.value;
final first = userStories.first;


          final currentUser =
              Supabase.instance.client.auth.currentUser?.id;

          final viewed = userStories.every((s) =>
              s.viewedBy.any((v) => v['id_usuario'] == currentUser));

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      StoryViewerPage(stories: userStories),
                ),
              ).then((_) => onReload());
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // 🔥 Borde tipo Instagram + Spotly
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: viewed
                            ? [
                                Colors.grey.shade400,
                                Colors.grey.shade500
                              ]
                            : [
                                const Color(0xFF2DD4BF),
                                const Color(0xFF0891B2),
                              ],
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            NetworkImage(first.imageUrl),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  SizedBox(
                    width: 70,
                    child: Text(
  first.username.isNotEmpty ? first.username : 'Usuario',
  textAlign: TextAlign.center,
  overflow: TextOverflow.ellipsis,
  style: TextStyle(
    fontSize: 12,
    color: SpotlyColors.text(dark),
  ),
),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}