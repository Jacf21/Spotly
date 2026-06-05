part of 'comments_page.dart';

/// Widget que representa un comentario individual en la lista.
/// Muestra avatar, nombre de usuario, texto, fecha, botones de responder y like,
/// y opción de eliminar si es propio.
class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final bool isOwn;
  final bool dark;
  final Color textColor;
  final Color subColor;
  final VoidCallback onDelete;
  final VoidCallback? onReply; // Puede ser null (si depth >= 1, no se muestra botón responder)
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
            /// Avatar del usuario
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
                  /// Texto del comentario con soporte para menciones (@usuario)
                  Flexible(
                    child: RichText(
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      text: _buildTextWithMention(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      /// Fecha formateada (ej: "hace 5 minutos")
                      Text(
                        timeago.format(comment.createdAt, locale: 'es'),
                        style: TextStyle(color: subColor, fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                      
                      /// Botón "Responder" - solo visible si onReply no es null
                      /// (se oculta en respuestas de profundidad >= 1)
                      if (onReply != null)
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
                      
                      /// Botón de like del comentario
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
            
            /// Botón de eliminar - solo visible para comentarios del usuario actual
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

  /// Construye el texto del comentario con formato especial para menciones.
  /// Si el texto comienza con @, extrae la mención y la muestra en color azul.
  /// Ejemplo: "@usuario Hola" → muestra "[nombre] @usuario Hola"
  TextSpan _buildTextWithMention() {
    final texto = comment.texto;
    // Si el texto empieza con @, extraer la mención
    if (texto.startsWith('@')) {
      final espacioIndex = texto.indexOf(' ');
      if (espacioIndex != -1) {
        final mencion = texto.substring(0, espacioIndex);
        final resto = texto.substring(espacioIndex + 1);
        return TextSpan(
          style: TextStyle(color: textColor, fontSize: 14),
          children: [
            TextSpan(
              text: '${comment.nombreUsuario} ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: '$mencion ',
              style: const TextStyle(color: Colors.blueAccent),
            ),
            TextSpan(text: resto),
          ],
        );
      }
    }
    // Si no hay mención al inicio, mostrar todo normal
    return TextSpan(
      style: TextStyle(color: textColor, fontSize: 14),
      children: [
        TextSpan(
          text: '${comment.nombreUsuario} ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(text: texto),
      ],
    );
  }
}