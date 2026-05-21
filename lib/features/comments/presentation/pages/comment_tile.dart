part of 'comments_page.dart';

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final bool isOwn;
  final bool dark;
  final Color textColor;
  final Color subColor;
  final VoidCallback onDelete;
  final VoidCallback onReply;
  final void Function(bool isLiked, int newCount) onLikeUpdate;
  final String? targetCommentId;

  const _CommentTile({
    required this.comment,
    required this.isOwn,
    required this.dark,
    required this.textColor,
    required this.subColor,
    required this.onDelete,
    required this.onReply,
    required this.onLikeUpdate,
    this.targetCommentId,
  });

  @override
  Widget build(BuildContext context) {
    final isHighlighted = comment.id.toString() == targetCommentId;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted
            ? Colors.blueAccent.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        if (comment.replyToUserName != null)
                          TextSpan(
                            text: '@${comment.replyToUserName} ',
                            style: const TextStyle(color: Colors.blueAccent),
                          ),
                        TextSpan(text: comment.texto),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        timeago.format(comment.createdAt, locale: 'es'),
                        style: TextStyle(color: subColor, fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: onReply,
                        child: Text(
                          'Responder',
                          style: TextStyle(
                            color: SpotlyColors.accent(dark),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _CommentLikeButton(
                        commentId: comment.id,
                        likeCount: comment.likeCount,
                        isLiked: comment.isLiked,
                        subColor: subColor,
                        onLikeUpdate: onLikeUpdate,
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
      ),
    );
  }
}
