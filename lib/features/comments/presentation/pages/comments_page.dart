import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../../../../core/utils/theme_utils.dart';
import '../../../../core/themes/spotly_colors.dart';
import '../../data/datasources/comment_remote_datasource.dart';
import '../../data/models/comment_model.dart';

part 'comment_tile.dart';
part 'comment_input.dart';
part 'emoji_picker_section.dart';
part 'comment_like_button.dart';

class CommentsPage extends StatefulWidget {
  final int postId;
  final String? targetCommentId;

  const CommentsPage({
    super.key,
    required this.postId,
    this.targetCommentId,
  });

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final Map<String, GlobalKey> _commentKeys = {};

  List<CommentModel> _comments = [];
  CommentModel? _replyingTo;

  bool _isLoading = true;
  bool _isSending = false;
  int _addedCount = 0;
  bool _showEmoji = false;

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

  void _setReplyingTo(CommentModel comment) {
    setState(() => _replyingTo = comment);
    _focusNode.requestFocus();
  }

  void _cancelReply() => setState(() => _replyingTo = null);

  void _toggleEmoji() {
    if (_showEmoji) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
    }
    setState(() => _showEmoji = !_showEmoji);
  }

  void _scrollToTargetComment() {
    if (widget.targetCommentId == null) return;
    final key = _commentKeys[widget.targetCommentId];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id ?? '';

      // Usar el método con likes si el usuario está logueado
      if (userId.isNotEmpty) {
        final data =
            await _datasource.getCommentsWithLikes(widget.postId, userId);
        setState(() => _comments = data);
      } else {
        final data = await _datasource.getComments(widget.postId);
        setState(() => _comments = data);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.targetCommentId != null) {
          Future.delayed(
              const Duration(milliseconds: 300), _scrollToTargetComment);
        }
      });
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

    final replyingTo = _replyingTo;
    final replyToId = replyingTo?.id;
    final replyToUserName = replyingTo?.nombreUsuario;

    String finalTexto = texto;
    if (replyingTo != null) {
      finalTexto = '@${replyingTo.nombreUsuario} $texto';
    }

    _controller.clear();
    _cancelReply();

    try {
      final newComment = await _datasource.addComment(
        postId: widget.postId,
        userId: user.id,
        texto: finalTexto,
        parentId: replyToId,
        replyToUserName: replyToUserName,
      );

      setState(() {
        _comments.add(newComment);
        _addedCount++;
      });
    } catch (e) {
      debugPrint('Error enviando comentario: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar comentario')),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _deleteComment(CommentModel comment) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.id != comment.userId) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar comentario'),
        content: const Text('¿Seguro que quieres eliminar este comentario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _datasource.deleteComment(commentId: comment.id, userId: user.id);
      setState(() {
        _comments.removeWhere((c) => c.id == comment.id);
        _addedCount--;
      });
    } catch (e) {
      debugPrint('Error eliminando: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar el comentario')),
        );
      }
    }
  }

  // Método para actualizar el like de un comentario localmente (callback desde el botón)
  void _updateCommentLike(int commentId, bool isLiked, int newLikeCount) {
    setState(() {
      final index = _comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        _comments[index] = _comments[index].copyWith(
          isLiked: isLiked,
          likeCount: newLikeCount,
        );
      }
    });
  }

  List<CommentModel> get _rootComments =>
      _comments.where((c) => c.parentId == null).toList();

  List<CommentModel> _repliesOf(int parentId) =>
      _comments.where((c) => c.parentId == parentId).toList();

  Widget _buildThread(CommentModel comment, bool dark, Color textColor,
      Color subColor, User? user) {
    final isOwn = user?.id == comment.userId;
    final replies = _repliesOf(comment.id);

    _commentKeys.putIfAbsent(comment.id.toString(), () => GlobalKey());

    return Padding(
      padding: const EdgeInsets.only(left: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CommentTile(
            comment: comment,
            isOwn: isOwn,
            dark: dark,
            textColor: textColor,
            subColor: subColor,
            onDelete: () => _deleteComment(comment),
            onReply: () => _setReplyingTo(comment),
            onLikeUpdate: (isLiked, newCount) =>
                _updateCommentLike(comment.id, isLiked, newCount),
            targetCommentId: widget.targetCommentId,
          ),
          if (replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Column(
                children: replies
                    .map(
                        (r) => _buildThread(r, dark, textColor, subColor, user))
                    .toList(),
              ),
            ),
        ],
      ),
    );
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              if (_replyingTo != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: divColor,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Respondiendo a @${_replyingTo!.nombreUsuario}',
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      IconButton(
                        onPressed: _cancelReply,
                        icon: const Icon(Icons.close, size: 18),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _rootComments.isEmpty
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
                        : ListView(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            children: _rootComments
                                .map((c) => _buildThread(
                                    c, dark, textColor, subColor, user))
                                .toList(),
                          ),
              ),
              if (_showEmoji) _EmojiPickerSection(controller: _controller),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              if (user != null)
                _CommentInput(
                  controller: _controller,
                  focusNode: _focusNode,
                  isSending: _isSending,
                  showEmoji: _showEmoji,
                  dark: dark,
                  textColor: textColor,
                  subColor: subColor,
                  onSend: _sendComment,
                  onToggleEmoji: _toggleEmoji,
                  replyingToUserName: _replyingTo?.nombreUsuario,
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
            ],
          ),
        );
      },
    );
  }
}
