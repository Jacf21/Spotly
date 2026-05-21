part of 'comments_page.dart';

class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final bool showEmoji;
  final bool dark;
  final Color textColor;
  final Color subColor;
  final VoidCallback onSend;
  final VoidCallback onToggleEmoji;
  final String? replyingToUserName;

  const _CommentInput({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.showEmoji,
    required this.dark,
    required this.textColor,
    required this.subColor,
    required this.onSend,
    required this.onToggleEmoji,
    this.replyingToUserName,
  });

  @override
  Widget build(BuildContext context) {
    final hint = replyingToUserName != null
        ? 'Responder a @$replyingToUserName...'
        : 'Agrega un comentario...';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggleEmoji,
            child: Icon(
              showEmoji ? LucideIcons.keyboard : LucideIcons.smile,
              color: subColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(color: textColor, fontSize: 14),
              maxLines: null,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: subColor, fontSize: 14),
                filled: true,
                fillColor: dark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.black.withOpacity(0.04),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
