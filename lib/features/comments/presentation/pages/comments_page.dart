import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/utils/theme_utils.dart';
import '../../../../core/themes/spotly_colors.dart';
import '../../data/datasources/comment_remote_datasource.dart';
import '../../data/models/comment_model.dart';

class CommentsPage extends StatefulWidget {
  final int postId;

  const CommentsPage({super.key, required this.postId});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;

  late final CommentRemoteDatasource _datasource;

  @override
  void initState() {
    super.initState();
    _datasource = CommentRemoteDatasource(Supabase.instance.client);
    _loadComments();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    try {
      final data = await _datasource.getComments(widget.postId);
      setState(() => _comments = data);
    } catch (e) {
      debugPrint('Error cargando comentarios: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendComment() async {
    final user = Supabase.instance.client.auth.currentUser;
    final texto = _controller.text.trim();

    if (user == null || texto.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _controller.clear();

    try {
      final newComment = await _datasource.addComment(
        postId: widget.postId,
        userId: user.id,
        texto: texto,
      );

      setState(() => _comments.add(newComment));

      // Scroll al último comentario
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      debugPrint('Error enviando comentario: $e');
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _deleteComment(CommentModel comment) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.id != comment.userId) return;

    // Confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar comentario'),
        content: const Text('¿Seguro que quieres eliminar este comentario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _datasource.deleteComment(
        commentId: comment.id,
        userId: user.id,
      );
      setState(() => _comments.removeWhere((c) => c.id == comment.id));
    } catch (e) {
      debugPrint('Error eliminando: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);
    final user = Supabase.instance.client.auth.currentUser;
    final bgColor = dark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = dark ? Colors.white : Colors.black;
    final subColor = dark ? Colors.white54 : Colors.black45;
    final divColor = dark ? Colors.white10 : Colors.black12;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // ── Handle ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: subColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Título ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Text(
                      'Comentarios',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(LucideIcons.x, color: subColor),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: divColor),

              // ── Lista de comentarios ──────────────────────────────
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _comments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.messageCircle,
                                    size: 48, color: subColor),
                                const SizedBox(height: 12),
                                Text('Sin comentarios aún',
                                    style: TextStyle(color: subColor)),
                                const SizedBox(height: 4),
                                Text('¡Sé el primero!',
                                    style: TextStyle(
                                        color: subColor, fontSize: 12)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              final isOwn = user?.id == comment.userId;

                              return _CommentTile(
                                comment: comment,
                                isOwn: isOwn,
                                dark: dark,
                                textColor: textColor,
                                subColor: subColor,
                                onDelete: () => _deleteComment(comment),
                              );
                            },
                          ),
              ),

              Divider(height: 1, color: divColor),

              // ── Input ─────────────────────────────────────────────
              if (user != null)
                _CommentInput(
                  controller: _controller,
                  focusNode: _focusNode,
                  isSending: _isSending,
                  dark: dark,
                  textColor: textColor,
                  subColor: subColor,
                  onSend: _sendComment,
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () => context.push('/login'),
                    child: Text(
                      'Inicia sesión para comentar',
                      style: TextStyle(
                        color: SpotlyColors.accent(dark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              // Padding para teclado
              SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }
}

// ── Tile de comentario ─────────────────────────────────────────────────
class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final bool isOwn;
  final bool dark;
  final Color textColor;
  final Color subColor;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.isOwn,
    required this.dark,
    required this.textColor,
    required this.subColor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: dark ? Colors.white24 : Colors.grey.shade200,
            backgroundImage: comment.avatarUrl.isNotEmpty
                ? NetworkImage(comment.avatarUrl)
                : null,
            child: comment.avatarUrl.isEmpty
                ? Icon(LucideIcons.user, size: 16, color: subColor)
                : null,
          ),
          const SizedBox(width: 10),

          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: textColor, fontSize: 14),
                    children: [
                      TextSpan(
                        text: '${comment.nombreUsuario} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: comment.texto),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeago.format(comment.createdAt, locale: 'es'),
                  style: TextStyle(color: subColor, fontSize: 11),
                ),
              ],
            ),
          ),

          // Eliminar (solo el dueño)
          if (isOwn)
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(LucideIcons.trash2, size: 16, color: subColor),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Input de comentario ────────────────────────────────────────────────
class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final bool dark;
  final Color textColor;
  final Color subColor;
  final VoidCallback onSend;

  const _CommentInput({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.dark,
    required this.textColor,
    required this.subColor,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(color: textColor, fontSize: 14),
              maxLines: null,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Agrega un comentario...',
                hintStyle: TextStyle(color: subColor, fontSize: 14),
                filled: true,
                fillColor: dark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.black.withOpacity(0.04),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          isSending
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : GestureDetector(
                  onTap: onSend,
                  child: Icon(
                    LucideIcons.send,
                    color: SpotlyColors.accent(dark),
                    size: 26,
                  ),
                ),
        ],
      ),
    );
  }
}