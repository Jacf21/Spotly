part of 'comments_page.dart';

class _CommentLikeButton extends StatefulWidget {
  final int commentId;
  final int likeCount;
  final bool isLiked;
  final Color subColor;
  final void Function(bool isLiked, int newCount) onLikeUpdate;

  const _CommentLikeButton({
    required this.commentId,
    required this.likeCount,
    required this.isLiked,
    required this.subColor,
    required this.onLikeUpdate,
  });

  @override
  State<_CommentLikeButton> createState() => _CommentLikeButtonState();
}

class _CommentLikeButtonState extends State<_CommentLikeButton> {
  late bool _isLiked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _likeCount = widget.likeCount;
  }

  Future<void> _toggleLike() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Estado actual antes del cambio
    final wasLiked = _isLiked;
    final newLiked = !wasLiked;
    final newCount = newLiked ? _likeCount + 1 : _likeCount - 1;

    // Optimistic update
    setState(() {
      _isLiked = newLiked;
      _likeCount = newCount;
    });

    // Notificar al padre para actualizar el modelo
    widget.onLikeUpdate(newLiked, newCount);

    try {
      final datasource = CommentRemoteDatasource(Supabase.instance.client);
      await datasource.toggleLike(widget.commentId, user.id, wasLiked);
    } catch (e) {
      // Revertir en caso de error
      setState(() {
        _isLiked = wasLiked;
        _likeCount = wasLiked ? _likeCount + 1 : _likeCount - 1;
      });
      widget.onLikeUpdate(wasLiked, wasLiked ? _likeCount + 1 : _likeCount - 1);
      debugPrint('Error toggling like: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al procesar el like')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLike,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? Colors.red : widget.subColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          if (_likeCount > 0)
            Text(
              '$_likeCount',
              style: TextStyle(
                color: _isLiked ? Colors.red : widget.subColor,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }
}
